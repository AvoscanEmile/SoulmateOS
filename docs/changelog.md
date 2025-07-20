# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Planning and design of project architecture.
- Added a description to the project.
- Created initial `README.md` and added a `LICENSE`.

## [0.1.0] - 2025-June-04
### Added
- Created base folder structure for SoulmateOS with placeholder `.gitkeep` files.
- Initialized repository with LICENSE and README.
- Created initial `CHANGELOG.md`, `architecture.md` and `roadmap.md` in `/docs`.
- Created `01-intro-vision.md` and `02-initial-repository-setup.md` inside `/devlogs`

## [0.2.0] - 2025-June-08
### Added
- Created `installation.sh`, the main script for installing SoulMateOS. Currently takes you from minimal install into a working lightdm login screen and a working qtile desktop.
- Created `install/README.md` where the installation process is explained.
- Created `03-failed-awesome-attempt.md` and `04-succesful-qtile-installation.md` inside `/devlogs`.
### Changed 
- Changed `CHANGELOG.md`, `architecture.md` and `roadmap.md` in `/docs` to reflect the transition from AwesomeWM into Qtile.
### Removed
- Removed `.gitkeep` files that were no longer necessary.

## [0.3.0] - 2025-June-11
### Added
- Created `nix-setup.sh`, the script for installing nix multi-user and rofi via nix.
- Created `05-package-selection.md` and `06-nixmare-of-a-setup.md` inside `/devlogs`.
### Changed 
- Changed `changelog.md`, `architecture.md` and `roadmap.md` in `/docs` to reflect the progress of the project.
- Changed `installation.sh` to call `nix-setup.sh` when needed and to install the relevant packages selected in `05-package-selection.md`. 
- Changed `/install/README.md` to make the installation process more consistent since while testing I find out caps were a problem.

## [0.4.0] - 2025-June-16
### Added
- Created `07-user-package-selection.md` and `08-nix-problems-again.md` inside `/devlogs`.
### Changed 
- Changed `installation.sh` to add new packages into the installation process, change nix from multi-user to single-user and remove RPM FUSION. 
- Changed `CHANGELOG.md`, `architecture.md` and `roadmap.md` in `/docs` to reflect the progress made to the project.
### Removed
- Removed `nix-setup.sh` since the single-user installation is simpler and fitted easily within `installation.sh`.

## [0.5.0] - 2025-June-17
### Added
- Created `09-entry.md` inside `/devlogs`.
- Created `/install/install-links.sh`, the main script for creating simlinks to config and theme files.
- Created `/config/qtile/autostart.sh` and `/config/qtile/config.py`, both of them being files for the qtile custom configuration.
- Created `/config/services/org.freedesktop.Notifications.service` the required service for the notification daemon to work. 
### Changed 
- Changed `installation.sh` to call `install-links.sh` before finishing the script. 
- Changed `CHANGELOG.md`, `architecture.md` and `roadmap.md` in `/docs` to reflect the progress made to the project.
- Changed all previous entries inside `/devlogs` so they follow a more standard naming convetion and structure. 
### Removed
- Removed `.gitkeep` files that were no longer necessary.

## [0.6.0] - 2025-July-19
### Changed
- Changed `LICENSE`
- Changed `README.md`
- Changed `config/qtile/autostart.sh`
- Changed `config/qtile/config.py`
- Changed `docs/architecture.md`
- Changed `docs/roadmap.md`
- Changed `install/README.md`
- Changed `install/installation.sh`

### Added
- Added `config/eww/eww.css`
- Added `config/eww/eww.yuck`
- Added `config/eww/scripts/volume-monitor.sh`
- Added `config/geany/colorschemes/nord.conf`
- Added `config/geany/geany.conf`
- Added `config/gtk-3.0/apps/geany.css`
- Added `config/gtk-3.0/apps/thunar.css`
- Added `config/gtk-3.0/colors.css`
- Added `config/gtk-3.0/fonts.css`
- Added `config/gtk-3.0/gtk.css`
- Added `config/gtk-3.0/settings.ini`
- Added `config/kitty/kitty.conf`
- Added `config/others/.Xresources`
- Added `config/picom/picom.conf`
- Added `config/polybar/config.ini`
- Added `config/polybar/scripts/change-config.sh`
- Added `config/polybar/scripts/network.sh`
- Added `config/polybar/scripts/qtile-groups.sh`
- Added `config/polybar/scripts/volume.sh`
- Added `config/rofi/applets/power/power.sh`
- Added `config/rofi/applets/power/theme.rasi`
- Added `config/rofi/themes/shared/colors.rasi`
- Added `config/rofi/themes/shared/fonts.rasi`
- Added `config/rofi/themes/soulmate_solid_fullscreen_left.rasi`
- Added `config/rofi/themes/soulmate_solid_fullscreen_top.rasi`
- Added `config/rofi/themes/soulmate_solid_left.rasi`
- Added `config/rofi/themes/soulmate_solid_top.rasi`
- Added `config/scripts/change-themes.sh`
- Added `devlogs/10-entry.md`
- Added `devlogs/11-entry.md`
- Added `devlogs/12-entry.md`
- Added `devlogs/13-entry.md`
- Added `devlogs/14-entry.md`
- Added `devlogs/15-entry.md`
- Added `devlogs/16-entry.md`
- Added `devlogs/17-entry.md`
- Added `devlogs/18-entry.md`
- Added `devlogs/19-entry.md`
- Added `devlogs/20-entry.md`
- Added `devlogs/21-entry.md`
- Added `install/modules/config.sh`
- Added `install/modules/graphics.sh`
- Added `install/modules/qtile.sh`
- Added `install/modules/user.sh`
- Added `themes/fonts/Font Awesome 6 Free-Solid-900.otf`
- Added `themes/fonts/Inconsolata-VariableFont_wdth,wght.ttf`
- Added `themes/fonts/JetBrains-Mono-Nerd-Font-Complete.ttf`
- Added `themes/fonts/NotoColorEmoji-Regular.ttf`
- Added `themes/gtk/Nordic.tar.xz`
- Added `themes/icons/03-Layan-white-cursors.tar.xz`
- Added `themes/icons/Nordzy-dark.tar.gz`
- Added `themes/polybar_theme.ini`

### Removed
- Removed `install/install-links.sh`
- Removed `themes/.gitkeep`
