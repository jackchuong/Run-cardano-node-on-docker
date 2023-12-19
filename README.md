# Run-cardano-node-on-docker
Assume that you have installed docker on Linux server (If you have not , google "how to install docker/docker-compose on Ubuntu/Centos")
You want to do lab at https://developers.cardano.org (Installing cardano-node , Installing cardano-wallet , Discover Native Tokens , etc...)

This document is a step-by-step guide to :
- Install cardano-node on docker (Mainnet --mainnet, USE WITH CAUTION!!!)
- Connect cardano-cli / cardano-wallet from host to cardano-node container on same host

## Install cardano-node on docker
1. We'll be working in a new directory , create directory structure to store everything about cardano node:
```bash
|---/opt/cardano                        # Folder which holds everything
   |---docker-compose.yml               # docker-compose config
   |---cardano-node-data                # store immutable data , ledger , etc...
   |---cardano-node-ipc                 # store node socket file node.socket
   |---configuration                    # store network , topology and eras configs
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

6. Mint new token function only accept utxo as below format
```
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
```
- TxHash , TxIx with existed token policyid.tokennameec16 will not be accepted , for ex:
```
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
30a9759a9cf020ac8c895d18a8b0ad9a051a4b35097494611301cf8cdf50bcee     0        9980569965 lovelace + 1000 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
```
- This is output when use script to mint new token
```
Choose the action you want:
1. Create new wallet
2. Mint new token
3. Mint more existing tokens
4. Send token to another wallet
5. Burn token
Press CTRL+C to exit
Enter the number corresponding to the action: 2
You have chosen: Mint new token
Your wallet balance:
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
25131ef9569210f13436689ed3bd685ff88de8cf55b3f02b29f51cc7abf7b970     0        9980751394 lovelace + TxOutDatumNone
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
Please provide information about token that you want to mint
Token name: bworks
tokenname in encode base 16: 62776f726b73
Amount of token: 1000
Please pick TxHash , TxIx that you want to use to pay for minting tokens, make sure the one you choose has at least 1000000 lovelaces
Insert your txhash here: 25131ef9569210f13436689ed3bd685ff88de8cf55b3f02b29f51cc7abf7b970
Insert your TxIx here: 0
You have selected TxHash , TxIx has enough lovelace balance: 9980751394 lovelace
build raw transtion
calculating fee
rebuild transaction
sign transaction
submit transaction
Transaction successfully submitted.
Minted token successfully
Wallet balance:
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
30a9759a9cf020ac8c895d18a8b0ad9a051a4b35097494611301cf8cdf50bcee     0        9980569965 lovelace + 1000 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
```
