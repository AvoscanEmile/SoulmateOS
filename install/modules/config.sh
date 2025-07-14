#!/usr/bin/env bash
set -euo pipefail

# config.sh: Deploy soulmateOS configs & create symlinks.
# Expects these env vars (set by installation.sh):
#   REPO_DIR   — where the soulmateos repo lives (default: $HOME/soulmateos)
#   CONFIG_DIR — where configs should be staged (default: $HOME/.config/soulmateos)

: "${REPO_DIR:=$HOME/soulmateos}"
: "${CONFIG_DIR:=$HOME/.config/soulmateos}"

# 1) Deploy config and themes
echo "→ Deploying repo into config: $REPO_DIR → $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"
rsync -av --delete "$REPO_DIR/" "$CONFIG_DIR/"

# 2) Make sure Qtile’s autostart is executable
AUTOSTART="$CONFIG_DIR/config/qtile/autostart.sh"
if [[ -f "$AUTOSTART" ]]; then
  chmod +x "$AUTOSTART"
  echo "→ Made executable: $AUTOSTART"
else
  echo "Warning: Qtile autostart not found at $AUTOSTART" >&2
fi

# 3) Symlinking (relative to CONFIG_DIR) and theme extraction
tar -xf "$CONFIG_DIR/themes/gtk/Nordic.tar.xz" -C "$CONFIG_DIR/themes/gtk" && rm "$CONFIG_DIR/themes/gtk/Nordic.tar.xz"
tar -xf "$CONFIG_DIR/themes/icons/03-Layan-white-cursors.tar.xz" -C "$CONFIG_DIR/themes/icons" && rm "$CONFIG_DIR/themes/icons/03-Layan-white-cursors.tar.xz"
tar -xf "$CONFIG_DIR/themes/icons/Nordzy.tar.gz" -C "$CONFIG_DIR/themes/icons" && rm "$CONFIG_DIR/themes/icons/Nordzy.tar.gz"

declare -A LINKS=(
  [config/qtile]="$HOME/.config/qtile"
  [config/polybar]="$HOME/.config/polybar"
  [config/rofi]="$HOME/.config/rofi"
  [config/eww]="$HOME/.config/eww"
  [config/gtk-3.0]="$HOME/.config/gtk-3.0"
  [config/picom]="$HOME/.config/picom"
  [config/others/.Xresources]="$HOME/.Xresources"
  [config/services/org.freedesktop.Notifications.service]="$HOME/.local/share/dbus-1/services/org.freedesktop.Notifications.service"
  [themes/fonts]="$HOME/.local/share/fonts"
  [themes/gtk]="$HOME/.local/share/themes"
  [themes/icons]="$HOME/.local/share/icons"
)

# 4) Create symlinks
echo "→ Creating symlinks"
for src_rel in "${!LINKS[@]}"; do
  SRC="$CONFIG_DIR/$src_rel"
  DST="${LINKS[$src_rel]}"

  if [[ ! -e "$SRC" ]]; then
    echo "Error: Cannot link non-existent source: $SRC" >&2
    exit 1
  fi

  echo "  ↳ $SRC → $DST"
  mkdir -p "$(dirname "$DST")"
  ln -sfn "$SRC" "$DST"
done

# 5) Make relevant files executable

chmod +x $HOME/.config/rofi/applets/power/power.sh

echo "→ Configuration deployment complete."
