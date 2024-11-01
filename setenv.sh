#!/bin/bash

export NET="--testnet-magic 1"
export CARDANO_NODE_SOCKET_PATH=`pwd`"/cardano-node-ipc/node.socket"
export CARDANO_CLI=`pwd`"/cardano-wallet/cardano-cli"
#export CARDANO_CLI=`pwd`"/cardano-wallet/cardano-cli-9.1.0"
#export CARDANO_CLI=`pwd`"/cardano-wallet/cardano-cli-10.1.1"
export address="addr_test1vrkq5fk3ulkplsy5sd2h97peka0tu2g4mljjp6w8wl24eesm5fy8z"
#export TESTNET_MAGIC_NUM=1
#export TESTNET_MAGIC=1
