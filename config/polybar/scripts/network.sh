#!/usr/bin/env bash

# Interface name (change this to your Ethernet interface)
iface="enp2s0"

# Unicode icons for static display
ethernet_icon=$'\uf6ff'
up_icon=$'\uf0d8'      
down_icon=$'\uf0d7'    
separator_icon = $'\uf142'

# Function to calculate speeds
get_speed() {
    # Read bytes from sysfs
    rx1=$(cat /sys/class/net/$iface/statistics/rx_bytes)
    tx1=$(cat /sys/class/net/$iface/statistics/tx_bytes)
    
    sleep 0.3
    
    rx2=$(cat /sys/class/net/$iface/statistics/rx_bytes)
    tx2=$(cat /sys/class/net/$iface/statistics/tx_bytes)
    
    # Calculate byte differences
    rx_diff=$((rx2 - rx1))
    tx_diff=$((tx2 - tx1))
    
    # Convert bytes per 0.3s interval to kilobytes per second (KB/s)
    # Multiply by ~3.33 (1/0.3) then divide by 1024 to get KB/s
    rx_speed=$(awk "BEGIN {printf \"%.1f\", ($rx_diff / 0.3) / (1024 * 1024 * 8)}")
    tx_speed=$(awk "BEGIN {printf \"%.1f\", ($tx_diff / 0.3) / (1024 * 1024 * 8)}")
    
    echo "$ethernet_icon $up_icon ${tx_speed}MiB/s \ $down_icon ${rx_speed}MiB/s"
}

while true; do
    get_speed
done
