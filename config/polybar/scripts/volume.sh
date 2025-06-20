#!/usr/bin/env bash

# Get volume as integer 0–100
vol=$(wpctl get-volume @DEFAULT_SINK@ \
      | awk '{print int($2 * 100)}')

# Get mute state ("yes" or "no")
mute=$(wpctl get-mute @DEFAULT_SINK@ \
       | awk '{print $2}')

# Select icon
if [[ "$mute" == "yes" || "$vol" -eq 0 ]]; then
  icon=$'\uf026'   # muted
elif (( vol < 34 )); then
  icon=$'\uf027'    # low volume
elif (( vol < 67 )); then
  icon=$'\uf027' # mid volume, still the same icon
else
  icon=$'\uf028'    # high volume
fi

# Output: ICON PERCENTAGE%
printf "%s %d%%" "$icon" "$vol"
