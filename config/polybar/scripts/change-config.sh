#!/bin/bash

# Function to read and export variables from a theme file
import_theme() {
  local theme_file="$1"
  
  # Check if file exists
  if [[ ! -f "$theme_file" ]]; then
    echo "Theme file not found: $theme_file" >&2
    return 1
  fi

  while IFS='=' read -r key value; do
    # Skip empty lines or comments
    [[ -z "$key" || "$key" =~ ^# ]] && continue

    # Trim whitespace around key and value (optional but good practice)
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    export "$key"="$value"
  done < "$theme_file"
}

import_theme ~/.config/soulmateos/themes/polybar_theme.ini || exit 1

cat > ~/.config/polybar/config.ini << EOF
[bar/datetime]
width = $DATETIME_BAR_WIDTH
offset-x = $DATETIME_OFFSET_X
offset-y = $OFFSET_Y
height = $HEIGHT
background = $BACKGROUND
foreground = $FOREGROUND
radius = $RADIUS
padding-left = $PADDING_LEFT
padding-right = $PADDING_RIGHT
modules-left = datetime
enable-click = true
override-redirect = true
font-0 = "$FONT"

[module/datetime]
type = internal/date
interval = 1
date = %Y/%m/%d%
time = %H:%M
format = <label>
label = %time% | %date%

[bar/weather]
override-redirect = true
width = $WEATHER_BAR_WIDTH
offset-x = $WEATHER_OFFSET_X
offset-y = $OFFSET_Y
height = $HEIGHT
background = $BACKGROUND
foreground = $FOREGROUND
radius = $RADIUS
padding-left = $PADDING_LEFT
padding-right = $PADDING_RIGHT
modules-left = weather
enable-click = true
font-0 = "$FONT"
font-1 = "$FONT_WEATHER"

[module/weather]
type = custom/script
exec = curl -s 'wttr.in/?format=%c%t' | sed -E 's/ ([+])?([0-9])/\2/'
interval = 600
format = <label>
label = %output%

[bar/groupsbar]
override-redirect = true
width = $GROUPS_BAR_WIDTH
offset-x = $(( $(xrandr | grep ' connected' | head -n1 | grep -oP '\d+x\d+' | cut -d'x' -f1) / 2 - $GROUPS_BAR_WIDTH / 2 ))
offset-y = $OFFSET_Y
height = $HEIGHT
background = $BACKGROUND
foreground = $FOREGROUND
radius = $RADIUS
padding-left = $PADDING_LEFT
padding-right = $PADDING_RIGHT
modules-center = groups
font-0 = "$FONT_CIRCLES"

[module/groups]
type = custom/script
exec = bash ~/.config/polybar/scripts/qtile-groups.sh
interval = 0
hook-0 = ~/.config/polybar/scripts/qtile-groups.sh
label = %output%
label-margin-left = 2

[bar/volumebar]
override-redirect = true
width = $VOLUME_BAR_WIDTH
offset-x = $(( $(xrandr | grep ' connected' | head -n1 | grep -oP '\d+x\d+' | cut -d'x' -f1) - $VOLUME_OFFSET_X ))
offset-y = $OFFSET_Y
height = $HEIGHT
background = $BACKGROUND
foreground = $FOREGROUND
radius = $RADIUS
padding-left = $PADDING_LEFT
padding-right = $PADDING_RIGHT
modules-center = volume
enable-click = true
click-left = eww open-many menu-closer volume
font-0 = "$FONT"
font-1 = "$FONT_VOLUME"

[module/volume]
type = custom/script
exec = bash ~/.config/polybar/scripts/volume.sh
interval = 0.1
label = %output%
label-margin-left = 5px

[bar/netbar]
override-redirect = true
width = $NETWORK_BAR_WIDTH
offset-x = $(( $(xrandr | grep ' connected' | head -n1 | grep -oP '\d+x\d+' | cut -d'x' -f1) - $NETWORK_OFFSET_X))
offset-y = $OFFSET_Y
height = $HEIGHT
background = $BACKGROUND
foreground = $FOREGROUND
radius = $RADIUS
padding-left = $PADDING_LEFT
padding-right = $PADDING_RIGHT
modules-center = network
enable-click = true
font-0 = "$FONT"
font-1 = "$FONT_NETWORK"

[module/network]
type = custom/script
exec = bash ~/.config/polybar/scripts/network.sh
tail = true
interval = 0.2
EOF
