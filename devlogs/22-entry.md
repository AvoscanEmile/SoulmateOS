# Devlog Entry [22] — Establishing Cross-Distro Wayland Compositor Integration. Defining the new Installation Script. 

**Date**: 2025-07-22

**Author**: Emile Avoscan

**Target Version**: v0.1.0 

## Main Objective

This devlog entry details the foundational work undertaken to establish a stable and reproducible base system on Debian, specifically focusing on the integration of Wayland compositors within a multi-user Nix environment. A significant portion of this cycle was dedicated to diagnosing and resolving compatibility challenges between Nix-managed graphical components and the host operating system, ultimately leading to a refined strategy for compositor installation.

### Implementation

#### Phase 1 Goals Review

The development cycle commenced with a review of the high-level goals for Phase 1. These goals include establishing a minimal, headless Debian system, validating compatibility between the host OS and a Nix-managed graphical stack, and ensuring proper SDDM integration. These objectives served as the guiding principles for subsequent implementation efforts.

#### Debian Installation Strategy Refinement

Initially, the possibility of providing a comprehensive Debian preseed file for fully automated installations was explored. A guide for creating such a file was prepared. However, concerns were raised regarding the preseed file's potential to hardcode user-specific choices (e.g., language, timezone) and thus limit user freedom during the initial OS setup. Consequently, this approach was refined and postponed. Instead of a full preseed, the strategy was adopted to rely on the user performing a **manual minimal headless Debian installation**. The project's `setup.sh` script will then handle the subsequent post-installation configuration and SoulmateOS deployment, providing a balance between automation and user control. This also allows for the future provision of separate, pre-configured ISOs per distro for a more streamlined base installation, which would then trigger the `setup.sh` script.

#### Display Manager Selection

SDDM was re-evaluated as the display manager. Its compatibility with Wayland and its broad availability across the target distributions (Debian, Fedora, openSUSE, Arch Linux) were re-confirmed, reinforcing its selection as the default display manager. SDDM was installed with `sudo apt install sddm --no-install-recommends` to avoid pulling unnecessary desktop environment components.

#### Multi-User Nix Installation

A multi-user Nix installation was performed on the Debian host. This was achieved by executing `sudo sh <(curl -L https://nixos.org/nix/install) --daemon`, setting up the `/nix` directory, the `nix-daemon`, and necessary users and groups for a multi-user environment. The primary user was subsequently added to the `nix` group using `sudo usermod -aG nix yourusername` (although it was later observed that explicit `nix` group membership may not be strictly required for command execution in recent Nix versions). This setup is crucial for enabling multiple system users to manage their own reproducible environments with Home Manager, as a single-user Nix installation would not suffice. The `nixos` channel was later removed as it was deemed unnecessary for a Home Manager setup using flakes in the future.

#### Script Naming Convention Establishment

A consistent naming convention for project scripts was established. The `snake_case` (e.g., `_my_script_name`) and `kebab-case` (e.g., `my-script-name`) conventions were adopted, with a leading underscore (`_`) signifying internal scripts not intended for direct user execution. This promotes modularity and clarity in the codebase, with `setup.sh` serving as the main orchestrator script. For instance, `setup.sh` will call `_debian_main.sh`, which in turn calls `_debian_bootstrap.sh`, `_debian_user.sh`, and `_debian_config.sh`.

#### `setup.sh` Orchestration Logic

The `setup.sh` script is designed as the main entry point for installing and configuring SoulmateOS on a pre-existing minimal Debian installation. Its operation is as follows:
* **Distribution Detection:** `setup.sh` will first attempt to detect the running Linux distribution by checking `/etc/os-release`. If this method is inconclusive, it will proceed to probe for the presence of specific package manager commands (`apt`, `dnf`, `pacman`, `zypper`).
* **Conditional Execution:** Upon successful detection (e.g., `apt` is found, indicating a Debian-based system), `setup.sh` will call the corresponding distribution-specific main script, such as `_debian_main.sh`.
* **Module Calling Order:** Within `_debian_main.sh`, sub-modules will be called in a sequential order to ensure proper dependencies and setup flow:
    1.  `_debian_bootstrap.sh`
    2.  `_debian_user.sh`
    3.  `_debian_config.sh`

#### `_debian_bootstrap.sh` Implementation (Debian)

The `_debian_bootstrap.sh` script is designed to perform the essential foundational steps on the Debian host. Its responsibilities include:
* Installing SDDM using `apt` with the `--no-install-recommends` flag to ensure a minimal installation.
* Executing the multi-user Nix installation command (`sudo sh <(curl -L https://nixos.org/nix/install) --daemon`).
* Implementing the hybrid Wayland WM/Compositor installation logic. This involves an internal auto-detection of the host's package manager within `_debian_bootstrap.sh` itself (re-confirming `apt` for Debian) and then using `apt install` to provision the chosen Wayland WM (e.g., Sway or Wayfire). This approach explicitly handles the `glibc` and ABI compatibility challenges by leveraging the host's native package management.

#### `_debian_user.sh` Implementation (Debian)

The `_debian_user.sh` script is responsible for setting up the user space primarily through Nix. It represents the first phase of heavy Nix integration for user-level packages. This module will ensure the installation of the full suite of user-facing applications using Home Manager's `home.packages` option, once the project formally migrates to Home Manager.

#### `_debian_config.sh` Implementation (Debian)

The `_debian_config.sh` script is tasked with configuring the system's aesthetic and functional aspects on top of the installed packages. This includes managing theming, Waybar configuration, and compositor animations (where applicable and configurable at the user level). It will leverage Home Manager's `home.file` and `programs` modules to declare and symlink relevant configuration files into their appropriate user-level locations, ensuring DE-independent application customization. This script method will be further refined and integrated more deeply with Home Manager once the project migrates into a full Home Manager setup.

#### Wayland WM/Compositor Installation Strategy Pivot

Significant effort was expended on attempting to install Wayland compositors (Hyprland, Sway) via Nix. Initial attempts with Hyprland resulted in critical `gbm` and `glibc` errors, indicating an ABI incompatibility between the Nix-built compositor (linked against `glibc` 2.40) and the Debian 12 host's `glibc` (2.36). While `nixos-22.11` was found to provide a `glibc` version (2.37) closer to Debian 12, the versions of compositors provided (e.g., Hyprland 0.6.1beta) were deemed too outdated. This highlighted a fundamental dilemma: Nixpkgs is primarily developed with NixOS in mind, leading to potential `glibc` mismatches on foreign host systems.

Due to these persistent challenges, a strategic pivot was made regarding Wayland compositor installation. Instead of relying on Nix for WMs, a **hybrid strategy** was adopted. This involves a dedicated, auto-generated script that will detect the host system's package manager (`apt`, `dnf`, `pacman`, `zypper`) and then attempt to install the chosen Wayland WM/Compositor using the host's native package manager. This approach explicitly handles the `glibc` and ABI compatibility challenges by leveraging the host's native package management. Nix/Home Manager will continue to manage all other user-level applications, services, and dotfiles.

#### Wayland WM/Compositor Options for Debian 12

Thorough research was conducted to identify Wayland WMs/Compositors directly available in Debian 12 (Bookworm) stable APT repositories that meet the criteria of supporting animations/rounded corners (natively or via extensions) and Waybar compatibility. The following were definitively confirmed:
* **Sway**: Available, minimalist, extensible for effects.
* **Wayfire**: Available, natively features animations and visual effects.
* **Hyprland**, **River**, **qtile**, **dwl**, and **labwc** were confirmed **NOT available** in Debian 12 (Bookworm) stable repositories, but are present in Debian Sid (Unstable). This limits the immediate options for native Debian 12 installations to Sway and Wayfire.

#### Desktop Environment Integration & Theming Scope

The possibility of including full Desktop Environments (KDE Plasma, GNOME) as default `apt`-installed options was discussed. It was confirmed that these DEs generally only consume significant resources when a user logs into their specific session, not when running a different WM. Their disk space footprint (2-4GB each, including default apps) was deemed acceptable for inclusion as default options, with users able to remove them if desired.

A key challenge identified was achieving a truly unified aesthetic across these full DEs due to their integrated theming pipelines. It was decided that SoulmateOS's "Theming Pipeline 2.0" would focus on unifying the aesthetic of its core applications and custom WMs (Sway, Wayfire). For full DEs like GNOME and KDE Plasma, it will be documented that they retain their own core shell/panel theming, which might not perfectly align with the SoulmateOS aesthetic, allowing users to customize them manually if desired. GTK themes and other application customizations can be managed at the user level without `sudo`.

### Challenges & Resolutions

* **Challenge**: Initial `apt` installations on Debian prompted for "Media change: please insert the disk labeled...".
    * **Resolution**: The `deb cdrom:` entry in `/etc/apt/sources.list` was commented out, followed by `sudo apt update`. This resolved the prompt.
* **Challenge**: `apt install` pulled recommended packages (e.g., full KDE Desktop with SDDM), but `apt remove` only removed the core package, leaving recommended dependencies.
    * **Resolution**: It was clarified that `apt`'s default behavior installs recommends, but `apt remove` only targets the specified package. Subsequent `sudo apt autoremove` is required to clean up orphaned dependencies, including those installed as recommends.
* **Challenge**: Multi-user Nix installation initially seemed to lack the `nix` group, despite commands working, leading to confusion about current Nix access mechanisms.
    * **Resolution**: It was verified that the `nixbld` users are correctly created for isolated builds. It was clarified that modern Nix versions (like 2.30.1) primarily use Polkit rules and Unix socket permissions for unprivileged user access to the `nix-daemon`, making explicit `nix` group membership less strictly required for basic command execution.
* **Challenge**: Nix-installed Wayland compositors (Hyprland, Sway) consistently crashed with `gbm` and `glibc` version mismatch errors when run on Debian 12 (Bookworm).
    * **Resolution**: Through `ldd` analysis, it was confirmed that Nix packages from newer channels (e.g., `nixos-unstable`, `nixos-23.05`) were linked against `glibc` 2.37/2.40, while Debian 12 uses `glibc` 2.36. This ABI incompatibility was identified as the root cause. While switching to `nixos-22.11` made Sway 1.7 work (matching Debian's version), this channel provided very old Hyprland versions. This led to the strategic decision to install WMs via the host package manager.
* **Challenge**: Inaccurate information regarding Wayland WM availability in Debian 12 (Bookworm) stable APT repositories was provided in previous iterations.
    * **Resolution**: Multiple, direct, and thorough verifications of `https://packages.debian.org/bookworm/` were performed. It was definitively confirmed that only Sway and Wayfire are available in Debian 12 stable repositories, while Hyprland, River, Qtile, dwl, and labwc are only in Debian Sid (Unstable).

### Testing & Validation

* **`apt` configuration**: The solution for the "Media change" prompt was validated by running `sudo apt update` after modifying `sources.list`, confirming the prompt's absence.
* **`apt` cleanup**: The `sudo apt autoremove` command was tested after `sudo apt remove` to verify the removal of recommended packages.
* **Multi-user Nix installation**: Verified by running `nix --version` and `nix profile install nixpkgs#htop` as a regular user (without `sudo`), confirming successful unprivileged access to the Nix store and daemon. `systemctl status nix-daemon` was used to confirm daemon operation.
* **Wayland Compositor Launch**: Sway (installed via `apt`) was successfully launched from a TTY, confirming the host's graphics stack was functional. Sway (installed via Nix from `nixos-22.11`) was successfully launched from a TTY, confirming `glibc` compatibility for that specific version. Crash reports were analyzed for `gbm` and `glibc` errors during failed compositor launches.
* **Channel Switching**: The process of removing and adding Nix channels (e.g., to `nixos-21.05`, `nixos-22.11`) was performed, and `nix-channel --list` was used to verify the active channel. `sway --version` and `ldd $(which sway)` were used to confirm the actual `sway` version and its `glibc` linkage after channel changes.

### Outcomes

This development cycle yielded several critical outcomes:

* A refined, pragmatic installation strategy was adopted, combining user-driven minimal Debian installation with a robust `setup.sh` orchestrator for post-install configuration and SoulmateOS deployment.
* A fully functional multi-user Nix environment was established on the Debian host, with a clear understanding of modern Nix access mechanisms (Polkit/sockets) over legacy group membership.
* A definitive understanding of the `glibc` compatibility challenges between Nix-built Wayland compositors and Debian 12 was achieved. This led to the crucial decision to install Wayland WMs/Compositors (Sway, Wayfire) via the host's `apt` package manager for stability, while retaining Nix for all other user-level applications and configurations.
* A thoroughly verified and corrected list of Wayland WMs/Compositors available in Debian 12 (Bookworm) stable repositories was compiled, confirming Sway and Wayfire as the primary options.
* The scope of the theming pipeline was clarified: it will unify aesthetics for core applications and custom WMs, with documentation for users regarding potential visual discrepancies when opting for full DEs like GNOME or KDE Plasma.

## Reflection

This development cycle underscored the profound complexities inherent in building a cross-distribution "Desktop Environment Manager" that leverages a declarative system like Nix on top of diverse imperative host operating systems. The persistent `glibc` and ABI compatibility issues, particularly with low-level graphical components, served as a practical validation of the project's initial strategic pivot away from rigid host OS assumptions. While the ideal of a purely Nix-managed graphical stack on any host proved challenging in practice, the adoption of a pragmatic hybrid installation strategy for Wayland compositors represents a significant step towards achieving the project's core mission of delivering a highly personalized and reproducible desktop experience. This iterative process of identifying challenges, attempting solutions, and adapting strategies is fundamental to navigating the intricate landscape of Linux desktop development. The realistic assessment of the project's scope, now clearly extending into a multi-month to year-long effort, is a testament to its ambition and the depth of the technical work involved.
