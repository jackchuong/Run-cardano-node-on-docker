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

7. Burn token & send token to other address functions only accept utxo as below format
```
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
30a9759a9cf020ac8c895d18a8b0ad9a051a4b35097494611301cf8cdf50bcee     0        9980569965 lovelace + 1000 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
```
- TxHash , TxIx without existed token policyid.tokennameec16 will not be accepted , for ex:
```
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
ba56c327d66b6da1d8e27628532533891ae59170f9dfd611c95aed410bdb6328     0        9980390604 lovelace + TxOutDatumNone
```
- This is output when use script to burn token
```
Choose the action you want:
1. Create new wallet
2. Mint new token
3. Mint more existing tokens
4. Send token to another wallet
5. Burn token
Press CTRL+C to exit
Enter the number corresponding to the action: 5
You have chosen: Burn token
Your wallet balance:
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
2ab313a6cd9382f89b3b489859cb55d1c95ebbfb14f8f5b93cecb8c102ba5926     0        9980209175 lovelace + 1000 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
Please provide information about token that you want to burn
Token name: bworks
tokenname in encode base 16: 62776f726b73
Amount of token: 100
Please pick TxHash , TxIx that you want to use to pay for minting tokens, make sure the one you choose has at least 1000000 lovelaces
Insert your txhash here: 2ab313a6cd9382f89b3b489859cb55d1c95ebbfb14f8f5b93cecb8c102ba5926
Insert your TxIx here: 0
build raw transaction
calculating fee
fee: 181209
tokenremain: 900
lovelace remain: 9980027966
rebuild transaction
sign transaction
submit transaction
Transaction successfully submitted.
Burned token successfully
Wallet balance::
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
10eb88f4b23d002b09b7ab1b063ef9ef1b21360c0b3d009af3bd9aeff54c313b     0        9980027966 lovelace + 900 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
```
NOTE: If the amount of token you entered >= remain token in UTXO , it will burn or send all remain tokens

- This is output when use script to send token to other wallet:
```
Choose the action you want:
1. Create new wallet
2. Mint new token
3. Mint more existing tokens
4. Send token to another wallet
5. Burn token
Press CTRL+C to exit
Enter the number corresponding to the action: 4
You have chosen: Send token to another wallet
Your wallet balance:
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
10eb88f4b23d002b09b7ab1b063ef9ef1b21360c0b3d009af3bd9aeff54c313b     0        9980027966 lovelace + 900 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
Please provide receiver address
Receiver Address: addr_test1qqr585tvlc7ylnqvz8pyqwauzrdu0mxag3m7q56grgmgu7sxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknswgndm3
Please provide information about token that you want to send
Token name: bworks
tokenname in encode base 16: 62776f726b73
Amount of token: 500
Please pick TxHash , TxIx that you want to use to pay for minting tokens
        Caution: We are forced to send at least a minimum of 2 ada (2000000 Lovelace) to the foreign address, make sure the one you choose has at least 3000000 lovelaces (3 ADA)
Insert your txhash here: 10eb88f4b23d002b09b7ab1b063ef9ef1b21360c0b3d009af3bd9aeff54c313b
Insert your TxIx here: 0
build raw transaction
calculating fee
fee: 179361
tokenremain: 400
lovelace remain: 9977848605
rebuild transaction
sign transaction
submit transaction
Transaction successfully submitted.
Sent token successfully
Wallet balance:
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
67bba5bab9405d1417d7b9c5efb53eb2f2ec20a2aaaf3fef355b48884fc16a0d     1        9977848605 lovelace + 400 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
```

8. Mint more token function only accept utxo as below format
```
Your wallet balance:
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
67bba5bab9405d1417d7b9c5efb53eb2f2ec20a2aaaf3fef355b48884fc16a0d     1        9977848605 lovelace + 400 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
```
- TxHash , TxIx without existed token policyid.tokennameec16 will not be accepted , for ex:
```
Your wallet balance:
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
```
- This is output when use script to mint more token
```
Choose the action you want:
1. Create new wallet
2. Mint new token
3. Mint more existing tokens
4. Send token to another wallet
5. Burn token
Press CTRL+C to exit
Enter the number corresponding to the action: 3
You have chosen: Mint more existing tokens
Your wallet balance:
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
67bba5bab9405d1417d7b9c5efb53eb2f2ec20a2aaaf3fef355b48884fc16a0d     1        9977848605 lovelace + 400 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
Please provide information about token that you want to mint
Token name: bworks
tokenname in encode base 16: 62776f726b73
Amount of token: 2000
Please pick TxHash , TxIx that you want to use to pay for minting tokens, make sure the one you choose has at least 1000000 lovelaces
Insert your txhash here: 67bba5bab9405d1417d7b9c5efb53eb2f2ec20a2aaaf3fef355b48884fc16a0d
Insert your TxIx here: 1
build raw transaction
calculating fee
fee: 181253
Amount of token after minting more: 2400
lovelace remain: 9977667352
rebuild transaction
sign transaction
submit transaction
Transaction successfully submitted.
Minted more token successfully
Wallet balance::
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
ca4e391cef69af129426fd896f4669ff82d6df2ad922844ba31cff0a1ba19370     0        9977667352 lovelace + 2400 39a863a56e0aef381749e08c5903b46da65bfcc1730e4b839905ff98.62776f726b73 + TxOutDatumNone
f3f548266c71a95d379c7afd557b62821da93f01d2044df0f12cdc02c0e94821     0        10000000000 lovelace + TxOutDatumNone
```

