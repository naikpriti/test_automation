#!/bin/bash

# Path to the JSON configuration file
CONFIG_FILE="../input.json"

# Read resource group and account name from the JSON configuration file
RESOURCE_GROUP=$(jq -r '.repositories[0].resource_group' "$CONFIG_FILE")
ACCOUNT_NAME=$(jq -r '.repositories[0].account_name' "$CONFIG_FILE")

# Read IP addresses from the file
IP_ADDRESSES=$(cat ip_addresses.txt)

# Loop through each IP address and execute the Azure CLI command
for IP in $IP_ADDRESSES; do
    az cognitiveservices account network-rule add --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --ip-address "$IP"
done