#!/bin/bash

for file in ./functions/*; do
  if [ -f "$file" ] && [ "${file##*.}" == "sh" ]; then
    source "$file"
  fi
done


check_cardano_env

NET="--testnet-magic 1"

# List actions
while true; do
  echo "Choose the action you want:"
  echo "1. Create new wallet"
  echo "2. Mint new token"
  echo "3. Mint more existing tokens"
  echo "4. Send token to another wallet"
  echo "5. Burn token"
  echo "Press CTRL+C to exit"

  read -p "Enter the number corresponding to the action: " action

  if [[ "$action" =~ ^[1-5]$ ]]; then
    break
  else
    echo "Please enter a number between 1 and 5."
  fi
done

case $action in
  1)
    echo "You have chosen: Create new wallet"
    create_wallet
    ;;
  2)
    	echo "You have chosen: Mint new token"
	mint_token
    ;;
  3)
    echo "You have chosen: Mint more existing tokens"
    mint_more_token
    ;;
  4)
    echo "You have chosen: Send token to another wallet"
    send_token
    ;;
  5)
    echo "You have chosen: Burn token"
    burn_token
    ;;
esac
