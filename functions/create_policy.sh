create_policy() {
  mkdir -p tokens/policy
  address=$(cat tokens/payment.addr)

  $CARDANO_CLI query protocol-parameters $NET --out-file tokens/protocol.json
  $CARDANO_CLI address key-gen --verification-key-file tokens/policy/policy.vkey --signing-key-file tokens/policy/policy.skey
  echo "{" > tokens/policy/policy.script
  echo "  \"keyHash\": \"$($CARDANO_CLI address key-hash --payment-verification-key-file tokens/policy/policy.vkey)\"," >> tokens/policy/policy.script
  echo "  \"type\": \"sig\"" >> tokens/policy/policy.script
  echo "}" >> tokens/policy/policy.script
  $CARDANO_CLI transaction policyid --script-file tokens/policy/policy.script > tokens/policy/policyID
}
