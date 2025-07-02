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
* **Version Tag:** `0.9.0`

## Phase 8 — Finalization and 1.0 Release

**Goal:** Final testing, cleanup, and release.

* Final QA and stress test
* Polish all documentation
* Tag release as `1.0.0`
* Optional: Build ISO
* **Version Tag:** `1.0.0`

## Phase 9 — Meta-Distro Foundation: Cross-Distribution Research & Core Adaptation (Towards 2.0.0)

**Goal:** Lay the groundwork for cross-distribution compatibility by thoroughly researching target distributions and adapting core components.

* **9.1 Distribution Landscape Analysis:** Identify 2-3 target major distributions (e.g., Debian/Ubuntu, Fedora, Arch) for initial compatibility. Research their package managers (`apt`, `dnf`, `pacman`), init systems (`systemd` specifics), and common filesystem layout variations.
* **9.2 Core Component Dependency Mapping:** For Qtile, Polybar, Eww, Picom, and Kitty, map their essential runtime dependencies across the selected target distributions. Identify commonalities and divergences in package names.
* **9.3 Installation Script Modularity Refinement:** Refactor the existing `installation.sh` script to introduce modular functions or sections for distro-specific package installation and service management. Begin implementing initial distro detection logic.
* **9.4 Base Configuration Abstraction:** Review existing dotfiles and configurations (e.g., Qtile `config.py`, Polybar configs) to identify AlmaLinux-specific paths or commands that need to be abstracted or made conditional for other distributions.
* **Version Tag:** `1.1.0`

## Phase 10 — Meta-Distro Development: Core Component Cross-Compatibility

**Goal:** Achieve functional core SoulmateOS component installations on at least two new target distributions beyond AlmaLinux.

* **10.1 Package Installation Implementation:** Implement the conditional logic within `installation.sh` to correctly install core SoulmateOS dependencies using the native package manager of the detected distribution.
* **10.2 Service & Autostart Adaptation:** Ensure Qtile, Picom, and other necessary background services/autostart entries function correctly across target distributions (e.g., `systemctl` usage, `xinitrc`/`xsession` differences).
* **10.3 Basic Environment Validation:** Perform initial installation tests on virtual machines for each new target distribution. Verify Qtile starts, a terminal (Kitty) opens, and the display manager (if applicable) loads correctly.
* **10.4 Common Configuration Adjustments:** Address any immediate functional breaks related to configuration paths or commands that differ between AlmaLinux and the new target distributions.
* **Version Tag:** `1.2.0`

## Phase 11 — Meta-Distro Expansion: Theme & UX Layer Porting

**Goal:** Extend cross-distribution compatibility to the theming, visual cohesion, and UX enhancer layers, ensuring a consistent user experience regardless of the underlying distro.

* **11.1 GTK & Icon Theme Cross-Compatibility:** Verify the GTK theme (Nordic), icon theme (Nordzy), and cursor theme (Layan-white-cursors) are correctly applied across new distributions. Address any pathing or GTK version-specific issues (GTK3 vs. GTK4).
* **11.2 Polybar & Eww Adaptation:** Ensure Polybar and Eww widgets function correctly across distributions, accounting for potential differences in `sysfs` paths, network interface naming, or specific command-line utilities.
* **11.3 UX Enhancer Integration:** Integrate `xfce4-clipman`, `xfce4-notifyd`, and `xfce4-screenshooter` to function reliably on new distributions, addressing any missing dependencies or service startup issues.
* **11.4 Font Management Across Distros:** Verify font installation and rendering consistency, accounting for different font caching mechanisms or system font directories.
* **Version Tag:** `1.3.0`

## Phase 12 — "Rice" Management System: `install-rice` Development & Alpha

**Goal:** Develop a functional alpha version of the `install-rice` command, enabling basic "rice" installation from GitHub.

* **12.1 `install-rice` Script Core:** Develop the initial `install-rice` bash script to clone a specified GitHub repository.
* **12.2 Basic Dotfile Symlinking/Copying:** Implement logic to identify common dotfile directories within the "rice" repository and create symlinks or copy them to the user's `~/.config/` or `~/.local/share/` directories.
* **12.3 `install-rice` Basic Validation:** Test the `install-rice` command with a few simple, pre-defined "rice" repositories.
* **12.4 Error Handling & User Feedback (Basic):** Implement basic error checking (e.g., repo not found, insufficient permissions) and provide clear command-line feedback to the user.
* **Version Tag:** `1.4.0`

## Phase 13 — "Rice" Management System: `create-rice` Development & Standardization

**Goal:** Develop the `create-rice` command, streamlining the packaging of user dotfiles into a standardized "rice" repository format, and define the "rice" repository structure.

* **13.1 `create-rice` Script Core:** Develop the initial `create-rice` bash script to identify and collect common SoulmateOS dotfiles and configuration directories from the user's system.
* **13.2 Standardized Rice Repository Structure:** Define a clear and consistent directory structure for SoulmateOS "rice" repositories (e.g., `qtile/`, `polybar/`, `eww/`, `gtk/`, `icons/`, `themes/`, `fonts/`).
* **13.3 Metadata & Licensing Integration:** Implement functionality within `create-rice` to prompt for and include essential metadata (author, description, license) in the generated repository.
* **13.4 Automated Packaging & Git Init:** Automate the packaging of collected dotfiles into the standardized structure and initialize a new Git repository ready for user upload.
* **Version Tag:** `1.5.0`

## Phase 14 — Meta-Distro & Rice System: Robustness & Usability Refinement

**Goal:** Enhance the robustness, error handling, and user-friendliness of both the cross-distribution installer and the "rice" management system.

* **14.1 Comprehensive Error Handling:** Implement robust error handling and informative messages throughout the `installation.sh`, `install-rice`, and `create-rice` scripts.
* **14.2 Idempotency & Rollback Mechanisms:** Ensure all scripts are idempotent (can be run multiple times without adverse effects) and consider basic rollback mechanisms for installations/rice applications.
* **14.3 User Interaction & Prompts:** Improve user prompts and interactive choices within the installer and rice commands (e.g., "Do you want to install X?", "Select rice variant").
* **14.4 Performance Optimization:** Optimize script execution speed and resource usage where possible.
* **14.5 Automated Testing Framework:** Begin developing automated tests for the installer and rice commands to ensure consistency and prevent regressions across different distributions.
* **Version Tag:** `1.6.0`

## Phase 15 — Community & Documentation: Ecosystem Foundation

**Goal:** Foster a community-driven ecosystem around SoulmateOS "rices" and comprehensively document the new meta-distro capabilities.

* **15.1 "Rice" Showcase & Discovery:** Plan and potentially implement a mechanism for users to discover and browse available SoulmateOS "rices" (e.g., a dedicated GitHub topic, a simple web page).
* **15.2 Contributing Guidelines:** Create detailed guidelines for "rice" creators, including best practices, licensing considerations, and submission processes.
* **15.3 Meta-Distro Documentation:** Update the `architecture.md` and other documentation to fully reflect the meta-distro vision, including supported distributions, installation nuances, and troubleshooting tips.
* **15.4 Version Control & Release Process for 2.0.0:** Finalize the versioning strategy and release process for the 2.0.0 major release, including beta testing periods.
* **Version Tag:** `1.7.0`

### Phase 16 — SoulmateOS 2.0.0 Final Release

**Goal:** Conduct final testing, comprehensive documentation, and officially release SoulmateOS 2.0.0 as a cross-distribution meta-distro platform with robust "rice" management.

* **16.1 Final QA & Stress Testing:** Extensive testing across all supported distributions, focusing on stability, performance, and the seamless integration of all components.
* **16.2 Comprehensive Documentation Review:** A thorough review and polish of all project documentation, ensuring accuracy, clarity, and completeness for new and existing users.
* **16.3 Community Launch & Announcement:** Prepare release announcements and engage with the community to introduce the new capabilities of SoulmateOS 2.0.0.
* **16.4 Tag Release:** Officially tag the `2.0.0` version in the Git repository.
* **Version Tag:** `2.0.0`

## Summary Table

| Phase | Focus Area                                   | Tag           |
| ----- | -------------------------------------------- | ------------- |
| 0     | Bootstrap + Git + Docs                       | `0.1.0`       |
| 1     | Qtile Base Setup                             | `0.2.0`       |
| 2     | System Utilities Layer                       | `0.3.0`       |
| 3     | User Applications Layer                      | `0.4.0`       |
| 4     | UX Enhancers & Session Polish                | `0.5.0`       |
| 5     | Theming & Visual Integration                 | `0.6.0`       |
| 6     | Security Hardening                           | `0.7.0`       |
| 7     | Installation Automation                      | `0.8.0`       |
| 8     | QA + Docs + Final Release                    | `1.0.0`       |
| 9     | Meta-Distro: Cross-Distro Research & Core Adaptation | `1.1.0`       |
| 10    | Meta-Distro: Core Component Cross-Compatibility | `1.2.0`       |
| 11    | Meta-Distro: Theme & UX Layer Porting        | `1.3.0`       |
| 12    | "Rice" Management: `install-rice` Development & Alpha | `1.4.0`       |
| 13    | "Rice" Management: `create-rice` Development & Standardization | `1.5.0`       |
| 14    | Meta-Distro & Rice System: Robustness & Usability Refinement | `1.7.0`       |
| 15    | Community & Documentation: Ecosystem Foundation | `1.9.0`       |
| 16    | SoulmateOS 2.0.0 Final Release               | `2.0.0`       |
