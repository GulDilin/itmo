import tarantool
import config


def get_connection():
    print(f'{config.DB_HOST=} {config.DB_PORT=} {config.DB_USER=} {config.DB_PASS=}')
    return tarantool.connect(
        config.DB_HOST,
        config.DB_PORT,
        user=config.DB_USER,
        password=config.DB_PASS,
    )
