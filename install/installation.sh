#!/usr/bin/env bash
set -euo pipefail

# installation.sh: Orchestrator for soulmateOS setup
# ----------------------------------------
# Usage:
#   ./installation.sh [--keep-repo] [--keep-docs] [--keep-devlogs]
#
# Flags:
#   --keep-repo       Preserve the original ~/soulmateos repository after install
#   --keep-docs       Keep docs/ in ~/.config/soulmateos/docs
#   --keep-devlogs    Keep devlogs/ in ~/.config/soulmateos/devlogs
#   -h, --help        Show this help message and exit

usage() {
  cat <<EOF
Usage: $0 [--keep-repo] [--keep-docs] [--keep-devlogs]

Options:
  --keep-repo       Do not remove ~/soulmateos after installation
  --keep-docs       Do not remove docs/ from ~/.config/soulmateos
  --keep-devlogs    Do not remove devlogs/ from ~/.config/soulmateos
  -h, --help        Show this help message and exit
EOF
  exit 1
}

# Defining relevant variables. KEEP_* are flag variables, CONFIG_DIR is the location of the config files post installation. 
KEEP_REPO=false
KEEP_DOCS=false
KEEP_DEVLOGS=false
CONFIG_DIR="$HOME/.config/soulmateos"

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep-repo)
      KEEP_REPO=true
      shift
      ;;
    --keep-docs)
      KEEP_DOCS=true
      shift
      ;;
    --keep-devlogs)
      KEEP_DEVLOGS=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Error: Unknown option '$1'" >&2
      usage
      ;;
  esac
done

# 0. Keep sudo alive
sudo -v
( while true; do sudo -n true; sleep 60; done ) &
SUDO_KEEPALIVE=$!
trap 'kill $SUDO_KEEPALIVE' EXIT

# 1. Enable repos
echo "Enabling DNF repositories..."
sudo dnf config-manager --set-enabled baseos appstream crb extras
sudo dnf install -y epel-release

# 2. Run installation phases
echo "Starting Phase 1: Graphics installation"
bash ~/soulmateos/install/modules/graphics.sh

echo "Starting Phase 2: Qtile installation"
bash ~/soulmateos/install/modules/qtile.sh

echo "Starting Phase 3: User-level apps installation"
bash ~/soulmateos/install/modules/user.sh

echo "Starting Phase 4: Configuration deployment"
bash ~/soulmateos/install/modules/config.sh

# 3. Post-install cleanup
# Checks for --keep-repo, if not used removes the soulmateos repo stored at $HOME
echo "→ Cleaning up installation artifacts"
if [[ "$KEEP_REPO" == false ]]; then
  rm -rf "$HOME/soulmateos"
  echo "Removed ~/soulmateos"
else
  echo "Retained ~/soulmateos"
fi

# Checks for --keep-docs, if not used removes the ~/.config/soulmateos/docs folder
if [[ "$KEEP_DOCS" == false ]]; then
  rm -rf "$CONFIG_DIR/docs"
  echo "Removed \$CONFIG_DIR/docs"
else
  echo "Retained \$CONFIG_DIR/docs"
fi

# Checks for --keep-devlogs, if not used removes the ~/.config/soulmateos/devlogs folder
if [[ "$KEEP_DEVLOGS" == false ]]; then
  rm -rf "$CONFIG_DIR/devlogs"
  echo "Removed \$CONFIG_DIR/devlogs"
else
  echo "Retained \$CONFIG_DIR/devlogs"
fi

# Removes the install directory for simplicity. If the user wants to retain the installation script it can do so via --keep-repo
rm -rf "$CONFIG_DIR/install"
echo "Removed \$CONFIG_DIR/install"

# Reboot prompt
echo -e "\nInstallation complete."
read -rp "Would you like to reboot now? [y/N]: " choice
case "$choice" in
  y|Y ) echo "Rebooting..."; sudo reboot;;
  * ) echo "Reboot skipped. You can reboot manually later with 'sudo reboot'.";;
esac
