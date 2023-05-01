from connect import get_connection
from random import random, choice
from string import ascii_letters, digits
import config
import argparse
import threading
import time


def random_integer(max_value: int = 1_000_000):
    return int(random() * max_value)


def random_bool():
    return choice([True, False])


def random_string(length=30):
    return "".join([choice(ascii_letters + digits) for _ in range(length)])


generators = {
    'string': random_string,
    'unsigned': random_integer,
    'integer': random_integer,
    'boolean': random_bool,
}


class TarantoolClient:
    def __init__(self, spaces: dict) -> None:
        self.connection = get_connection()
        self.spaces = spaces

    def get_space(self, name: str):
        return self.connection.space(name)

    def select(self, name: str):
        print(f'{len(self.connection.select(name))=}')

    def insert(self, name: str):
        space = self.get_space(name)
        space_cols = self.spaces[name]
        try:
            inserted = space.insert(tuple(
                generators[col_type]() for _, col_type in space_cols.items()
            ))
            print(f'{inserted=}')
        except:
            pass


is_running = True


def thread_insert():
    global is_running
    t = TarantoolClient(config.spaces)
    while is_running:
        for space_name in config.spaces:
            t.insert(space_name)


def thread_select():
    global is_running
    t = TarantoolClient(config.spaces)
    while is_running:
        for space_name in config.spaces:
            t.select(space_name)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--threads',
        type=int,
        default=10,
        help="threads amount"
    )
    args = parser.parse_args()
    threads = []

    for index in range(args.threads):

        if random() > 0.5:
            t = threading.Thread(target=thread_insert)
        else:
            t = threading.Thread(target=thread_select)
        threads.append(t)
        t.start()

    try:
        while True:
            time.sleep(100)
    except (KeyboardInterrupt, SystemExit):
        global is_running
        is_running = False
        print('Received keyboard interrupt, quitting threads.')

    for index, thread in enumerate(threads):
        thread.join()
        print(f"Main    : thread {index} done")


if __name__ == '__main__':
    # t = TarantoolClient(config.spaces)
    # table = t.get_space('customer')

    # for space_name in config.spaces:
    #     t.insert(space_name)
    #     t.select(space_name)

    main()
