#!/usr/bin/env bash
set -euo pipefail
# This script install and configures x11 and lightDM with the GTK Greeter
echo "Installing X11 and LightDM..."
sudo dnf update -y
sudo dnf groupinstall -y "base-x"
sudo dnf install -y lightdm lightdm-gtk-greeter
sudo touch /etc/rc.d/rc.local
sudo chmod +x /etc/rc.d/rc.local
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target
