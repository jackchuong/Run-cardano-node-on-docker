check_policy_existence() {
    if [ ! -d "tokens/policy" ]; then
        echo "folder tokens/policy not existed, creating..."
        create_policy
    fi
}
