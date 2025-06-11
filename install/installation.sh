#!/usr/bin/env bash
set -euo pipefail

# Prompt for sudo password once, and keep alive throughout the script
sudo -v
( while true; do sudo -n true; sleep 60; done ) &
SUDO_KEEPALIVE=$!
trap 'kill $SUDO_KEEPALIVE' EXIT

# 1. Enable repos
echo "Enabling DNF repositories..."
sudo dnf config-manager --set-enabled baseos appstream crb extras
sudo dnf install -y epel-release
sudo dnf install -y distribution-gpg-keys
sudo rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-el-$(rpm -E %rhel)
sudo rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-nonfree-el-$(rpm -E %rhel)
sudo dnf --setopt=localpkg_gpgcheck=1 install -y \
  https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

# 2. Update and install X11 + LightDM
echo "Installing X11 and LightDM..."
sudo dnf update -y
sudo dnf groupinstall -y "base-x"
sudo dnf install -y lightdm lightdm-gtk-greeter
sudo touch /etc/rc.d/rc.local
sudo chmod +x /etc/rc.d/rc.local
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

# 3. Install Python 3.11 and build tools
echo "Installing Python 3.11 and development tools..."
sudo dnf install -y \
  python3.11 python3.11-pip python3.11-devel python3.11-setuptools \
  gcc make pkg-config libffi-devel

# 4. Install C/C++ development headers
echo "Installing C/C++ headers and libraries..."
sudo dnf install -y \
  libX11-devel libXrandr-devel libXi-devel libXinerama-devel libXcursor-devel \
  libxcb-devel xcb-util-devel xcb-util-renderutil-devel xcb-util-wm-devel \
  cairo-devel cairo-gobject-devel pango-devel \
  gobject-introspection-devel glib2-devel \
  dbus-devel

# 5. Install Qtile and Python bindings (as user)
echo "Installing Python bindings and Qtile..."
python3.11 -m pip install --upgrade pip
python3.11 -m pip install \
  xcffib \
  cairocffi \
  pangocairocffi \
  dbus-python \
  PyGObject==3.50.1 \
  qtile

# 6. Configure LightDM Qtile session
echo "Configuring Qtile LightDM session..."
sudo tee /usr/share/xsessions/qtile.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Qtile
Comment=Tiling Window Manager
Exec=dbus-run-session qtile start
Type=Application
Keywords=wm;tiling;
EOF

# 7. Multi-user nix installation
echo "Running Nix setup script..."
bash /soulmateos/install/nix-setup.sh

# 8. Reboot prompt
echo -e "\nInstallation complete."
read -rp "Would you like to reboot now? [y/N]: " choice
case "$choice" in
  y|Y ) echo "Rebooting..."; sudo reboot;;
  * ) echo "Reboot skipped. You can reboot manually later with 'sudo reboot'.";;
esac

