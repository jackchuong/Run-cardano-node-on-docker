#!/bin/bash

create_wallet() {
    tmp_dir=$(mktemp -d)

    $CARDANO_CLI address key-gen \
        --verification-key-file "$tmp_dir/payment.vkey" \
        --signing-key-file "$tmp_dir/payment.skey"
    
    $CARDANO_CLI address build \
        --payment-verification-key-file "$tmp_dir/payment.vkey" \
        --out-file "$tmp_dir/payment.addr" \
        $NET
    
    address=$(cat "$tmp_dir/payment.addr")
    echo "$address 0 500" >> list.txt
    
    echo "Wallet created with address: $address"
}

create_multiple_wallets() {
    if [ -z "$1" ] || [ "$1" -lt 1 ]; then
        echo "Usage: $0 <number_of_wallets>"
        exit 1
    fi
    
    for (( i=1; i<=$1; i++ ))
    do
        create_wallet
    done
}

create_multiple_wallets "$1"

