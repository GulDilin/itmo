
## Requirements
- Python 3.10
- Docker
- docker compose

## Install
1. Install cartridge
```shell
sudo apt-get update
sudo apt-get install -y unzip cmake make git gcc
sudo apt-get install cartridge-cli
```
1. Create cartridge project
```shell
cartridge create --name cluster
cd cluster
cartridge build
```

1. Create venv `python -m venv venv`
1. Activate `./venv/Scripts/activate` (for windows) or `./venv/bin/activate` (for linux)
1. Install requirements `python -m pip install -r requirements.txt`
1. Setup env file. Copy `.env.example` to `.env`. And change if you need
1. In project dir. Run `python init_config_cluster.py ~/cluster` to copy cartridge config
1. In cluster dir. Start cluster `cartridge start -d`
1. In cluster dir. Setup replicas `cartridge replicasets setup --bootstrap-vshard`
1. In cluster dir. Setup replicas `cartridge failover setup`
1. In project dir. Run `python load_data.py` to create spam threads
