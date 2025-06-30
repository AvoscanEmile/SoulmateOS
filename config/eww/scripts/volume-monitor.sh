#!/bin/bash
# volume-monitor.sh

# Immediately output current volume
wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}' 
# Flush output explicitly
printf '\n' >&2  # This forces a flush

# Then continue with monitoring
# Your monitoring logic here

