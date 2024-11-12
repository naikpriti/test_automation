#!/bin/bash

# Path to the JSON configuration file
CONFIG_FILE="./automation_scripts/input.json"

# Read resource group and account name from the JSON configuration file
RESOURCE_GROUP=$(jq -r '.repositories[0].resource_group' "$CONFIG_FILE")
ACCOUNT_NAME=$(jq -r '.repositories[0].account_name' "$CONFIG_FILE")

cat ip_addresses.txt

# Read IP addresses from the file and execute the Azure CLI command for each IP address
while IFS= read -r IP; do
    az cognitiveservices account network-rule add --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --ip-address "$IP"
done < ip_addresses.txt