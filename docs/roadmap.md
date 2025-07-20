# **SoulmateOS Roadmap v2.0**

## **Introduction**

This document outlines the official development roadmap for SoulmateOS. The project's mission is to create a cross-distro "Desktop Environment Manager" that allows users to build a deeply personalized and reproducible desktop environment on top of any major Linux distribution. This is achieved through an innovative "imperative editing, declarative conservation" model, which combines intuitive, direct modification with the power of a declarative Nix-based backend.

The plan below is structured as a series of comprehensive phases, charting the course from our validated foundational work to the final, stable `v1.0.0` release. Each phase represents a significant development milestone with a corresponding version tag. The preamble that follows this introduction provides crucial context on the project's history and the strategic pivot that led to this current, validated development plan.

## **Phase 1: Foundational Validation & Core Environment Setup**

**High-Level Goal:** To establish a stable, minimal, and reproducible base system on Debian that explicitly validates the compatibility between the host OS and a Nix-managed graphical stack, preventing a repeat of the AlmaLinux failure.

**Breadth and Depth of Tasks:**
* **1.1 Host OS Installation & Configuration:**
    * Script the installation of a minimal, headless Debian system, codifying the successful manual process from Devlog 21. This includes automating UEFI/BIOS settings checks, disk partitioning (with a dedicated EFI partition), and forcing GRUB installation to the removable media path for maximum compatibility.
    * Install essential host-level system packages required for a graphical environment, such as `sddm`, `xwayland`, core Wayland libraries, and `libglvnd-glx`.
* **1.2 Nix Integration & Graphics Stack Validation:**
    * Install the Nix package manager on the Debian host.
    * Use Nix to install a core set of graphical packages: `hyprland`, `kitty`, and the latest stable `mesa` drivers. This is the most critical validation step.
    * Create a minimal, valid `hyprland.conf` to handle basic inputs and launch a terminal.
* **1.3 Session Management & Integration:**
    * Create a `hyprland.desktop` file for SDDM to discover the Wayland session.
    * Diagnose and resolve the SDDM user-session discovery issue encountered in Devlog 21. This may involve creating a system-level session file that launches a user-level script, ensuring a seamless login experience.
    * **Success Metric:** The user can successfully log in via SDDM and be dropped into a functional Hyprland session where a Nix-managed Kitty terminal can be opened without any `gbm` or `EGL` errors.

## **Phase 2: Declarative User Environment & Application Layer**

**High-Level Goal:** To build the complete, functional desktop by declaratively managing the entire user environment with Nix Home Manager, thereby avoiding the ad-hoc integration problems identified in Devlog 20.

**Breadth and Depth of Tasks:**
* **2.1 Home Manager Implementation:**
    * Install and configure Nix Home Manager as the single source of truth for the user's environment.
    * Structure the Home Manager configuration into logical, modular files (e.g., `apps.nix`, `services.nix`, `theming.nix`).
* **2.2 Application Suite Deployment:**
    * Using the `home.packages` option in Home Manager, install the full suite of user-facing applications selected in `architecture.md`. This includes:
        * **Core Tools:** Thunar, Geany, Rofi.
        * **Media Stack:** Firefox, Celluloid, Lollypop, gThumb.
        * **Utilities:** Engrampa, Evince, Foliate, Calcurse.
* **2.3 Declarative Service Management:**
    * Utilize Home Manager's `services` module to manage background daemons like `xfce4-notifyd` and `xfce4-clipman`. This approach ensures services are started correctly with the proper environment, directly solving the D-Bus "split-brain" and `PATH` issues from Devlog 20.
    * **Success Metric:** A fully-featured, application-rich desktop is deployed from a single `home-manager switch` command.

## **Phase 3: Visual Cohesion & Theming Pipeline Implementation**

**High-Level Goal:** To implement the "Theming Pipeline 2.0" architecture designed in Devlog 20 to create the project's signature unified aesthetic across all system components.

**Breadth and Depth of Tasks:**
* **3.1 Build the Theming Pipeline Engine:**
    * Create the central `themes.conf` file to act as a master source for all non-GTK color variables (e.g., full 16-color ANSI palettes).
    * Develop the `apply-themes.sh` script, which reads from `themes.conf` and the live GTK settings to programmatically generate configuration files for all target applications.
* **3.2 System-Wide Theme Deployment:**
    * Manage the base GTK theme (Nordic), icons (nordzy), and cursors (Layan-white-cursors) via Home Manager.
    * Use the pipeline to apply consistent theming to:
        * Kitty terminal (foreground, background, all ANSI colors).
        * The Wayland status bar/widgets that will replace Polybar.
        * Rofi's `.rasi` configuration file.
        * Geany's internal color schemes.
* **3.3 Compositor and WM Configuration:**
    * Fully configure Hyprland for aesthetics, including window borders, gaps, corner radius, animations, and shadows to align with the overall theme.
    * Establish a complete and intuitive set of keybindings for all window management, application launching, and system controls.
    * **Success Metric:** The entire desktop environment, from the login screen to every application, shares a single, consistent, and professionally designed visual language.

## **Phase 4: System Automation & Reproducibility Scripting**

**High-Level Goal:** To create a fully automated, idempotent installation process that can deploy the entire SoulmateOS environment from a bare Debian install to a fully configured desktop.

**Breadth and Depth of Tasks:**
* **4.1 Develop the Installation Orchestrator (`install.sh`):**
    * This master script will guide the entire process.
    * It will handle command-line flags (e.g., `--hardened`, `--developer`) to install different sets of packages as planned in the original architecture.
* **4.2 Host OS Setup Module:**
    * This sub-script, called by the orchestrator, will automate the Debian installation steps defined in Phase 1. It must be able to run on a bare-metal or VM target.
* **4.3 SoulmateOS Deployment Module:**
    * This module takes over post-reboot. It will:
        1.  Install the Nix package manager.
        2.  Clone the project's Home Manager configuration repository from Git.
        3.  Execute the first `home-manager switch` to build and deploy the entire user environment.
    * **Success Metric:** A single command (`./install.sh`) can be executed on a machine with a Debian installer USB, resulting in a fully installed and configured SoulmateOS system with no further manual intervention required.

## **Phase 5: `soul` CLI for Declarative State Management**

**High-Level Goal:** To build the `soul` CLI, the primary user-facing tool for managing the system via the "imperative editing, declarative conservation" model outlined in the original roadmap.

**Breadth and Depth of Tasks:**
* **5.1 Develop Imperative Wrapper Commands:**
    * Implement `soul install <package>` and `soul remove <package>` to modify the user's Nix profile while also updating a state-tracking file (e.g., `installed_packages.json`).
* **5.2 Implement Change Detection:**
    * Create a mechanism for the `soul` tool to hash or otherwise track the state of key configuration files within monitored directories like `~/.config`.
    * Develop `soul status` to report on packages that have been imperatively changed and config files that have been modified since the last `save`.
* **5.3 Build the Declarative Conservation Engine (`soul save`):**
    * This is the cornerstone of the phase. The `soul save` command must:
        1.  Read the `installed_packages.json` cache and update the `home.packages` list in the Nix configuration.
        2.  Compare current config files against their baseline and copy any modified files into the local Git repository.
        3.  Programmatically generate or update a Nix module (e.g., `auto-generated.nix`) to point `home.file` declarations to these newly saved files.
        4.  Trigger a `home-manager switch` to apply the newly declared state, creating a new, persistent generation.
    * **Success Metric:** A user can install a new application, tweak a config file manually, and run `soul save` to make those changes a permanent, declarative part of their system configuration.

## **Phase 6: Multi-Profile Architecture & Cross-Distro Expansion**

**High-Level Goal:** To abstract the complete desktop environment into swappable "rices" and validate the installation process on at least one other major Linux distribution family, fulfilling the meta-distro vision.

**Breadth and Depth of Tasks:**
* **6.1 Implement "Rice" Management:**
    * Develop `soul save-de <de-name>` to create a persistent GC root for the current Home Manager generation, effectively saving a snapshot of the entire DE.
    * Develop `soul switch-de <de-name>` to activate a previously saved generation.
* **6.2 Package Default Profiles:**
    * Package the main SoulmateOS theme as the default "rice."
    * Create at least two other distinct "rices" (e.g., one ultra-minimalist, one more feature-rich) to demonstrate the flexibility of the system and provide users with out-of-the-box choices.

* **Success Metric:** On the Debian reference system, a user can create, save, and switch between multiple distinct desktop profiles using the soul CLI.
## **Phase 7: Fedora Family Integration**
**High-Level Goal:** To achieve full feature-parity and automated installation on Fedora, the second major target distribution family.
* **7.1 Host Environment Analysis:**
    * Research Fedora's minimal installation process and identify the equivalent base packages for a graphical session (e.g., Wayland libraries, Mesa drivers, SDDM).
    * Analyze default security configurations, specifically SELinux, and develop troubleshooting guides or configuration adjustments to ensure Nix-managed applications run without issues.
* **7.2 Develop Fedora Installer Module:**
    * Create a new script module (`install/fedora.sh`) for the installation orchestrator. This module will handle Fedora-specific tasks, using `dnf` for host package installation.
* **7.3 Adapt Dependency Mapping:**
    * Update the main `install.sh` script to recognize a `--distro=fedora` flag and call the appropriate module with the correct package names.
* **7.4 Full-Stack Validation:**
    * Execute a complete, automated installation and testing cycle on a Fedora target. Document and resolve any distribution-specific bugs or incompatibilities.

## **Phase 8: Arch Family Integration**
**High-Level Goal:** To expand support to the Arch Linux ecosystem, accommodating its rolling-release nature and distinct packaging tools.
* **8.1 Host Environment Analysis:**
    * Map the required host dependencies to their package names in the official Arch repositories.
    * Investigate if any essential dependencies would need to be sourced from the Arch User Repository (AUR) and plan the automation strategy accordingly.
* **8.2 Develop Arch Installer Module:**
    * Create an `install/arch.sh` module that uses `pacman` for host system setup. This will likely involve scripting `pacstrap` for the base installation.
* **8.3 Testing on a Rolling Base:**
    * Perform full-stack validation on a fresh Arch Linux installation. Pay special attention to potential breakages that could be caused by the rolling-release model and document a clear support policy.

## **Phase 9: openSUSE Family Integration**
**High-Level Goal:** To complete the core cross-distro support by integrating with the openSUSE family.
* **9.1 Host Environment Analysis:**
    * Research openSUSE's "patterns" system for installation and identify the minimal set required for a graphical host.
    * Map dependencies to their `zypper` package names.
* **9.2 Develop openSUSE Installer Module:**
    * Create an `install/opensuse.sh` module to handle system setup using `zypper`.
* **9.3 Final Integration Testing:**
    * Conduct a full installation and testing cycle on a target openSUSE system (e.g., Tumbleweed) to ensure complete functionality.

## **Phase 10: Finalization, Community, and 2.0.0 Release**
**High-Level Goal:** To polish the project, its documentation, and its community resources for an official 2.0.0 release as a mature, cross-distribution platform.
* **10.1 Comprehensive QA and Hardening:**
    * Conduct a final round of stress testing and QA across all four supported distribution families (Debian, Fedora, Arch, openSUSE).
    * Implement the final security hardening measures as outlined in the original `architecture.md` on all platforms.
* **10.2 Documentation and Community Resources:**
    * Perform a thorough review and polish of all project documentation, ensuring it is clear, accurate, and complete for users on any supported distro.
    * Create detailed contribution guidelines for users who want to submit new "rices" or bug fixes.
* **10.3 Official Release:**
    * Prepare official release announcements for the community.
    * Tag the `2.0.0` version in the Git repository, marking the completion of the meta-distro vision.

## Summary Table

| Phase | Focus Area                                         | Target Tag      |
|:------|:---------------------------------------------------|:----------------|
| (Legacy) | Archived AlmaLinux/X11 Prototype                  | `v0.6.0-legacy` |
| 1     | Foundational Validation & Core Environment Setup   | `v0.1.0`        |
| 2     | Declarative User Environment & Application Layer   | `v0.2.0`        |
| 3     | Visual Cohesion & Theming Pipeline Implementation  | `v0.3.0`        |
| 4     | System Automation & Reproducibility Scripting      | `v0.4.0`        |
| 5     | `soul` CLI for Declarative State Management        | `v0.5.0`        |
| 6     | Multi-Profile "Rice" Architecture                  | `v0.6.0`        |
| 7     | Fedora Family Integration                          | `v0.7.0`        |
| 8     | Arch Family Integration                            | `v0.8.0`        |
| 9     | openSUSE Family Integration                        | `v0.9.0`        |
| 10    | Finalization, Community, and Stable Release        | `v1.0.0`        |

## Note on the Original Vision of the Project

The SoulmateOS project began with the goal of creating a personalized, minimal environment on a stable, enterprise-grade foundation. However, even before significant implementation began, the project's vision underwent a major conceptual evolution. The focus shifted from creating a simple "Linux flavor" to a far more ambitious goal: developing a cross-distro "Desktop Environment Manager". The new core philosophy was to treat the host OS as a minimal, reliable base, while managing the entire user-facing environment—from the window manager to the applications and dotfiles—declaratively with Nix.

A key innovation in this new design was the principle of "imperative editing, declarative conservation". This model would allow users to intuitively modify their system through a simple `soul` command-line tool, with their changes being saved back into a reproducible Nix configuration, keeping the complexity of the underlying engine invisible. The project's identity had matured into a tool for democratizing highly customized and reproducible desktops.

The subsequent development work on AlmaLinux became the first practical test of this new, grander vision. The initial results were fraught with friction. Attempts to manually integrate Nix-managed services with the host's D-Bus and `systemd` layers proved brittle, highlighting the challenges of layering a modern declarative system onto a traditional host. This was followed by a series of definitive, unresolvable failures. First, a fundamental `glibc` version mismatch on AlmaLinux 9 made it impossible to run modern Nix-managed applications. Then, an attempted migration to AlmaLinux 10 was thwarted by the deprecation of Xorg sessions and, ultimately, by insurmountable graphics driver incompatibilities between the Nix-packaged Wayland stack and the host system.

These technical dead ends were not merely setbacks; they were the practical validation that the project's evolved, cross-distro vision was not just preferable, but the *only* viable path forward. The experience proved that a stable but rigid enterprise-focused OS could not serve as the foundation for the flexible, user-centric environment SoulmateOS aimed to be. The pivot to a Debian base and a roadmap focused on supporting the four major desktop distribution families is, therefore, not a retreat, but the first deliberate step in executing the project's fully-realized and more ambitious mission. This roadmap reflects that journey and outlines the validated plan to deliver a truly next-generation desktop management experience. 

If you want to see what was the original conceptualization of this roadmap, you can read the old roadmaps in the history of this file. If you want to go into detail about the reconceptualization of the project, it's outlined in `devlogs/17-entry.md`, `devlogs/20-entry.md`, and `devlogs/21-entry.md`.
