send_token() {
    check_wallet_existence
    check_policy_existence
    address=$(cat tokens/payment.addr)

        # Get wallet utxo
        echo "Your wallet balance: "
        $CARDANO_CLI query utxo --address $address $NET
        selected_utxo=$($CARDANO_CLI query utxo --address $address $NET)
        policyid=$(cat tokens/policy/policyID)
        fee="0"
        output="0"
	receiver_output="2000000"

    echo "Please provide receiver address"
    read -p "Receiver Address: " receiver

        echo "Please provide information about token that you want to send"
        read -p "Token name: " tokenname

        # tokenname endcode base 16
        tokennameec16=$(echo -n "$tokenname" | xxd -ps | tr -d '\n')
        echo "tokenname in encode base 16: $tokennameec16"
        read -p "Amount of token: " tokenamount

	while true; do
	echo "Please pick TxHash , TxIx that you want to use to pay for minting tokens
	Caution: We are forced to send at least a minimum of 2 ada (2000000 Lovelace) to the foreign address, make sure the one you choose has at least 3000000 lovelaces (3 ADA)"
    	read -p "Insert your txhash here: " txhash
    	read -p "Insert your TxIx here: " txix

    	# Check txhash , TxIx value

        # Get funds
        rs2=$(awk -v th="$txhash" -v ix="$txix" '
        $1==th && $2==ix {
                print $3;
        }' <<<"$selected_utxo")
        funds=$rs2

        # Get tokenamount & tokenremain
    	rs1=$(awk -v th="$txhash" -v ix="$txix" '
        $1==th && $2==ix {
		if ($5 == "+" && $6 == "TxOutDatumNone") {
                print "The TxHash , TxIx you selected does not have enough lovelace or is invalid. Please re-select appropriate TxHash , TxIx or press CTRL+C to exit.";
            	}
		else if ($5 == "+" && $6 ~ /^[0-9]+$/ && ($7 != "'$policyid.$tokennameec16'" || $3 < 2000000)) {
                print "The TxHash , TxIx you selected does not have enough lovelace or is invalid. Please re-select appropriate TxHash , TxIx or press CTRL+C to exit.";
            	}
            	else if ($5 == "+" && $6 ~ /^[0-9]+$/ && $7 == "'$policyid.$tokennameec16'" && $3 >= 2000000) {
                print $6;
            	}
        }' <<<"$selected_utxo")

    	if echo "$rs1" | grep -q "The TxHash , TxIx you selected"; then
		echo "$rs1"
        	continue  # pick another TxHash & TxIx if invalid
    	elif [[ $rs1 =~ ^[0-9]+$ && $tokenamount -ge $rs1 ]]; then
        	tokenremain=0;
        	tokenamount=$rs1;
		break;
    	elif [[ $rs1 =~ ^[0-9]+$ && $tokenamount -lt $rs1 ]]; then
        	tokenremain=$(expr $rs1 - $tokenamount);
		break;
    	fi
	
	done

        # Start sending...
        echo "build raw transaction"
        $CARDANO_CLI transaction build-raw --fee $fee --tx-in $txhash#$txix --tx-out $receiver+$receiver_output+"$tokenamount $policyid.$tokennameec16" --tx-out $address+$output+"$tokenremain $policyid.$tokennameec16" --out-file tokens/rec_matx.raw
        echo "calculating fee"
	fee=$($CARDANO_CLI transaction calculate-min-fee --tx-body-file tokens/rec_matx.raw --tx-in-count 1 --tx-out-count 2 --witness-count 1 $NET --protocol-params-file tokens/protocol.json | cut -d " " -f1)
	echo "fee: $fee"
	echo "tokenremain: $tokenremain"
        output=$(expr $funds - $fee - $receiver_output)
	echo "lovelace remain: $output"
        echo "rebuild transaction"
        $CARDANO_CLI transaction build-raw --fee $fee --tx-in $txhash#$txix --tx-out $receiver+$receiver_output+"$tokenamount $policyid.$tokennameec16" --tx-out $address+$output+"$tokenremain $policyid.$tokennameec16" --out-file tokens/rec_matx.raw
        echo "sign transaction"
	$CARDANO_CLI transaction sign --signing-key-file tokens/payment.skey $NET --tx-body-file tokens/rec_matx.raw --out-file tokens/rec_matx.signed
        echo "submit transaction"
	$CARDANO_CLI transaction submit --tx-file tokens/rec_matx.signed $NET

        # check submit result
        submit_exit_code=$?
        if [ $submit_exit_code -eq 0 ]; then
            echo "Sent token successfully"
		# Displays wallet balance after minting tokens
        	sleep 10
        	echo "Wallet balance:"
        	$CARDANO_CLI query utxo --address $address $NET
            exit 0
        else
            echo "Error submitting transaction. Exit code: $submit_exit_code"
            exit $submit_exit_code
        fi
}

