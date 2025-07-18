#!/usr/bin/env bash
set -euo pipefail

# 1. Single user nix installation
echo "Installing single user nix..."
curl -L https://nixos.org/nix/install | sh
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

# 2. Basic Apps Installation
echo "Installing basic desktop apps..."
sudo dnf install -y kitty btop gnome-disk-utility gthumb
nix-env -iA nixpkgs.rofi nixpkgs.geany nixpkgs.thunar

# 3. Installing user-level apps
echo "Installing desktop apps..."
nix-env -iA nixpkgs.celluloid nixpkgs.lollypop nixpkgs.foliate nixpkgs.calcurse nixpkgs.polybar nixpkgs.eww nixpkgs.firefox nixpkgs.xfce.thunar-archive-plugin
sudo dnf install -y engrampa evince

# 4. Installing UX enhancers
echo "Installing UX enhancers..."
sudo dnf install -y rsync xfce4-notifyd xfce4-screenshooter xfce4-clipman-plugin unzip

# 5. Installing Compositor and dependencies.
echo "Installing Compositor and dependencies..."
nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl && nix-channel --update
nix-env -iA nixgl.auto.nixGLDefault nixpkgs.picom

echo "The user environment was succesfully installed"
