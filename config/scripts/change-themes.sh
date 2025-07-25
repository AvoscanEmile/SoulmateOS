#!/bin/bash

# change-theme.sh
# This script reads the current GTK theme, extracts its core colors,
# and applies them to Polybar and Rofi to ensure a consistent look and feel.

# --- 1. Read the current GTK theme from settings.ini ---

# Define the path to the GTK settings file.
SETTINGS_FILE="$HOME/.config/gtk-3.0/settings.ini"

# Check if the settings file exists.
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Error: GTK settings file not found at $SETTINGS_FILE"
    exit 1
fi

# Grep for the 'gtk-theme-name' and use sed to extract the value.
CURRENT_THEME=$(grep 'gtk-theme-name' "$SETTINGS_FILE" | sed 's/.*=//')
echo "Current GTK Theme: $CURRENT_THEME"

# --- 2. Extract color variables from the theme's gtk.css ---

# Define the path to the theme's CSS file.
THEME_CSS_FILE="$HOME/.local/share/themes/$CURRENT_THEME/gtk-3.0/gtk.css"

# Check if the CSS file exists.
if [ ! -f "$THEME_CSS_FILE" ]; then
    echo "Error: Theme CSS file not found at $THEME_CSS_FILE"
    # Fallback for themes installed system-wide
    THEME_CSS_FILE="/usr/share/themes/$CURRENT_THEME/gtk-3.0/gtk.css"
    if [ ! -f "$THEME_CSS_FILE" ]; then
        echo "Error: Also not found in /usr/share/themes. Aborting."
        exit 1
    fi
fi

# Function to extract a color value from the CSS file.
extract_color() {
    # Loop through all provided arguments (primary, fallback1, fallback2)
    for var_at in "$1" "$2" "$3"; do
        # Skip if the argument is empty
        [ -z "$var_at" ] && continue

        # The variable name we look for in the CSS file (e.g., "theme_bg_color")
        local var_name_to_find=${var_at#@}

        # The awk command to find and extract the color
        local color_value=$(awk -v var="$var_name_to_find" '$2 == var {gsub(";",""); print $3}' "$THEME_CSS_FILE")

        # If a color was found, print it and exit the function
        if [ -n "$color_value" ]; then
            echo "$color_value"
            return 0
        fi
    done

    # If no color was found after trying all arguments, return 1 to indicate failure
    return 1
}

# Extract each color and assign it to a variable.
background=$(extract_color "@theme_bg_color" "@bg_color" "@theme_base_color")
background_alt=$(extract_color "@theme_base_color" "@content_view_bg" "@theme_bg_color")
foreground=$(extract_color "@theme_fg_color" "@theme_text_color" "@fg_color")
selected=$(extract_color "@theme_selected_bg_color" "@selected_bg_color" "@success_color")
active=$(extract_color "@success_color" "@theme_selected_bg_color" "@warning_color")
urgent=$(extract_color "@error_color" "@warning_color" "@theme_selected_bg_color")
borders=$(extract_color "@borders" "@theme_bg_color" "@bg_color")
disabled_foreground_color=$(extract_color "@theme_unfocused_selected_fg_color" "@unfocused_selected_fg_color" "@borders")

# Check if colors were extracted successfully.
if [ -z "$background" ] || [ -z "$foreground" ]; then
    echo "Error: Could not extract essential colors (background/foreground) from CSS file."
    exit 1
fi

echo "Extracted Colors:"
echo "  Background:     $background"
echo "  Background Alt: $background_alt"
echo "  Foreground:     $foreground"
echo "  Selected:       $selected"
echo "  Active:         $active"
echo "  Urgent:         $urgent"
echo "  borders:         $borders"

# --- 3. Update Polybar theme file ---

# Define the path to the Polybar theme file.
POLYBAR_THEME_FILE="$HOME/.config/soulmateos/themes/polybar_theme.ini"

# Check if the Polybar theme file exists.
if [ ! -f "$POLYBAR_THEME_FILE" ]; then
    echo "Error: Polybar theme file not found at $POLYBAR_THEME_FILE"
    exit 1
fi

# Use sed to replace the BACKGROUND and FOREGROUND values in-place.
# The -i flag modifies the file directly.
sed -i "s/^BACKGROUND=.*/BACKGROUND=$borders/" "$POLYBAR_THEME_FILE"
sed -i "s/^FOREGROUND=.*/FOREGROUND=$foreground/" "$POLYBAR_THEME_FILE"

echo "Successfully updated Polybar theme file."

# --- 4. Generate Rofi colors.rasi file ---

# Define the path for the Rofi colors file.
ROFI_COLORS_FILE="$HOME/.config/rofi/themes/shared/colors.rasi"

# Create the directory if it doesn't exist.
mkdir -p "$(dirname "$ROFI_COLORS_FILE")"

# Use a HEREDOC (EOF block) to write the new color configuration to the file.
# This will overwrite the file if it already exists, ensuring it's always up-to-date.
cat << EOF > "$ROFI_COLORS_FILE"
/* This file is auto-generated by change-theme.sh */
/* Do not edit manually.                       */

* {
    background:     ${background}FF;
    background-alt: ${background_alt}FF;
    foreground:     ${foreground}FF;
    selected:       ${selected}FF;
    active:         ${active}FF;
    urgent:         ${urgent}FF;
}
EOF

echo "Successfully generated Rofi colors.rasi file."

# --- 5. Generate GTK colors.css file ---

# Define the path for the GTK colors file.
GTK_COLORS_FILE="$HOME/.config/gtk-3.0/colors.css"

# Create the directory if it doesn't exist (though ~/.config/gtk-3.0 should already exist).
mkdir -p "$(dirname "$GTK_COLORS_FILE")"

# Use a HEREDOC (EOF block) to write the new color definitions to the file.
# This will overwrite the file if it already exists.
cat << EOF > "$GTK_COLORS_FILE"
/* This file is auto-generated by change-theme.sh */
/* Do not edit manually.                           */

@define-color background ${background};
@define-color text ${foreground};
@define-color active ${active};
@define-color selected ${selected};
@define-color border_color ${borders};
@define-color background_hover ${background_alt};
@define-color unfocused_text ${disabled_foreground_color};
@define-color urgent ${urgent};

EOF

echo "Successfully generated GTK colors.css file."
echo "Theme synchronization complete."

