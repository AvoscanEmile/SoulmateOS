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
