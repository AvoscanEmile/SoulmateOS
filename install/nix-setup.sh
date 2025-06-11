#!/usr/bin/env bash
set -euo pipefail

# 1. Install prerequisites
sudo dnf install -y tar policycoreutils-python-utils

# 2. Temporarily switch SELinux to permissive so installer can run
sudo setenforce 0

# 3. Install Nix in multi-user (daemon) mode
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon --yes

# 4. Capture SELinux denials and generate a custom policy module
sudo ausearch -m avc -ts today | audit2allow -M nix-install
sudo semodule -i nix-install.pp

# 5. Make nix work without reboot
source /etc/profile.d/nix.sh

# 7. Restore SELinux to enforcing mode
sudo setenforce 1

echo "Nix multi-user install complete. SELinux policy updated and enforcing."
