# Run-cardano-node-on-docker
Assume that you have installed docker on Linux server (If you have not , google "how to install docker/docker-compose on Ubuntu/Centos")
You want to do lab at https://developers.cardano.org (Installing cardano-node , Installing cardano-wallet , Discover Native Tokens , etc...)

This document is a step-by-step guide to :
- Install cardano-node on docker (Preprod Testnet --testnet-magic 1)
- Connect cardano-cli / cardano-wallet from host to cardano-node container on same host

## Install cardano-node on docker
1. We'll be working in a new directory , create directory structure to store everything about cardano node:
```bash
|---/opt/cardano                        # Folder which holds everything
   |---docker-compose.yml               # docker-compose config
   |---cardano-node-data                # store immutable data , ledger , etc...
   |---cardano-node-ipc                 # store node socket file node.socket
   |---config                           # store network , topology and eras configs
   |---cardano-wallet			# cardano wallet binaries
```
2. Compile cardano wallet binaries your self or use downloaded latest pre-built binaries of cardano-wallet in this repo, please refer https://developers.cardano.org/docs/get-started/installing-cardano-wallet

3. Download configuration files or you can use mines , copy them to config folder , please refer https://developers.cardano.org/docs/get-started/running-cardano

4. Start/stop cardano node:
```bash
cd /opt/cardano
docker-compose -f docker-compose.yml up -d    # start node
docker-compose -f docker-compose.yml down     # stop node

docker ps -a # check result
CONTAINER ID   IMAGE                             COMMAND                  CREATED        STATUS       PORTS                                                                                      NAMES
b43766a12766   inputoutput/cardano-node:1.35.5   "entrypoint"             5 hours ago    Up 5 hours                                                                                              cardano-node
```

5. Access to your cardano-node container
```bash
# exec bash shell inside your container
docker exec -it your_node_name bash
bash-4.4# cardano-cli query tip --testnet-magic 1
{
    "era": "Alonzo",
    "syncProgress": "95.87",
    "hash": "87b389fe8e6157254d13eef09bdd13ac5b0995c0aea7ffbc1f2714c516d34eb6",
    "epoch": 214,
    "slot": 62502587,
    "block": 3680370
}
```

6. mint_token function only accept utxo as below format
```
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
```
