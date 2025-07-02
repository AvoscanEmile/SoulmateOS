# SoulmateOS Comprehensive Installation Guide

This guide provides a comprehensive overview and instructions for transforming a minimal AlmaLinux 9.6 installation into a complete graphical environment powered by LightDM and the Qtile Window Manager, along with various user-level applications and configurations.

## Requirements

Before you begin, ensure your system meets the following requirements:

  * **AlmaLinux 9.6 Minimal Installation**: This installer is specifically designed for a minimal installation of AlmaLinux 9.6.
  * **Internet Connection**: An active internet connection is required to download packages and dependencies.
  * **Root or `sudo` Privileges**: The installation process requires administrative privileges to install system-level packages and configure services.

## Quick Installation

For a quick setup, execute the following commands from your fresh AlmaLinux installation:

```bash
sudo dnf install -y git
git clone https://github.com/avoscanemile/soulmateos.git
bash soulmateos/install/installation.sh
```

## Detailed Installation Process

The `installation.sh` script acts as the main orchestrator, guiding you through several phases of the soulmateOS setup. It utilizes modular scripts located in `soulmateos/install/modules/` to handle specific aspects of the installation.

### Installation Phases

1.  **Repository Enabling**: The installer begins by enabling essential DNF repositories, including `baseos`, `appstream`, `crb`, `extras`, and `epel-release`, to ensure all necessary packages are available.
2.  **Graphics Installation (Phase 1)**: This phase, managed by `graphics.sh`, focuses on setting up the graphical environment.
      * It updates DNF packages.
      * It installs the "base-x" group, which provides the core X11 components.
      * `lightdm` (the display manager) and `lightdm-gtk-greeter` are installed.
      * `lightdm` is enabled to start on boot, and the system's default target is set to the graphical target.
3.  **Qtile Installation (Phase 2)**: The `qtile.sh` script handles the installation and configuration of the Qtile Window Manager.
      * It installs Python 3.11, `pip`, development tools, and compilers (`gcc`, `make`, `pkg-config`, `libffi-devel`).
      * Necessary C/C++ development headers and libraries for Qtile, such as `libX11-devel`, `libXrandr-devel`, `cairo-devel`, and `dbus-devel`, are installed.
      * Python bindings essential for Qtile, including `xcffib`, `cairocffi`, `pangocairocffi`, `dbus-python`, `PyGObject`, and `qtile` itself, are installed via `pip`.
      * A `.desktop` file is created for Qtile, allowing LightDM to recognize and provide it as a selectable desktop session.
4.  **User-Level Applications Installation (Phase 3)**: The `user.sh` script installs various applications and enhances the user experience.
      * It performs a single-user installation of Nix.
      * Essential desktop applications like `kitty`, `geany`, `thunar`, `btop`, `gnome-disk-utility`, `gthumb`, and `rofi` are installed using DNF and Nix.
      * Additional user-level applications such as `celluloid`, `lollypop`, `foliate`, `calcurse`, `polybar`, `eww`, `firefox`, `engrampa`, and `evince` are installed.
      * UX enhancers like `rsync`, `xfce4-notifyd`, `xfce4-screenshooter`, and `xfce4-clipman-plugin` are also installed.
      * A compositor (`picom`) and its dependencies are installed, leveraging NixGL for graphical capabilities.
5.  **Configuration Deployment (Phase 4)**: The `config.sh` script deploys the core soulmateOS configurations and sets up symbolic links.
      * The contents of the `~/soulmateos` repository are copied to `~/.config/soulmateos`.
      * Qtile's autostart script (`~/.config/soulmateos/config/qtile/autostart.sh`) is made executable.
      * Themes (Nordic GTK, Layan white cursors, and Nordzy icons) are extracted from their archives into their respective directories within `~/.local/share/`.
      * Symbolic links are created to connect configuration files and directories from `~/.config/soulmateos` to their standard locations in the user's home directory (e.g., Qtile, Polybar, Eww, GTK 3.0, Picom configurations, `.Xresources`, D-Bus services, fonts, GTK themes, and icons).

### Post-Installation Cleanup

After all installation phases are complete, the `installation.sh` script performs cleanup operations based on the flags provided during its execution.

  * **`--keep-repo`**: If this flag is **not** used, the original `~/soulmateos` repository will be removed.
  * **`--keep-docs`**: If this flag is **not** used, the `docs/` folder within `~/.config/soulmateos/` will be removed.
  * **`--keep-devlogs`**: If this flag is **not** used, the `devlogs/` folder within `~/.config/soulmateos/` will be removed.
  * Additionally, non-essential files such as `README.md`, `install/`, `LICENSE`, and `.git` are removed from the `~/.config/soulmateos` directory.

### Reboot

Upon successful completion, the installer will prompt you to reboot your system. It is highly recommended to reboot to apply all changes and start your new soulmateOS environment.

## Usage of `installation.sh` Flags

You can customize the post-installation cleanup behavior of `installation.sh` using the following flags:

  * `--keep-repo`: Preserves the original `~/soulmateos` repository after installation.
  * `--keep-docs`: Keeps the `docs/` directory in `~/.config/soulmateos/docs`.
  * `--keep-devlogs`: Keeps the `devlogs/` directory in `~/.config/soulmateos/devlogs`.
  * `-h`, `--help`: Displays a help message and exits.

**Example:**

To install soulmateOS and keep the original repository and documentation:

```bash
bash soulmateos/install/installation.sh --keep-repo --keep-docs
```
