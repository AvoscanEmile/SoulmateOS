#!/usr/bin/env bash
set -euo pipefail

# This script install all the relevant devel tools, headers, libraries and bindings for qtile, installs qtile and configures it to start at bootup. 
# 1. Install Python 3.11 and build tools
echo "Installing Python 3.11 and development tools..."
sudo dnf install -y python3.11 python3.11-pip python3.11-devel python3.11-setuptools gcc make pkg-config libffi-devel

# 2. Install C/C++ development headers
echo "Installing C/C++ headers and libraries..."
sudo dnf install -y \
  libX11-devel libXrandr-devel libXi-devel libXinerama-devel libXcursor-devel libxcb-devel xcb-util-devel xcb-util-renderutil-devel xcb-util-wm-devel \
  cairo-devel cairo-gobject-devel pango-devel gobject-introspection-devel glib2-devel dbus-devel

# 3. Install Qtile and Python bindings (as user)
echo "Installing Python bindings and Qtile..."
python3.11 -m pip install --upgrade pip
python3.11 -m pip install xcffib cairocffi pangocairocffi dbus-python PyGObject==3.50.1 qtile

# 4. Configure LightDM Qtile session
echo "Configuring Qtile LightDM session..."
sudo tee /usr/share/xsessions/qtile.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Qtile
Comment=Tiling Window Manager
Exec=dbus-run-session qtile start
Type=Application
Keywords=wm;tiling;
EOF

echo "Qtile succesfully installed and configured."
