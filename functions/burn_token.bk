burn_token() {
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

        echo "Please provide information about token that you want to burn"
        read -p "Token name: " tokenname

        # tokenname endcode base 16
        tokennameec16=$(echo -n "$tokenname" | xxd -ps | tr -d '\n')
        echo "tokenname in encode base 16: $tokennameec16"
        read -p "Amount of token: " tokenamount

	while true; do
    	echo "Please pick TxHash , TxIx that you want to use to pay for minting tokens, make sure the one you choose has at least 1000000 lovelaces"
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
    		else if ($5 == "+" && $6 ~ /^[0-9]+$/ && ($7 != "'$policyid.$tokennameec16'" || $3 < 1000000)) {
                print "The TxHash , TxIx you selected does not have enough lovelace or is invalid. Please re-select appropriate TxHash , TxIx or press CTRL+C to exit.";
            	}
            	else if ($5 == "+" && $6 ~ /^[0-9]+$/ && $7 == "'$policyid.$tokennameec16'" && $3 >= 1000000) {
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

        # Start burning...
        echo "build raw transaction"
        $CARDANO_CLI transaction build-raw --fee $fee --tx-in $txhash#$txix --tx-out $address+$output+"$tokenremain $policyid.$tokennameec16"  --mint="-$tokenamount $policyid.$tokennameec16" --minting-script-file tokens/policy/policy.script --out-file tokens/burning.raw
        echo "calculating fee"
        fee=$($CARDANO_CLI transaction calculate-min-fee --tx-body-file tokens/burning.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 $NET --protocol-params-file tokens/protocol.json | cut -d " " -f1)
	echo "fee: $fee"
	echo "tokenremain: $tokenremain"
        output=$(expr $funds - $fee)
	echo "lovelace remain: $output"
        echo "rebuild transaction"
        $CARDANO_CLI transaction build-raw --fee $fee --tx-in $txhash#$txix --tx-out $address+$output+"$tokenremain $policyid.$tokennameec16"  --mint="-$tokenamount $policyid.$tokennameec16" --minting-script-file tokens/policy/policy.script --out-file tokens/burning.raw
        echo "sign transaction"
        $CARDANO_CLI transaction sign --signing-key-file tokens/payment.skey --signing-key-file tokens/policy/policy.skey $NET --tx-body-file tokens/burning.raw --out-file tokens/burning.signed
        echo "submit transaction"
        $CARDANO_CLI transaction submit --tx-file tokens/burning.signed $NET

        # check submit result
        submit_exit_code=$?
        if [ $submit_exit_code -eq 0 ]; then
            	echo "Burned token successfully"
		sleep 10
        	echo "Wallet balance::"
        	$CARDANO_CLI query utxo --address $address $NET
		exit 0
        else
            echo "Error submitting transaction. Exit code: $submit_exit_code"
            exit $submit_exit_code
        fi
}

