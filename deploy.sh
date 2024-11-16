#!/bin/bash

# Predefined configurations
CONFIGS=(
    "base-sepolia|https://base-sepolia.blockscout.com"
    "mantle-sepolia|https://explorer.sepolia.mantle.xyz"
)

# Function to display usage
usage() {
    echo "Usage: $0 [file-name] [option-number]"
    echo "Arguments:"
    echo "  file-name: (Optional) Name of the script file (default: Deploy)"
    echo "  option-number: (Optional) Select a configuration from the list below (default: 0):"
    echo "    0: Deploy to all chains"
    for i in "${!CONFIGS[@]}"; do
        RPC_URL=$(echo "${CONFIGS[$i]}" | cut -d'|' -f1)
        VERIFIER_URL=$(echo "${CONFIGS[$i]}" | cut -d'|' -f2)
        echo "    $((i + 1)): RPC_URL=$RPC_URL, VERIFIER_URL=$VERIFIER_URL"
    done
    exit 1
}

# Set default values
FILE_NAME=${1:-Deploy}
OPTION=${2:-0}


deploy_to_chain() {
    local rpc_url=$1
    local verifier_url=$2
    echo "Deploying to:"
    echo "  RPC URL: $rpc_url"
    echo "  Verifier URL: $verifier_url"

    rm -rf cache

    # Execute the deployment command
    forge script script/${FILE_NAME}.s.sol:${FILE_NAME} \
        --broadcast \
        --rpc-url "$rpc_url" \
        --verify \
        --verifier blockscout \
        --verifier-url "$verifier_url/api/"
}

# Validate the option number
if ! [[ "$OPTION" =~ ^[0-9]+$ ]] || [ "$OPTION" -lt 0 ] || [ "$OPTION" -gt "${#CONFIGS[@]}" ]; then
    echo "Error: Invalid option number."
    usage
fi

# Deploy to all chains if option is 0
if [ "$OPTION" -eq 0 ]; then
    for CONFIG in "${CONFIGS[@]}"; do
        RPC_URL=$(echo "$CONFIG" | cut -d'|' -f1)
        VERIFIER_URL=$(echo "$CONFIG" | cut -d'|' -f2)
        deploy_to_chain "$RPC_URL" "$VERIFIER_URL"
    done
else
    # Deploy to the selected chain
    SELECTED_CONFIG="${CONFIGS[$((OPTION - 1))]}"
    RPC_URL=$(echo "$SELECTED_CONFIG" | cut -d'|' -f1)
    VERIFIER_URL=$(echo "$SELECTED_CONFIG" | cut -d'|' -f2)
    deploy_to_chain "$RPC_URL" "$VERIFIER_URL"
fi



# Usage
# All: ./deploy.sh <file-name> 0
# Base Sepolia: ./deploy.sh <file-name> 1
# Mantle Sepolia: ./deploy.sh <file-name> 2

