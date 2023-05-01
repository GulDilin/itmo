import shutil
import os
import argparse

CLUSTER_CONFIG_DIR = os.path.abspath(
    os.path.join(
        os.path.join(os.path.abspath(__file__), os.pardir),
        'cluster-config',
    )
)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'path',
        type=str,
        help="cartridge project dir path"
    )
    args = parser.parse_args()
    print(f'{args.path=}')

    if not os.path.exists(args.path) or \
            not os.path.isdir(args.path) or \
            not os.path.exists(os.path.join(args.path, '.cartridge.yml')):
        raise ValueError('Incorrect cluster project path')

    shutil.copyfile(
        os.path.join(CLUSTER_CONFIG_DIR, 'init.lua'),
        os.path.join(args.path, 'init.lua'),
    )
    shutil.copyfile(
        os.path.join(CLUSTER_CONFIG_DIR, 'storage.lua'),
        os.path.join(args.path, 'app/roles/storage.lua'),
    )
    shutil.copyfile(
        os.path.join(CLUSTER_CONFIG_DIR, 'replicasets.yml'),
        os.path.join(args.path, 'replicasets.yml'),
    )


if __name__ == '__main__':
    main()
