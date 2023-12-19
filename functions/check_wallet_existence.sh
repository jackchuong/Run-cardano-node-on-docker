check_wallet_existence() {
  if [ ! -f "tokens/payment.addr" ] || [ ! -f "tokens/payment.skey" ] || [ ! -f "tokens/payment.vkey" ]; then
    echo "wallets not found, please create wallet or provide necessary wallet information if you already have a wallet. We need:
    		tokens/payment.addr - wallet's address
		tokens/payment.skey & tokens/payment.vkey - wallet's keys"
    echo "Wait 10 seconds or press CTRL+C to exit."
    sleep 10
    exit 1
  fi
}
