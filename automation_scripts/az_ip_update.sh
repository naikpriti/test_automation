#!/bin/bash

CONFIG_FILE="./automation_scripts/input.json"

RESOURCE_GROUP=$(jq -r '.repositories[0].resource_group' "$CONFIG_FILE")
ACCOUNT_NAME=$(jq -r '.repositories[0].account_name' "$CONFIG_FILE")

# Get the current list of IP rules
CURRENT_IPS=$(az cognitiveservices account network-rule list --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --query "ipRules[].value" -o tsv)
echo "Current IP addresses: $CURRENT_IPS"

# Read IP addresses from the file and print each IP address
echo "IP addresses from ip_addresses.txt:"
cat ip_addresses.txt

# Read IP addresses from the file into a set
declare -A IP_SET
while IFS= read -r IP; do
    IP=$(echo "$IP" | tr -d '"' | xargs)
    IP_SET["$IP"]=1
done < ip_addresses.txt

# Determine IPs to add
NEW_IPS=()
for IP in "${!IP_SET[@]}"; do
    if ! echo "$CURRENT_IPS" | grep -q -w "$IP"; then
        NEW_IPS+=("$IP")
    fi
done

# Add new IP addresses
for IP in "${NEW_IPS[@]}"; do
    echo "Adding IP: $IP"
    az cognitiveservices account network-rule add --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --ip-address "$IP" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Successfully added IP: $IP"
    else
        echo "Failed to add IP: $IP"
    fi
done