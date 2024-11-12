#!/bin/bash

CONFIG_FILE="./automation_scripts/input.json"

RESOURCE_GROUP=$(jq -r '.repositories[0].resource_group' "$CONFIG_FILE")
ACCOUNT_NAME=$(jq -r '.repositories[0].account_name' "$CONFIG_FILE")

# Get the current list of IP rules
CURRENT_IPS=$(az cognitiveservices account network-rule list --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --query "ipRules[].value" -o tsv)

# Read IP addresses from the file and add only new IP addresses
while IFS= read -r IP; do
    IP=$(echo "$IP" | tr -d '"' | xargs)
    if ! echo "$CURRENT_IPS" | grep -q "$IP"; then
        az cognitiveservices account network-rule add --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --ip-address "$IP" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Successfully added IP: $IP"
        else
            echo "Failed to add IP: $IP"
        fi
    else
        echo "IP already exists: $IP"
    fi
done < ip_addresses.txt