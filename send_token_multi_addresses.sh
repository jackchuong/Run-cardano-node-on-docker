#!/bin/bash

for file in ./functions/*; do
  if [ -f "$file" ] && [ "${file##*.}" == "sh" ]; then
    source "$file"
  fi
done

check_cardano_env

NET="--testnet-magic 1"

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <file_path> <token_name> <txhash> <txix>"
    exit 1
fi

file_path=$1
token_name=$2
txhash=$3
txix=$4

check_wallet_existence
check_policy_existence

address=$(cat tokens/payment.addr)
selected_utxo=$($CARDANO_CLI query utxo --address $address $NET)
policyid=$(cat tokens/policy/policyID)
fee="0"
receiver_output="2000000" # Fixed lovelace amount
tokennameec16=$(echo -n "$token_name" | xxd -ps | tr -d '\n')

# Get funds
funds=$(awk -v th="$txhash" -v ix="$txix" '
    $1==th && $2==ix {
        print $3;
    }' <<<"$selected_utxo")

token_amount=$(awk -v th="$txhash" -v ix="$txix" '
        $1==th && $2==ix {
                if ($5 == "+" && $6 == "TxOutDatumNone") {
                print "The TxHash , TxIx you selected is invalid.";
                }
                else if ($5 == "+" && $6 ~ /^[0-9]+$/ && $7 == "'$policyid.$tokennameec16'") {
                print $6;
                }
        }' <<<"$selected_utxo")

if echo "$token_amount" | grep -q "The TxHash , TxIx you selected"; then
        echo "$token_amount"
        exit 1  # exit program
fi

# Initialize raw transaction
raw_transaction="$CARDANO_CLI transaction build-raw --fee $fee --tx-in $txhash#$txix"

# Initialize total cost of lovelace and tokens
totalcostlovelace=0
totalcosttoken=0

# Generate tx_out for each line in the file
while IFS=" " read -r receiver lovelace tokenamt; do
    receiver_output_adjusted=$((receiver_output + lovelace))
    raw_transaction+=" --tx-out $receiver+$receiver_output_adjusted+\"$tokenamt $policyid.$tokennameec16\""
    totalcostlovelace=$((totalcostlovelace + receiver_output_adjusted))
    totalcosttoken=$((totalcosttoken + tokenamt))
done < "$file_path"

# Calculate remaining tokens and output balance
tokenremain=$((token_amount - totalcosttoken))
output=$((funds - fee - totalcostlovelace))

# Add change output to the raw transaction
raw_transaction+=" --tx-out $address+$output+\"$tokenremain $policyid.$tokennameec16\" --out-file tokens/rec_matx.raw"

echo "raw_transaction is : $raw_transaction"
eval $raw_transaction

# Calculate fee
fee=$($CARDANO_CLI transaction calculate-min-fee --tx-body-file tokens/rec_matx.raw --tx-in-count 1 --tx-out-count $(($(wc -l < "$file_path")+1)) --witness-count 1 $NET --protocol-params-file tokens/protocol.json | cut -d " " -f1)

# Update output balance after fee deduction
output=$((funds - fee - totalcostlovelace))

# Rebuild transaction with updated fee and output balance
raw_transaction="$CARDANO_CLI transaction build-raw --fee $fee --tx-in $txhash#$txix"

# Rebuild tx_outs
while IFS=" " read -r receiver lovelace tokenamt; do
    receiver_output_adjusted=$((receiver_output + lovelace))
    raw_transaction+=" --tx-out $receiver+$receiver_output_adjusted+\"$tokenamt $policyid.$tokennameec16\""
done < "$file_path"

# Add change output
raw_transaction+=" --tx-out $address+$output+\"$tokenremain $policyid.$tokennameec16\" --out-file tokens/rec_matx.raw"

echo "Rebuilt raw_transaction is : $raw_transaction"
eval $raw_transaction

# Sign transaction
$CARDANO_CLI transaction sign --signing-key-file tokens/payment.skey $NET --tx-body-file tokens/rec_matx.raw --out-file tokens/rec_matx.signed

# Submit transaction
$CARDANO_CLI transaction submit --tx-file tokens/rec_matx.signed $NET

# Check submit result
submit_exit_code=$?
if [ $submit_exit_code -eq 0 ]; then
    echo "Sent token successfully"
    # Display wallet balance after minting tokens
    sleep 10
    echo "Wallet balance:"
    $CARDANO_CLI query utxo --address $address $NET
    exit 0
else
    echo "Error submitting transaction. Exit code: $submit_exit_code"
    exit $submit_exit_code
fi

