#!/bin/bash

CONFIG_FILE="./automation_scripts/input.json"

RESOURCE_GROUP=$(jq -r '.repositories[0].resource_group' "$CONFIG_FILE")
ACCOUNT_NAME=$(jq -r '.repositories[0].account_name' "$CONFIG_FILE")

while IFS= read -r IP; do
    IP=$(echo "$IP" | tr -d '"' | xargs)
    echo "Adding IP: $IP"
    az cognitiveservices account network-rule add --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --ip-address "$IP" > /dev/null 2>&1
done < ip_addresses.txt