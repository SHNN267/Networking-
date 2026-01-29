#!/bin/bash

echo "==== Active IP Scanner (Ping Sweep) ===="
echo

read -p "Enter number of network octets (1, 2, or 3): " OCTETS
read -p "Enter base network (example 192.168.1.0): " NETWORK

echo
echo "[*] Scanning... please wait ⏳"
echo

IFS='.' read -r O1 O2 O3 O4 <<< "$NETWORK"

ping_host () {
    ip=$1
    ping -c 1 -W 1 $ip > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "[+] Host Alive: $ip"
    fi
}

# 🔹 Case 1: Only last octet changes ( /24 )
if [ "$OCTETS" -eq 1 ]; then
    for i in {0..255}; do
        ip="$O1.$O2.$O3.$i"
        ping_host $ip &
        sleep 0.01
    done

# 🔹 Case 2: Last two octets change ( /16 style inside class B )
elif [ "$OCTETS" -eq 2 ]; then
    for i in {0..255}; do
        for j in {0..255}; do
            ip="$O1.$O2.$i.$j"
            ping_host $ip &
            sleep 0.01
        done
    done

# 🔹 Case 3: Last three octets change ( big scan like 10.0.0.0/8 )
elif [ "$OCTETS" -eq 3 ]; then
    for i in {0..255}; do
        for j in {0..255}; do
            for k in {0..255}; do
                ip="$O1.$i.$j.$k"
                ping_host $ip &
                sleep 0.005
            done
        done
    done

else
    echo "❌ Invalid number. Choose 1, 2, or 3."
    exit 1
fi

wait
echo
echo "==== Scan Finished ===="
