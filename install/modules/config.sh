#!/usr/bin/env bash
set -euo pipefail

# config.sh: Deploy soulmateOS configs & create symlinks.
# Expects these env vars (set by installation.sh):
#   REPO_DIR   — where the soulmateos repo lives (default: $HOME/soulmateos)
#   CONFIG_DIR — where configs should be staged (default: $HOME/.config/soulmateos)

: "${REPO_DIR:=$HOME/soulmateos}"
: "${CONFIG_DIR:=$HOME/.config/soulmateos}"

# 1) Source trees
SRC_CONFIG="$REPO_DIR/config"
SRC_THEMES="$REPO_DIR/themes"

# 2) Sanity checks
for d in "$SRC_CONFIG" "$SRC_THEMES"; do
  if [[ ! -d "$d" ]]; then
    echo "Error: Source directory not found: $d" >&2
    exit 1
  fi
done

# 3) Deploy config and themes
echo "→ Deploying config: $SRC_CONFIG → $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"
rsync -av --delete "$SRC_CONFIG/" "$CONFIG_DIR/"

echo "→ Deploying themes: $SRC_THEMES → $CONFIG_DIR/themes"
mkdir -p "$CONFIG_DIR/themes"
rsync -av --delete "$SRC_THEMES/" "$CONFIG_DIR/themes/"

# 4) Make sure Qtile’s autostart is executable
AUTOSTART="$CONFIG_DIR/qtile/autostart.sh"
if [[ -f "$AUTOSTART" ]]; then
  chmod +x "$AUTOSTART"
  echo "→ Made executable: $AUTOSTART"
else
  echo "Warning: Qtile autostart not found at $AUTOSTART" >&2
fi

# 5) Symlink map (relative to CONFIG_DIR)
declare -A LINKS=(
  [qtile]="$HOME/.config/qtile"
  [org.freedesktop.Notifications.service]="$HOME/.local/share/dbus-1/services/org.freedesktop.Notifications.service"
)

# 6) Create symlinks
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

echo "→ Configuration deployment complete."
