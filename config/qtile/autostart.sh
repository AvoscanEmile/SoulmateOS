#!/usr/bin/env sh

bash ~/.config/polybar/scripts/change-config.sh
pkill polybar
polybar datetime &
polybar weather &
polybar groupsbar &
polybar volumebar &
polybar netbar &
pkill eww
eww daemon &
CURRENT_VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
eww update volume="$CURRENT_VOL"
pkill xfce4-clipman
xfce4-clipman &
xset s 1200 1200
xset dpms 1200 1800 0
