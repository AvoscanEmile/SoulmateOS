# SoulmateOS Roadmap

A structured, modular approach to building a lightweight, secure, and cohesive Linux-based environment using AlmaLinux Minimal and Qtile, evolving into a cross-distribution meta-distro platform.

## Phase 0 — Github repo creation

**Goal:** Create the github repo with the basic structure, and the initial documentation.

* Add every relevant folder the project will have
* Add architecture.md, changelog.md, and roadmap.md to /docs
* Write initial `README.md`
* Choose a license.
* **Version Tag:** `0.1.0`

## Phase 1 — AlmaLinux installation and Qtile installation

**Goal:** Set the barebones of the project in place.

* Install Alma Linux
* Install Qtile and X11
* Install a lightweight login manager
* Boot into graphical environment
* Install minimal terminal and file manager
* **Version Tag:** `0.2.0`

## Phase 2 — System Utilities Layer + Git Setup

**Goal:** Add foundational system tools to ensure a robust and manageable base. Add git to host a local repo, to keep track of any config changes.

* Terminal emulator
* File manager
* Text editor
* Network manager
* System monitor
* Disk utility
* Time synchronization daemon (e.g., chrony or ntp)
* Package manager plugins (preinstalled, verify only)
* Log management tools (journalctl, logrotate)
* **Version Tag:** `0.3.0`

## Phase 3 — User Applications Layer

**Goal:** Add commonly expected user-facing applications.

* Web browser
* Media player
* Office/markdown tool
* Image viewer
* Archiver
* Password manager
* PDF viewer
* Calendar
* **Version Tag:** `0.4.0`

## Phase 4 — UX Enhancers & Session Polish

**Goal:** Complete the user experience with session utilities.

* Notification daemon
* Screenshot tool
* Clipboard manager
* Autostart configuration
* **Version Tag:** `0.5.0`

## Phase 5 — Theming, Visual Cohesion, Widget Addition and Error Correction.

**Goal:** Build a unified aesthetic, a base widget environment and resolve any problems related to app usage.

* Install and theme Polybar with the following modules (power menu, workspaces, weather, date and time, network + volume)
* Build relevant custom widgets with Eww. Build one for the each of the relevant modules (weather, date and time, network + volume)
* Add a dropdown grid-like widget layout where all the system information shows up
* Configure all relevant Qtile keybindings
* GTK theming all relevant apps
* Fonts and icons
* Wallpaper, cursor
* Align visuals across all apps
* Lightweight compositor (picom) for transparency, shadows, and effects
* Save everything relevant in `themes/`
* Add the symlinking and installation process to their relevant files
* **Version Tag:** `0.6.0`

## Phase 6 — Security Hardening

**Goal:** Lightweight but strong security baseline.

* Configure `firewalld` or `nftables`
* Harden SSH (disable root, change port)
* Enable SELinux
* Disable unnecessary services
* Document security in `docs/security.md`
* **Version Tag:** `0.7.0`

## Phase 7 — Automation, Optimization and Reproducibility

**Goal:** Optimize and automate deployment of the entire environment.

* Minimize default packages with the usage of dng-graph
* Bash or Ansible-based installer
* Dotfile deployment
* Scripted security and config setup
* Test in VM for reproducibility
* **Version Tag:** `0.8.0`

## Phase 8 — Finalization and 1.0 Release

**Goal:** Final testing, cleanup, and release.

* Final QA and stress test
* Polish all documentation
* Tag release as `1.0.0`
* Optional: Build ISO
* **Version Tag:** `1.0.0`

## Phase 9 — Core OS Foundation & Cross-Distro Base Integration

**Goal:** Establish the minimal, essential host distribution layer on multiple target distributions, ensuring a functional graphical base system for Nix to build upon. This phase defines the boundaries between the host distribution's responsibilities and Nix's capabilities.

* **9.1 Distribution Landscape Analysis & Selection:** Identify 2-3 target major distributions (e.g., AlmaLinux, Debian/Ubuntu, Fedora, Arch) for initial compatibility. Research their package managers (`apt`, `dnf`, `pacman`), init systems (`systemd` specifics), and common filesystem layout variations.
* **9.2 Minimal Core OS Installation Scripting:** Develop a base installation script (`installation.sh`) that performs a standard minimal installation of the chosen host distribution.
* **9.3 Essential System-Level Components Installation:** Implement conditional logic within `installation.sh` to install the few *additional* essential system-level components for a graphical base, managed by the host distro's package manager:
    * `dbus`, `polkit`
    * X.Org Server, Mesa, & Core X11 Libraries (`base-x` or equivalents)
    * Wayland Protocol Libraries & Xwayland
    * Display Manager (`sddm` recommended, or `gdm`/`lightdm`)
    * Networking components (`NetworkManager`, etc.)
    * Filesystem support (`udisks2`, `gvfs`, etc.)
    * Essential shared libraries (`libstdc++`, `zlib`, etc.)
    * Basic console tools and system security frameworks (`firewalld`/`ufw`, SELinux/AppArmor)
* **9.4 Configure Default Graphical Target:** Ensure `sudo systemctl set-default graphical.target` is executed to boot into the graphical environment.
* **Version Tag:** `1.1.0`

## Phase 10 — Nix Integration & Initial User Environment Deployment

**Goal:** Integrate Nix as the declarative manager for the user environment, building upon the established host OS foundation.

* **10.1 Nix Package Manager Installation:** Implement the installation of the Nix package manager on the host system.
* **10.2 SoulmateOS Home Manager Configuration Repository Cloning:** Script the cloning of the `home.nix` configuration repository (the future default "rice" profile).
* **10.3 Initial Home Manager Activation:** Implement the initial activation of Home Manager using the cloned configuration, declaratively deploying the default user desktop environment (e.g., Wayland compositor, X11 WM, default terminal).
* **10.4 Basic Environment Validation:** Verify that the display manager loads, the chosen window manager/compositor starts, and a terminal (e.g., Kitty, if Nix-managed) can be opened.
* **Version Tag:** `1.2.0`

## Phase 11 — `soul` CLI Development: Imperative Control Foundation

**Goal:** Develop the core `soul` command-line interface for imperative package management and the "dirty state" detection mechanism.

* **11.1 `soul install <package-name>` Implementation:** Develop the initial `soul install` command to perform immediate user-level imperative installations using `nix-env -iA nixpkgs.<package-name>` (or `nix profile install nixpkgs#<package-name>`).
* **11.2 `soul remove <package-name>` Implementation:** Develop the initial `soul remove` command to perform immediate user-level imperative removals using `nix-env -e <package-name>`.
* **11.3 Mutable Package Cache (`installed_packages.json`):** Implement the creation and management of a SoulmateOS-managed mutable cache file (e.g., `~/.local/share/soulmateos/installed_packages.json`) to track imperatively installed/removed packages.
* **11.4 "Dirty State" Detection (Initial):** Implement a mechanism to detect unsaved manual changes in monitored user configuration directories before any `home-manager switch` operation.
* **11.5 User Prompting for Unsaved Changes:** Integrate basic user prompts (save, discard, cancel) when unsaved changes are detected.
* **Version Tag:** `1.3.0`

## Phase 12 — `soul save` & Declarative State Conservation

**Goal:** Implement the pivotal `soul save` command to translate imperative user modifications into a declarative Nix configuration.

* **12.1 Monitored Directories Definition:** Define the set of user-owned directories (e.g., `~/.config/`, `~/.local/share/`) that `soul save` will monitor for changes.
* **12.2 Configuration File Change Capture:** Develop the logic to compare current file content against a baseline and capture modified or newly created text-based configuration files.
* **12.3 Dynamic `home.nix` Generation (File References):** Implement dynamic generation of a new Nix module (e.g., `auto-generated-config.nix`) that uses `home.file."<path>".source = ./path/to/file;` to declaratively manage captured configuration files. Ensure the actual files are copied into a SoulmateOS-managed local repository structure.
* **12.4 Package List Synchronization:** Implement the logic within `soul save` to read `installed_packages.json` and update the `home.packages` list in the main `home.nix` configuration.
* **12.5 Declarative Deployment Trigger:** Trigger `home-manager switch` after updating the declarative configuration to apply changes and create a new generation.
* **Version Tag:** `1.4.0`

## Phase 13 — "Rice" Management: `soul save-de` & `soul switch-de`

**Goal:** Implement the "rice" (Desktop Environment profile) management system, allowing users to save and switch between distinct DEs.

* **13.1 `soul save-de <de-name>` Implementation:** Develop the command to create a persistent Nix GC root pointing to the current active Home Manager generation, preventing it from being garbage collected.
* **13.2 `soul switch-de <de-name>` Implementation:** Develop the command to switch to a saved DE generation using `home-manager switch --switch-to <path-to-de-generation>`.
* **13.3 Graphical Session Restart/Prompt:** Integrate a mechanism to prompt for or attempt a graphical session restart after switching DEs.
* **13.4 Default "Rice" Profiles:** Prepare 5-6 default "rice" profiles (Nix configurations) to be shipped with SoulmateOS, leveraging the 1.0.0 environment as the base for one of these.
* **Version Tag:** `1.5.0`

## Phase 14 — Robustness, Usability & Documentation Refinement

**Goal:** Enhance the reliability, user-friendliness, and documentation of the entire SoulmateOS system.

* **14.1 Comprehensive Error Handling:** Implement robust error handling and informative messages across all `soul` commands and installation scripts.
* **14.2 Idempotency & Basic Rollback:** Ensure all scripts are idempotent and consider basic rollback mechanisms for installations/rice applications.
* **14.3 Improved User Interaction:** Refine user prompts and interactive choices within all `soul` commands (e.g., clearer "dirty state" options).
* **14.4 Initial Troubleshooting Guides:** Develop clear documentation for common troubleshooting scenarios, especially related to SELinux.
* **14.5 User Guidelines Enforcement:** Document clear guidelines for users regarding actions outside `soul` commands and their implications, emphasizing that following guidelines ensures support.
* **Version Tag:** `1.6.0`

## Phase 15 — Community, Advanced Features & Performance

**Goal:** Foster a community-driven ecosystem, explore performance optimizations, and lay groundwork for advanced "rice" features.

* **15.1 "Rice" Showcase & Discovery (Conceptual):** Plan a mechanism for users to discover and browse available SoulmateOS "rices" (e.g., a dedicated GitHub topic, simple web page).
* **15.2 Contributing Guidelines for "Rice" Creators:** Create detailed guidelines for "rice" creators, including best practices, licensing, and packaging standards for `soul save` compatibility.
* **15.3 Performance Optimization Review:** Review and optimize script execution speed and resource usage, particularly for `soul save` with larger configurations.
* **15.4 Meta-Distro Documentation Expansion:** Update `architecture.md` and other documentation to fully reflect the meta-distro vision, supported distributions, installation nuances, and troubleshooting.
* **15.5 Optional: "Rice" Versioning & Dependencies (Research):** Begin research into potential versioning for "rices" and handling inter-rice dependencies.
* **Version Tag:** `1.7.0`

## Phase 16 — SoulmateOS 2.0.0 Final Release

**Goal:** Conduct final testing, comprehensive documentation, and officially release SoulmateOS 2.0.0 as a cross-distribution meta-distro platform with robust "imperative editing, declarative conservation" management.

* **16.1 Final QA & Stress Testing:** Extensive testing across all supported distributions, focusing on stability, performance, and seamless integration of all components and `soul` commands.
* **16.2 Comprehensive Documentation Polish:** A thorough review and polish of all project documentation, ensuring accuracy, clarity, and completeness for new and existing users.
* **16.3 Community Launch & Announcement:** Prepare release announcements and engage with the community to introduce the new capabilities of SoulmateOS 2.0.0.
* **16.4 Tag Release:** Officially tag the `2.0.0` version in the Git repository.
* **Version Tag:** `2.0.0`

## Summary Table

| Phase | Focus Area | Tag |
|---|---|---|
| 0 | Bootstrap + Git + Docs | `0.1.0` |
| 1 | Qtile Base Setup | `0.2.0` |
| 2 | System Utilities Layer | `0.3.0` |
| 3 | User Applications Layer | `0.4.0` |
| 4 | UX Enhancers & Session Polish | `0.5.0` |
| 5 | Theming & Visual Integration | `0.6.0` |
| 6 | Security Hardening | `0.7.0` |
| 7 | Automation, Optimization and Reproducibility | `0.8.0` |
| 8 | QA + Docs + Final Release | `1.0.0` |
| 9 | Core OS Foundation & Cross-Distro Base Integration | `1.1.0` |
| 10 | Nix Integration & Initial User Environment Deployment | `1.2.0` |
| 11 | `soul` CLI Development: Imperative Control Foundation | `1.3.0` |
| 12 | `soul save` & Declarative State Conservation | `1.4.0` |
| 13 | "Rice" Management: `soul save-de` & `soul switch-de` | `1.5.0` |
| 14 | Robustness, Usability & Documentation Refinement | `1.6.0` |
| 15 | Community, Advanced Features & Performance | `1.7.0` |
| 16 | SoulmateOS 2.0.0 Final Release | `2.0.0` |
