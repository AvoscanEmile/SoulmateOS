#!/usr/bin/env bash
set -euo pipefail

# Trap to restore SELinux to enforcing mode on exit or error
trap 'setenforce 1' EXIT

# 1. Install prerequisites
dnf install -y curl tar policycoreutils-python-utils

# 2. Temporarily switch SELinux to permissive so installer can run
setenforce 0

# 3. Install Nix in multi-user (daemon) mode
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon --yes

# 4. Capture SELinux denials and generate a custom policy module
ausearch -m avc -ts today | audit2allow -M nix-install
semodule -i nix-install.pp

# 5. Persist the Nix environment for all users via /etc/profile.d
tee /etc/profile.d/nix.sh << 'EOF'
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
EOF
chmod 644 /etc/profile.d/nix.sh

# 6. Ensure current user’s future shells loads nix properly
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
echo 'source /etc/profile.d/nix.sh' >> "$USER_HOME/.bashrc"
chown "$SUDO_USER":"$SUDO_USER" "$USER_HOME/.bashrc"

# 7. Source immediately for the current session
sudo -u "$SUDO_USER" bash -lc '
  source /etc/profile.d/nix.sh
'

# 7. Restore SELinux to enforcing mode
setenforce 1

echo "Nix multi-user install complete. SELinux policy updated and enforcing."
