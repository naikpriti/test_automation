#!/bin/bash

CONFIG_FILE="./automation_scripts/command.json"

RESOURCE_GROUP=$(jq -r '.repositories[0].resource_group' "$CONFIG_FILE")
ACCOUNT_NAME=$(jq -r '.repositories[0].account_name' "$CONFIG_FILE")

# Get the current list of IP rules
CURRENT_IPS=$(az cognitiveservices account network-rule list --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --query "ipRules[].value" -o tsv)
echo "Current IP addresses: $CURRENT_IPS"

# Read IP addresses from the file into a set
declare -A NEW_IP_SET
while IFS= read -r IP; do
    IP=$(echo "$IP" | tr -d '"' | xargs)
    NEW_IP_SET["$IP"]=1
done < ip_addresses.txt

# Determine IPs to remove (present in CURRENT_IPS but not in NEW_IP_SET)
for IP in $CURRENT_IPS; do
    if [ -z "${NEW_IP_SET[$IP]}" ]; then
        echo "Removing IP: $IP"
        ERROR_OUTPUT=$(az cognitiveservices account network-rule remove --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --ip-address "$IP" 2>&1 > /dev/null)
        if [ $? -eq 0 ]; then
            echo "Successfully removed IP: $IP"
        else
            echo "Failed to remove IP: $IP"
            echo "Error: $ERROR_OUTPUT"
        fi
    fi
done

# Determine IPs to add (present in NEW_IP_SET but not in CURRENT_IPS)
for IP in "${!NEW_IP_SET[@]}"; do
    if ! echo "$CURRENT_IPS" | grep -q -w "$IP"; then
        echo "Adding IP: $IP"
        ERROR_OUTPUT=$(az cognitiveservices account network-rule add --resource-group "$RESOURCE_GROUP" --name "$ACCOUNT_NAME" --ip-address "$IP" 2>&1 > /dev/null)
        if [ $? -eq 0 ]; then
            echo "Successfully added IP: $IP"
        else
            echo "Failed to add IP: $IP"
            echo "Error: $ERROR_OUTPUT"
        fi
    fi
done