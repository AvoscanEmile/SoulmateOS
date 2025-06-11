# SoulmateOS Minimal Installer

This folder provides a streamlined script to transform a **minimal AlmaLinux 9.6 installation** into a functional graphical environment using **LightDM** and **Qtile**.

---

## Requirements

- AlmaLinux 9.6 **minimal install**
- Internet connection
- Root (or `sudo`) privileges

---

## Quick Installation

Run the following commands from your fresh AlmaLinux installation:

```bash
sudo dnf install -y git
git clone https://github.com/avoscanemile/soulmateos.git
sudo soulmateos/install/installation.sh
