#!/usr/bin/env sh

xsetroot -xcf /home/emile/.local/share/icons/Layan-white-cursors/cursors/left_ptr 24
bash ~/.config/soulmateos/config/scripts/change-themes.sh
bash ~/.config/polybar/scripts/change-config.sh
pkill picom
nixGL picom &
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

