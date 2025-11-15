#!/bin/bash

# Loop through 172.16.0.1 to 172.16.255.254
for i in {10..255}; do
  for j in {1..254}; do
    IP="172.16.$i.$j"
    ping -c 4 -W 1 $IP > /dev/null && echo "$IP is alive" &
  done
done

wait
