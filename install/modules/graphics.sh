#!/usr/bin/env bash
set -euo pipefail
# This script installs, and enables SDDM
echo "Installing and Enabling Display Manager (SDDM)..."
sudo dnf update -y
sudo dnf install -y epel-release sddm
sudo systemctl enable sddm
sudo systemctl set-default graphical.target
echo "Succesful Installation of the Display Manager"
