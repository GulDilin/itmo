from connect import get_connection
from random import random, choice
from string import ascii_letters, digits
import config
import argparse
import threading
import tarantool
import time
import requests
import logging


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
    def __init__(self, spaces: dict, store_connection = False) -> None:
        self.connection = get_connection()
        self.spaces = spaces
        self.store_connection = store_connection

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

    def select_customer(self):
        idx = random_integer()
        try:
            if self.store_connection:
                selected = self.connection.call('customer_lookup', (idx,))
            else:
                selected = get_connection().call('customer_lookup', (idx,))
            print(f'{selected=}')
        except Exception as e:
            print(f'SELECT FAILED: {e}')

    def insert_customer(self):
        space_cols = self.spaces['customer']
        data = {
            key: generators[col_type]()
            for key, col_type in space_cols.items()
        }
        try:
            if self.store_connection:
                inserted = self.connection.call('customer_add', (data,))
            else:
                inserted = get_connection().call('customer_add', (data,))
            print(f'{inserted=}')
        except Exception as e:
            print(f'INSERT FAILED: {e}')


class TarantoolCartridgeClient:
    def __init__(self, spaces: dict) -> None:
        self.space = 'customer'
        self.spaces = spaces

    def select(self):
        idx = random_integer()
        response = requests.get(f'{config.APP_URI}/storage/{self.space}s/{idx}', timeout=1)
        if response.status_code == 500:
            print('SELECT FAILED')
        else:
            print(f'{response.status_code} {response.content=}')

    def insert(self):
        space_cols = self.spaces[self.space]
        try:
            data = {
                key: generators[col_type]()
                for key, col_type in space_cols.items()
            }
            response = requests.post(f'{config.APP_URI}/storage/{self.space}s/create', json=data, timeout=1)
            if response.status_code >= 500:
                print(f'{response.status_code} INSERT FAILED {response.content}')
            else:
                print(f'{response.status_code} {data=}')
        except:
            pass


is_running = True


def thread_insert():
    global is_running
    print('Start insert thread')
    t = TarantoolClient(config.spaces)
    while is_running:
        for space_name in config.spaces:
            t.insert(space_name)


def thread_select():
    global is_running
    print('Start select thread')
    t = TarantoolClient(config.spaces)
    while is_running:
        for space_name in config.spaces:
            t.select(space_name)


def thread_insert_2():
    global is_running
    print('Start insert thread')
    t = TarantoolCartridgeClient(config.spaces)
    while is_running:
        time.sleep(0.001)
        t.insert()


def thread_select_2():
    global is_running
    print('Start select thread')
    t = TarantoolCartridgeClient(config.spaces)
    while is_running:
        time.sleep(0.001)
        t.select()


def thread_insert_3(store_connection):
    global is_running
    print('Start insert thread')
    t = TarantoolClient(config.spaces, store_connection)
    while is_running:
        time.sleep(0.001)
        t.insert_customer()


def thread_select_3(store_connection):
    global is_running
    print('Start select thread')
    t = TarantoolClient(config.spaces, store_connection)
    while is_running:
        time.sleep(0.001)
        t.select_customer()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--threads',
        type=int,
        default=10,
        help="threads amount"
    )
    parser.add_argument(
        '--store-connection',
        default=False,
        action='store_true'
    )
    args = parser.parse_args()
    threads = []

    for index in range(args.threads):

        if index > args.threads / 2:
            t = threading.Thread(target=thread_insert_3, args=(args.store_connection,))
        else:
            t = threading.Thread(target=thread_select_3, args=(args.store_connection,))
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
    main()
