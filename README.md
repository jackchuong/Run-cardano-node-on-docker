# Run-cardano-node-on-docker
Assume that you have installed docker on Linux server (If you have not , google "how to install docker/docker-compose on Ubuntu/Centos")
You want to do lab at https://developers.cardano.org (Installing cardano-node , Installing cardano-wallet , Discover Native Tokens , etc...)

This document is a step-by-step guide to :
- Install cardano-node on docker
- Connect cardano-cli / cardano-wallet from host to cardano-node container on same host

I. Install cardano-node on docker
1. We'll be working in a new directory , create directory structure to store everything about cardano node:
├── /opt/cardano                        # Folder which holds everything
   ├── docker-compose.yml               # docker-compose config
   ├── cardano-node-data                # store immutable data , ledger
   ├── cardano-node-ipc                 # store node socket file
   ├── config                           # store network , topology and eras configs
   └── note                             # store environment variables file - for convinence

2. Create/Edit docker-compose.yml:
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
    
3. Download configuration files: you can them from https://hydra.iohk.io
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-config.json
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-shelley-genesis.json
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-byron-genesis.json
wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-topology.json

4. Create file note/variables.sh
#!/bin/bash
export CARDANO_NODE_SOCKET_PATH="/ipc/node.socket"
export testnet="--testnet-magic 1097911063"

5. Start/stop cardano node:
cd /opt/cardano
docker-compose up -d
docker-compose down
