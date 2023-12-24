check_cardano_env() {
  # Check if CARDANO_NODE_SOCKET_PATH existed
  if [ -z "$CARDANO_NODE_SOCKET_PATH" ]; then
    echo "CARDANO_NODE_SOCKET_PATH not found."
  fi

  # Check if CARDANO_CLI existed
  if [ -z "$CARDANO_CLI" ]; then
    echo "CARDANO_CLI not found."
  fi

  if [ -z "$CARDANO_NODE_SOCKET_PATH" ] || [ -z "$CARDANO_CLI" ]; then
    echo "cardano node socket and/or cardano-cli not found."
    echo "Please ensure that you run this script in the environment there is already cardano node and cardano-cli."
    export CARDANO_NODE_SOCKET_PATH=`pwd`"/cardano-node-ipc/node.socket"
    export CARDANO_CLI=`pwd`"/cardano-wallet/cardano-cli"
  fi
}
