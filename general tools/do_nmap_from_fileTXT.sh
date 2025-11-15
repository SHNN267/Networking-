#!/bin/bash

# File with IPs
IP_FILE="ip.txt"

# Loop through each IP
while read -r ip; do
    echo "Scanning $ip for port 445 and OS detection..."
    sudo nmap -p 445 -O "$ip"
    echo "----------------------------------------"
done < "$IP_FILE"
