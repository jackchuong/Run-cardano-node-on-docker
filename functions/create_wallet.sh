create_wallet() {
    $CARDANO_CLI address key-gen --verification-key-file tokens/payment.vkey --signing-key-file tokens/payment.skey

    $CARDANO_CLI address build --payment-verification-key-file tokens/payment.vkey --out-file tokens/payment.addr $NET

    echo "Wallet has been created successfully! wallet's address $(cat tokens/payment.addr)"
}
