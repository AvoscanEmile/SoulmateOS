#!/usr/bin/env sh

bash ~/.config/polybar/scripts/change-config.sh
pkill polybar
polybar datetime &
polybar weather &
polybar groupsbar &
polybar volumebar &
polybar netbar &
pkill xfce4-clipman
xfce4-clipman &
xset s 1200 1200 
xset dpms 1200 1800 0

