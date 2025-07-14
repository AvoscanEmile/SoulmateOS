#!/usr/bin/env bash
set -euo pipefail

# 1. Single user nix installation
echo "Installing single user nix..."
curl -L https://nixos.org/nix/install | sh
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

# 2. Basic Apps Installation
echo "Installing basic desktop apps..."
sudo dnf install -y kitty geany thunar btop gnome-disk-utility gthumb
nix-env -iA nixpkgs.rofi

# 3. Installing user-level apps
echo "Installing desktop apps..."
nix-env -iA nixpkgs.celluloid nixpkgs.lollypop nixpkgs.foliate nixpkgs.calcurse nixpkgs.polybar nixpkgs.eww
sudo dnf install -y firefox geany-plugins-markdown engrampa evince thunar-archive-plugin

# 4. Installing UX enhancers
echo "Installing UX enhancers..."
sudo dnf install -y rsync xfce4-notifyd xfce4-screenshooter xfce4-clipman-plugin unzip

# 5. Installing Compositor and dependencies.
echo "Installing Compositor and dependencies..."
nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl && nix-channel --update
nix-env -iA nixgl.auto.nixGLDefault nixpkgs.picom

echo "The user environment was succesfully installed"
