# Error Handling
#!/usr/bin/env bash
set -e
# 1. Enable repos
# Basic Repos
sudo dnf config-manager --set-enabled baseos appstream crb extras
# EPEL installation
sudo dnf install -y epel-release
# RPM Fusion GPG keys to validate packages installed through RPM Fusion are authentic
sudo dnf install -y distribution-gpg-keys
# RPM Fusion importing keys
sudo rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-el-$(rpm -E %rhel)
sudo rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-nonfree-el-$(rpm -E %rhel)
# RPM Fusion installation
sudo dnf --setopt=localpkg_gpgcheck=1 install -y https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm
sudo dnf --setopt=localpkg_gpgcheck=1 install -y https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

# 2. Update, install, and configure X11 + LightDM
sudo dnf update -y
sudo dnf groupinstall -y "base-x"
sudo dnf install -y lightdm lightdm-gtk-greeter
# A fix that corrects a purely cosmetic error when running systemctl enable/disable
sudo touch /etc/rc.d/rc.local
sudo chmod +x /etc/rc.d/rc.local
# Setting up the machine to start lightdm on boot
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target

# 3. Install Python 3.11 and build tools
sudo dnf install -y \
  python3.11 python3.11-pip python3.11-devel python3.11-setuptools \
  gcc make pkg-config libffi-devel

# 4. Install C/C++ development headers
sudo dnf install -y \
  libX11-devel libXrandr-devel libXi-devel libXinerama-devel libXcursor-devel \
  libxcb-devel xcb-util-devel xcb-util-renderutil-devel xcb-util-wm-devel \
  cairo-devel cairo-gobject-devel pango-devel \
  gobject-introspection-devel glib2-devel \
  dbus-devel

# 5. Install Qtile and Python bindings
sudo python3.11 -m pip install --upgrade pip
sudo python3.11 -m pip install \
  xcffib \
  cairocffi \
  pangocairocffi \
  dbus-python \
  PyGObject==3.50.1 \
  qtile

# 6. Configure the LightDM Qtile session
sudo tee /usr/share/xsessions/qtile.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Qtile
Comment=Tiling Window Manager
Exec=dbus-run-session qtile start
Type=Application
Keywords=wm;tiling;
EOF

# 7. Reboot prompt 
printf "\n✅ Installation complete.\n"
read -p "Would you like to reboot now? [y/N]: " choice
case "$choice" in
  y|Y ) echo "Rebooting..."; sudo reboot;;
  * ) echo "Reboot skipped. You can reboot manually later with 'sudo reboot'.";;
esac
