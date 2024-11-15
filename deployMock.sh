#!/bin/bash

# Error handling: check for required arguments
if [ -z "$1" ]; then
    echo "Error: RPC URL is required."
    echo "Usage: $0 <rpc-url> <verifier-url>"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Error: Verifier URL is required."
    echo "Usage: $0 <rpc-url> <verifier-url>"
    exit 1
fi

# Assign arguments to variables
RPC_URL=$1
VERIFIER_URL=$2
IS_LEGACY=${3:-false}

# Display the configuration being used
echo "RPC URL: $RPC_URL"
echo "Verifier URL: $VERIFIER_URL"
echo "Is Legacy: $IS_LEGACY"

# Clear cache
rm -rf cache

COMMAND="forge script script/DeployMock.s.sol:DeployMock \
    --broadcast \
    --rpc-url \"$RPC_URL\" \
    --verify \
    --verifier blockscout \
    --verifier-url \"$VERIFIER_URL/api/\""

# Add --legacy if IS_LEGACY is true
if [ "$IS_LEGACY" = "true" ]; then
    COMMAND="$COMMAND --legacy"
fi

# Execute constructed command
eval $COMMAND


# Examples
# ./deployMock.sh base-sepolia https://base-sepolia.blockscout.com
# ./deployMock.sh world-sepolia https://worldchain-sepolia.explorer.alchemy.com
# ./deployMock.sh mantle-sepolia https://explorer.sepolia.mantle.xyz
# ./deployMock.sh polygonzkevm-cardona https://explorer-ui.cardona.zkevm-rpc.com true

# Hedera Testnet
# forge script script/DeployMock.s.sol:DeployMock \
#     --broadcast \
#     --rpc-url hedera-testnet