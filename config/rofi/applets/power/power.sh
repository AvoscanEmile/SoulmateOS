#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Applets : Power Menu

# Import Current Theme
theme="$HOME/.config/rofi/applets/power/theme.rasi"

# Theme Elements
prompt="`hostname`"
mesg="Uptime : `uptime -p | sed -e 's/up //g'`"

# Directly define options as you've chosen to always show icons and text
option_1=$(echo -e "\uF705 Logout") # Changed
option_2=$(echo -e "\uF2DC Suspend") # Changed
option_3=$(echo -e "\uF46A Reboot")  # Changed
option_4=$(echo -e "\u23FB Shutdown") # Changed
yes=$(echo -e "\u2713 Yes")          # Changed
no=$(echo -e "\u2715 No")            # Changed

# Rofi CMD
rofi_cmd() {
    rofi -theme-str 'textbox-prompt-colon {str: "";}' \
        -dmenu \
        -p "$prompt" \
        -mesg "$mesg" \
        -markup-rows \
        -theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$option_4\n$option_3\n$option_1\n$option_2" | rofi_cmd
}

# Confirmation CMD
confirm_cmd() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {orientation: vertical; children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme ${theme}
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Confirm and execute
confirm_run () {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        ${@}
    else
        exit
    fi
}


# Execute Command
run_cmd() {
    if [[ "$1" == '--opt1' ]]; then # Logout
        confirm_run 'qtile cmd-obj -o cmd -f shutdown'
    elif [[ "$1" == '--opt2' ]]; then # Suspend
        confirm_run 'systemctl suspend'
    elif [[ "$1" == '--opt3' ]]; then # Reboot
        confirm_run 'systemctl reboot'
    elif [[ "$1" == '--opt4' ]]; then # Shutdown
        confirm_run 'systemctl poweroff'
    fi
}

# Actions
chosen="$(run_rofi)"
# Handle cancellation of the main Rofi menu BEFORE showing confirmation
if [[ -z "$chosen" ]]; then # If 'chosen' is empty (user pressed ESC or cancelled)
    exit 0 # Exit the script silently
fi

case ${chosen} in
    "$option_1")
        run_cmd --opt1
        ;;
    "$option_2")
        run_cmd --opt2
        ;;
    "$option_3")
        run_cmd --opt3
        ;;
    "$option_4")
        run_cmd --opt4
        ;;
esac
