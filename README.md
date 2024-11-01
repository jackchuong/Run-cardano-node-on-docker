# Run-cardano-node-on-docker
- Assume that you have installed docker on Linux server (If you have not , google "how to install docker/docker-compose on Ubuntu/Centos")
- You want to do lab at https://developers.cardano.org (Installing cardano-node , Installing cardano-wallet , Discover Native Tokens , etc...)

This document is a step-by-step guide to :
- Install cardano-node on docker (Pre-production NETWORK=preprod)
- Connect cardano-cli / cardano-wallet from host to cardano-node container on same host

## Install cardano-node on docker
1. We'll be working in a new directory , create directory structure to store everything about cardano node (or just clone my repo)
```bash
|---/opt/cardano                        # Folder which holds everything
   |---docker-compose.yml               # docker-compose config
   |---cardano-node-data                # store immutable data , ledger , etc...
   |---cardano-node-ipc                 # store node socket file node.socket
   |---configuration                    # store network , topology and eras configs
   |---cardano-wallet			# cardano wallet binaries
   |---tokens                   	# store payment address , policyID of token
```
2. Compile cardano wallet binaries your self or use downloaded latest pre-built binaries of cardano-wallet in this repo, please refer https://developers.cardano.org/docs/get-started/installing-cardano-wallet (ignore this step if you clone my repo)

3. Download configuration files or you can use mines , copy them to config folder , please refer https://developers.cardano.org/docs/get-started/running-cardano (ignore this step if you clone my repo)

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

Or use setenv.sh
source setenv.sh
$CARDANO_CLI query tip $NET
{
    "block": 2574131,
    "epoch": 160,
    "era": "Babbage",
    "hash": "e9dbd32ceafeca281f6ea7f501e5eb4c4794ba781ee02613f734dac9eeaac173",
    "slot": 67690344,
    "syncProgress": "100.00"
}
```

## Do lab with shell script
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
build transaction
Estimated transaction fee: 181253 Lovelace
sign transaction
submit transaction
Transaction successfully submitted.
Minted token successfully
Summited TxHash: xxx Date:
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
build transaction
Estimated transaction fee: 181209 Lovelace
sign transaction
submit transaction
Transaction successfully submitted.
Burned token successfully
Summited TxHash: xxx Date:
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
build transaction
Estimated transaction fee: 179361 Lovelace
sign transaction
submit transaction
Transaction successfully submitted.
Sent token successfully
Summited TxHash: xxx Date:
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
build transaction
Estimated transaction fee: 181253 Lovelace
sign transaction
submit transaction
Transaction successfully submitted.
Minted more token successfully
Summited TxHash: xxx Date: 
```

9. Send ADA and token to multi wallet
```
list.txt
cat list.txt
addr_test1vz6aay995sa8rdaajlzxlkcldjg9c5zxp7j298a8dhqchrgkasc0m 0 500
addr_test1vq88zrwjrqdrzpuv2vp4fxsx2r2skyxkkvlkrdvlyxs9w0gh92vyl 0 500
addr_test1vrp5gyf7tv895uns6gyfjh8f0w5r5j66s20y7n877v70hfsjm9n5q 0 500
...
```

```
./send_token_multi_addresses.sh list.txt bWorksApp 24d221b7079ea76d75855ed75bcab364747321c0c5180318c3356f2a1d93e2f1 1
raw_transaction is : /opt/preprod/Run-cardano-node-on-docker/cardano-wallet/cardano-cli-10.1.1 latest transaction build --tx-in 24d221b7079ea76d75855ed75bcab364747321c0c5180318c3356f2a1d93e2f1#1 --tx-out addr_test1vz6aay995sa8rdaajlzxlkcldjg9c5zxp7j298a8dhqchrgkasc0m+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vq88zrwjrqdrzpuv2vp4fxsx2r2skyxkkvlkrdvlyxs9w0gh92vyl+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vrp5gyf7tv895uns6gyfjh8f0w5r5j66s20y7n877v70hfsjm9n5q+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vrytgm4p7dckfpdjehpm3w263rsgh0tujtjue3eej5rh2lsczr8qs+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vz52h0cn9ua9vl8ak4yz4czas3sf3ftjy82a5tt7ladhufqyuk45c+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vrzxk63rul738v5uwhu0mwkxcmu5ywlakzg2wy0t4828lkqsnexwz+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vzzf58lunc938phx8mhdwzed6jhujakjm9akrdsmfv4jnjc4hjft6+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vpe5502tm9rvzvaltqykaqgfrmqkyxuklup0rtx5q44rzrg2zkgzr+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vqyc7c2pa76autwvt44nsn5gyyt4eg38ny4zfe5es0tyakck7ytz8+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vz4g97yw8new0llzvx0n5sk3dye4hh9gghy3wvya4rrwx3qwz25g6+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vqjycpfjxghycdg2544y40pfuwtskhg8dd63cey7sgm7fes7g0t2u+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vz6yyzuw447mneh8g5nltn29ayrch89s7p9jjszckk45ntcya6c00+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vqelmcyhjegpc9ayjnx0csy4u6l34zs45wnc935az4qqkgcw2v89q+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vp0j78pagqrmn2cygk9nff4lc26fkv7xves4n50llhg0tfq6jraq3+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vrvk39xu29tfhdq5rvne5jclef4pgmdtwsau8cz4x9kfvxs5sygha+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vrr26cgfs090fg08u2h76czn02enp8ech83lfdmhxp5ueac0elmpv+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vzvydh3y9ke9ukzya3vgn9xs7x5cnrkp6q6uwj636gftwlql0kyph+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vrlt32l3ezk8ar64x6n8qy99qcvsdf48fllhtyflyxtgvxgcgvmhp+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vpv7tdsq5z89zrzakc6us685ag74nmnkn4ycufkp49xta4q60dut2+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vp2rwxwggyw03u2tj5qvae8pc9w30xnhwkfp5jfczv927nshkxzw9+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vz2xeewrwvu0hycfkfafq7gd4gzyu80w4wztch8xjffu0ss8x73ng+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vq85rztacaukayeqfgdlvr9tye6hf75sl3v5nrx4vclylwq2d6kfn+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vpl38tpnhmrjld95klmja9hzvncjnlmth5ns5cuxwhe9q6ccy8d6v+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vq56gtsn87tf4gw20k67jdv47fpn6dlcatf0zp4v8ev8sfqs9sywd+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vz9qg27dy69xrwt9xey5xzmxt5x3t09ftq8uv3rjrgpsg6s0zyjwx+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vphjy837m8lpvg4mjpeegjuxlayjtgshc78r0wkt4jpdrsctuqam0+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vpsdx5xu2zvdfe7gy0scz8jdvsp2euc2tl8lhy47xjw7g3qw5r6jv+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vrqa0ztjskzqplh74yx3yln4hanqm5h8uzr4yqpnqtyuh8gst0nv9+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vqtpn7wcjja93wvp4lcyqea6yf7vu2w5t9xvgxg5tztxy8c2ydx2e+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --tx-out addr_test1vquqt4rcjujcffx28h2xn0wu722len3v4k3l25ctdrszlyq7ccv6v+2000000+"500 d7dcafac1919b7dbc6afa295c9ab793eeba55e927a6d94ace67a9067.62576f726b73417070" --change-address addr_test1vrkq5fk3ulkplsy5sd2h97peka0tu2g4mljjp6w8wl24eesm5fy8z --testnet-magic 1 --out-file tokens/rec_matx.raw
Estimated transaction fee: 280341 Lovelace
Transaction successfully submitted.
Sent token successfully
Summited TxHash: 730d5107d7d3cfe3d0b1058b410d5a437c0902b6c48d9ab0263dfdaaabb49efb Date: Fri Nov 1 10:41:17 AM +07 2024
```
