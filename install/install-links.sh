#!/usr/bin/env bash
set -euo pipefail

# 1) Source & target directories
REPO_DIR="$HOME/soulmateos"
MASTER="$HOME/.config/soulmateos"

# 2) Map each source (relative to $MASTER) to its live destination
declare -A LINKS=(
  [qtile]="$HOME/.config/qtile"
  [org.freedesktop.Notifications.service]="$HOME/.local/share/dbus-1/services/org.freedesktop.Notifications.service"
)

# 3) Copy the master config tree
echo "Copying configs: $REPO_DIR/config → $MASTER"
mkdir -p "$MASTER"
rsync -av --delete "$REPO_DIR/config/" "$MASTER/"

# 4) Create symlinks
echo "Creating symlinks:"
for src_rel in "${!LINKS[@]}"; do
  SRC="$MASTER/$src_rel"
  DST="${LINKS[$src_rel]}"
  echo "  ↳ $SRC → $DST"
  mkdir -p "$(dirname "$DST")"
  ln -sfn "$SRC" "$DST"
done
