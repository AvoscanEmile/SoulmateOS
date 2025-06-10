#!/usr/bin/env bash
set -euo pipefail

# 1. Run the official Nix installer in no-daemon mode
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon

# 2. Source Nix into the current shell and persist it, after that reloads bash to avoid reboot
. "$HOME/.nix-profile/etc/profile.d/nix.sh"
echo 'source "$HOME/.nix-profile/etc/profile.d/nix.sh"' >> "$HOME/.bashrc"
exec bash
