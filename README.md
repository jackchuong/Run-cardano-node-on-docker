# Run-cardano-node-on-docker
Assume that you have installed docker on Linux server (If you have not , google "how to install docker/docker-compose on Ubuntu/Centos")
You want to do lab at https://developers.cardano.org (Installing cardano-node , Installing cardano-wallet , Discover Native Tokens , etc...)

This document is a step-by-step guide to :
- Install cardano-node on docker
- Connect cardano-cli / cardano-wallet from host to cardano-node container on same host

I. Install cardano-node on docker
1. We'll be working in a new directory , create directory structure to store everything about cardano node:
```bash
|---/opt/cardano                        # Folder which holds everything
   |---docker-compose.yml               # docker-compose config
   |---cardano-node-data                # store immutable data , ledger , etc...
   |---cardano-node-ipc                 # store node socket file node.socket
   |---config                           # store network , topology and eras configs
   |---note                             # store environment variables file - for convinence later
```
2. Create/Edit docker-compose.yml:
```bash
version: '3.1'

networks:
  net:
    driver: bridge

services:
  cardano-node:
    image: inputoutput/cardano-node
    volumes:
      - ./cardano-node-ipc:/ipc
      - ./cardano-node-data:/data
      - ./note:/note
      - ./config:/config
    environment:
      - TZ=yourtimezone
      - NETWORK=testnet
      - CARDANO_NODE_SOCKET_PATH=/ipc/node.socket
    networks:
      - net
    ports:
      - "3001:3001"
    expose:
      - 3001
    restart: unless-stopped
```    
3. Download configuration files: you can them from https://hydra.iohk.io
```bash
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-config.json
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-shelley-genesis.json
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-byron-genesis.json
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-topology.json
```
4. Create file note/variables.sh
```bash
#!/bin/bash
export CARDANO_NODE_SOCKET_PATH="/ipc/node.socket"
export testnet="--testnet-magic 1097911063"
```
5. Start/stop cardano node:
```bash
cd /opt/cardano
docker-compose up -d    # start container
docker-compose down     # stop container

docker ps -a # check result
CONTAINER ID   IMAGE                             COMMAND                  CREATED        STATUS                 PORTS                                   NAMES
6f84b2672dec   inputoutput/cardano-node:1.33.0   "entrypoint"             2 days ago     Up 2 days              0.0.0.0:3001->3001/tcp                  cardano_cardano-node_1
```

II. Connect cardano-cli / cardano-wallet from host to cardano-node container
1. You can download the latest pre-built binaries of cardano-cli/cardano-wallet (for Linux in my case) from the link https://hydra.iohk.io/job/Cardano/cardano-wallet/cardano-wallet-linux64/latest

Place it wherever you want
```bash
cd $yourPATH
wget https://hydra.iohk.io/build/11949441/download/1/cardano-wallet-v2022-01-18-linux64.tar.gz
tar xzf cardano-wallet-v2022-01-18-linux64.tar.gz
mv cardano-wallet-v2022-01-18-linux64 cardano-wallet
cd cardano-wallet
ls
auto-completion  bech32  cardano-address  cardano-cli  cardano-node  cardano-wallet
```

2. Prepair environment variables
- Create variables.sh at your home directory ~
```bash
#!/bin/bash
export CARDANO_NODE_SOCKET_PATH=/opt/cardano/cardano-node-ipc/node.socket
export testnet="--testnet-magic 1097911063"
export PATH=$yourPATH/cardano-wallet:$PATH
```
- Export variables each time you ssh to server or append your ~/.bashrc and ~/.bash_profile
```bash
source ~/variables.sh
```

Check if environment variables are exported
```bash
export
declare -x CARDANO_NODE_SOCKET_PATH="/opt/cardano/cardano-node-ipc/node.socket"
declare -x testnet="--testnet-magic 1097911063"
declare -x PATH="$yourPATH/cardano-wallet:/sbin:/bin:/usr/sbin:/usr/bin"
```

Now you can test connect cardano-cli to your cardano node running on docker on same host
```bash
cardano-cli query tip $testnet
{
    "era": "Alonzo",
    "epoch": 214,
    "hash": "87b389fe8e6157254d13eef09bdd13ac5b0995c0aea7ffbc1f2714c516d34eb6",
    "block": 3680370,
    "slot": 62502587,
    "syncProgress": "95.87"
}
```
