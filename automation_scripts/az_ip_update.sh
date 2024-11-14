#!/bin/bash

CONFIG_FILE="./automation_scripts/command.json"

RESOURCE_GROUP=$(jq -r '.repositories[0].resource_group' "$CONFIG_FILE")
ACCOUNT_NAME=$(jq -r '.repositories[0].account_name' "$CONFIG_FILE")

# Get the current list of IP rules
CURRENT_IPS=$(az cognitiveservices account network-rule list --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --query "ipRules[].value" -o tsv)
echo "Current IP addresses: $CURRENT_IPS"

# Remove all existing IP rules
for IP in $CURRENT_IPS; do
    echo "Removing IP: $IP"
    az cognitiveservices account network-rule remove --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --ip-address "$IP" 
    if [ $? -eq 0 ]; then
        echo "Successfully removed IP: $IP"
    else
        echo "Failed to remove IP: $IP"
    fi
done

# Read IP addresses from the file and print each IP address
echo "IP addresses from ip_addresses.txt:"
cat ip_addresses.txt

# Add new IP addresses
while IFS= read -r IP; do
    IP=$(echo "$IP" | tr -d '"' | xargs)
    echo "Adding IP: $IP"
    az cognitiveservices account network-rule add --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --ip-address "$IP" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Successfully added IP: $IP"
    else
        echo "Failed to add IP: $IP"
    fi
done < ip_addresses.txt
