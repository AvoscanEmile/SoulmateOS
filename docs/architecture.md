# SoulmateOS Architecture

## Philosophy

SoulmateOS is built with a singular goal: to create a personalized, minimal, highly cohesive Linux environment that merges lightweight performance with curated design. It is not meant to serve the average user — it is designed to be a long-term companion OS for users who value total control over their computing experience. It is a computing environment that evolves with the user, offering depth for those who want to tinker, script, customize, and gradually build mastery over their digital workspace. It is designed for:

* **Learning-by-building**: The user grows alongside the system by configuring each layer manually.
* **Long-term cohabitation**: It aims to minimize churn — avoiding overhauls or reinstallation every year.
* **Trust through transparency**: Since all components are scriptable, versioned, and intentionally selected, the user knows exactly how the system behaves.
* **Sane Defaults**: It's designed to be a fully customizable OS, but it comes with an aesthetically harmonized carefully selected collection of packages.

This makes SoulmateOS not just a workspace, but a trusted and extendable digital habitat.

## Justifying AlmaLinux over Other Bases

### Why AlmaLinux?

AlmaLinux was selected due to its direct relationship with RHEL (Red Hat Enterprise Linux), which is a gold standard in server and cloud environments. Key benefits include:

* **Enterprise-grade stability**: Ideal for long-lived systems and mission-critical infrastructure.
* **RPM ecosystem**: Mature, secure, and rich in system tools and libraries.
* **Predictable lifecycle**: Guaranteed release cycles and long-term support.
* **Advanced toolchains**: Supports tools like podman, SELinux, Cockpit, Ansible, and other RHEL-tier utilities out-of-the-box.

### Why Not Alternatives?

| Distro | Reason for Rejection |
|---|---|
| **Arch** | Too bleeding-edge; breaks reproducibility. |
| **Void** | Too niche; lacks widespread enterprise tools. |
| **Alpine** | Designed for containers, not full desktops. |
| **Fedora** | Too volatile; fast-changing packages. |
| **NixOS** | Excellent reproducibility, but steep learning curve and ecosystem complexity. |

AlmaLinux represents the best balance between **system transparency**, **long-term reliability**, and **support for advanced server tools**.

## Hardening & Security: Installation Script Goals

Planned features of the installation script:

* **System Hardening**:
    * Enable SELinux in enforcing mode
    * Configure `firewalld` with secure defaults
    * Install and enable `fail2ban`
    * Disable unnecessary services
* **Filesystem**:
    * Use `LVM` or `Btrfs` with snapshots (optional)
    * Encrypted partitions (`LUKS2`)
* **User Setup**:
    * Create primary user with sudo access
    * SSH key setup with optional hardened `sshd_config`
* **Package Installation**:
    * Install base system packages from AlmaLinux minimal ISO
    * Apply version-pinned packages using `dnf` with stable repositories
    * Deploy apps and configs (e.g. Qtile, Geany, Rofi, etc.) from Git-tracked dotfiles
* **Auditing**:
    * Install `auditd` and configure basic rules
    * Enable logging to remote syslog or journald retention policies
* **Optional Flags**:
    * `--hardened` (enable strict security policies)
    * `--developer` (install language toolchains, LSPs)
    * `--server` (skip GUI components, install Cockpit, podman, etc.)

## Wayland Support and Future Readiness

Although Qtile currently runs on X11, it is actively developing Wayland support. The long-term strategy is:

* **Phase 1**: Stick with X11 for wide compatibility and maturity.
* **Phase 2**: Offer optional Wayland session (using `qtile-wayland` or Sway as fallback).
* **Phase 3**: Shift to Wayland-first, once Qtile-Wayland is stable and feature-complete.

The theme system and tooling (GTK, Rofi, Geany) are already compatible with Wayland-aware backends, allowing for smooth future migration.

## Reproducibility & Declarativity Roadmap

To achieve long-term reproducibility:

1.  **Git-Pinned State Management**:
    * All dotfiles and config files stored in versioned Git repositories
    * Each release corresponds to a Git tag and a SemVer version
2.  **Portable Setup Scripts**:
    * Bash/Ansible-based scripts that install, configure, and verify each system component
    * Ensure idempotency to support reinstallation and recovery

## Base Design Decisions

### OS Base: AlmaLinux Minimal
- Chosen for its **stability**, **predictability**, and **RPM ecosystem**
- A downstream RHEL rebuild that provides enterprise-grade robustness
- Easy to script and reproduce across systems

### Window Manager: Qtile
- Tiling window manager chosen for:
  - Scriptability in Python.
  - Performance and responsiveness, with asynchronous event handling
  - Extensive configurability via python, with modular components
  - Minimal Dependencies, X11-native with wayland support.
  - Active development and modern design, built around extensibility.

### Display Manager and Login Greeter: LightDM + GTK-Greeter
- Select chosen for:
  - Very lightweight greeter.
  - GTK-based. Fully customizable with GTK-CSS and fits the general theming pipeline of the system.
  - Well supported in AlmaLinux
  - Little dependencies compared to heavier Display Managers

### Package Philosophy
- No full DEs (GNOME, KDE); instead, curated standalone tools
- Each major DE component (file manager, terminal, panel, etc.) is selected and integrated manually
- Tools chosen for functionality, aesthetic harmony, and resource efficiency

## Apps Selection
Here’s a consolidated recap of your **final selections**, the **reasons** behind each choice, and the **alternatives** we considered along the way.

### Terminal Emulator
**Selected: Kitty**

* **Reasons**:
    * GPU-accelerated performance, fast startup
    * Powerful customization (config file, “kittens” scripting)
    * Mature and stable ecosystem without WezTerm’s extra multiplexer bloat

* **Considered Alternatives**:
    * **WezTerm** (Rust, Lua-powered, built-in multiplexing—too heavy)
    * **Ghostty** (Go-based, very fast, but still early-stage and missing redraw optimizations)

### App Launcher
**Selected: Rofi**

* **Reasons**:
    * Extremely lightweight (~2 MB RAM idle), near-zero CPU when idle
    * Fully themeable via `.rasi` (colors, fonts, padding)
    * Scriptable “modes” for run, drun, ssh, custom menus

* **Considered Alternatives**:
    * dmenu (simpler, less themeable)
    * Ulauncher / Albert (heavier Python/Electron dependencies)

### File Manager
**Selected: Thunar**

* **Reasons**:
    * GUI-based, fast (~25 MB RAM), full mouse support and drag-and-drop
    * Deep appearance theming via GTK-CSS (colors, fonts, padding, margins)
    * Modest plugin ecosystem (archive, media tags, custom actions)

* **Considered Alternatives**:
    * PCManFM-Qt (Qt theming, limited plugin API)
    * Sunflower (stale, unmaintained)
    * Double Commander / Dolphin / Nemo (heavier or less scriptable)
    * Terminal FMs (nnn, ranger, MC) — ultimately chose GUI for broad navigation speed

### Text Editor
**Selected: Geany**

* **Reasons**:
    * GTK3-based (theming consistency), very lightweight
    * Built-in autocomplete for many languages, plugin support (LSP, file tree)
    * Can disable terminal, sidebar, toolbar to get a clean text-only view

* **Considered Alternatives**:
    * Kate (Qt, LSP support but heavier on deps)
    * FeatherPad (Qt, no LSP)
    * Lite XL (Lua-based, needs manual plugin setup)
    * Neovim/Kakoune (powerful but steeper learning curve)

### System Monitor
**Selected: btop**

* **Reasons**:
    * Zero dependencies
    * Fully TUI based
    * Highly sophisticated interface and very powerful interactions

* **Considered Alternatives**:
    * htop (TUI but minimal visuals)
    * LXTask / Xfce Task Manager (very light GUI but limited)
    * GNOME/KDE monitors (too heavy)

### Disk Utilities
**Selected: GNOME-disk-utility**

* **Reasons**:
    * Full-featured GUI for disk management (mounting/unmounting, formatting, partitioning, SMART health monitoring)
    * Lighter than other similar alternatives, more sophisticated than lighter alternatives
    * GTK-Based. Fully customizable with GTK-CSS and GTK-Themes

* **Considered Alternatives**:
    * GParted
    * CLI tools (`parted`, `fdisk`, `mkfs`, `fsck`)—fallback and advanced use

## Additional User-Level Applications

To complement the core environment, the following user-facing apps are selected for a GTK-consistent, lightweight, and privacy-aware experience:

### Web Browser

**Selected: Firefox**

* **Reasons**:

    * Robust developer tooling (Inspector, console, network analysis)
    * Sync across devices for bookmarks, passwords, and history
    * Actively maintained and well-supported on AlmaLinux

* **Considered Alternatives**:

    * LibreWolf (privacy-focused but lacks Firefox Sync)
    * GNOME Web (limited extension ecosystem)

### Media Player

**Selected: Celluloid (mpv GTK frontend)**

* **Reasons**:

    * GTK3 themability via CSS, consistent with system theme
    * Lightweight frontend paired with powerful mpv backend
    * Keyboard-driven controls and minimal dependencies

* **Considered Alternatives**:

    * VLC (heavy dependencies)
    * Haruna (Qt-based, not GTK-native)
    * Direct mpv CLI (no GUI)

### Music Player

**Selected: Lollypop**

* **Reasons**:

    * GTK3-based with CSS theming support
    * Active development and library management features
    * Simple, intuitive UI tailored to album Browse

* **Considered Alternatives**:

    * Rhythmbox (older and heavier)
    * Amberol (too minimal feature set)

### Markdown Editor

**Selected: Geany + Markdown Preview Plugin**

* **Reasons**:

    * Leverages existing Geany setup, avoiding Electron
    * Live preview and syntax highlighting for Markdown
    * Plugin architecture allows further extensibility

* **Considered Alternatives**:

    * Apostrophe (overkill for text+code editing)
    * MarkText (Electron-based)

### Image Viewer

**Selected: gThumb**

* **Reasons**:

    * GTK-based with full-screen support and basic editing
    * CSS theming possible via GTK
    * Lightweight compared to other viewers

* **Considered Alternatives**:

    * Eye of GNOME (too minimal)
    * Viewnior (limited features)
    * Ristretto (XFCE-centric)

### Archive Manager

**Selected: Engrampa + Thunar Plugin**

* **Reasons**:

    * GTK3-native and integrates seamlessly with Thunar
    * Supports most archive formats out-of-the-box
    * The Thunar plugin provides right-click context actions

* **Considered Alternatives**:

    * File Roller (older GNOME tool)
    * Xarchiver (less integrated)

### Document Viewer

**Selected: Evince + Foliate**

* **Reasons**:

    * **Evince** for PDFs: lightweight, robust GTK3 app
    * **Foliate** for eBooks (EPUB/DJVU): CSS themable and reader-focused
    * Combined coverage for all common document formats

* **Considered Alternatives**:

    * Zathura (Vim-like controls but fewer GUI features)
    * Okular (Qt-based, heavier)

### Calendar and Project Management

**Selected: Calcurse**

* **Reasons**:

    * Powerful TUI calendar, todo, and note management
    * Highly scriptable and integrates with Qtile widgets
    * Avoids heavy GUI dependencies while providing full feature set

* **Considered Alternatives**:

    * Orage (obsolete)
    * GNOME Calendar (tied too closely to GNOME Shell)
    * Gsimplecal (too simplistic)

## UX Enhancers Package Selection

This section documents the rationale behind selecting auxiliary user experience (UX) tools for **SoulmateOS**, including clipboard managers, volume controls, screen lockers, and notification daemons. These tools are chosen for their minimal footprint, compatibility with a Qtile + X11 stack, and alignment with the system’s GTK3-oriented aesthetic goals.

### Clipboard Manager

* **Selected**: `xfce4-clipman`
* **Alternatives Considered**:
    * `clipit`: Not available in AlmaLinux repositories
    * `copyq`: Qt-based, introduces unnecessary dependencies
* **Rationale**: Despite being an XFCE panel plugin, `xfce4-clipman` runs independently and integrates well into a standalone Qtile session. It supports clipboard history, primary/clipboard selection, and a system tray icon with low resource usage.

### Notification Daemon

* **Selected**: `xfce4-notifyd`
* **Alternatives Considered**:
    * `dunst`: Highly configurable, but lacks native GTK styling
    * `mako`: Wayland-only
* **Rationale**: `xfce4-notifyd` provides out-of-the-box GTK3 support, integrates well with accessibility tools, and requires no additional configuration when started via session hooks.

### Volume Control

* **Selected**: Custom Eww widget with `wpctl` backend
* **Alternatives Considered**:
    * `volumeicon`: Not available in AlmaLinux
    * `pavucontrol`: Heavy, but installed for GUI fallback
    * XFCE panel volume plugin: Requires full panel runtime
* **Rationale**: The eventual goal is a fully native Qtile widget using `wpctl` for volume control under PipeWire. A minimal CLI fallback exists in the interim.

### Screenshoots

* **Selected**: `xfce4-screenshooter`
* **Alternatives Considered**:
    * `gnome-screenshot`: Dragged in GNOME dependencies
    * `flameshot`: Qt-based, aesthetically inconsistent with the rest of the stack
    * `scrot`: Lacks GUI and modern conveniences
* **Rationale**: `xfce4-screenshooter` provides a well-designed GTK3-compatible GUI, supports full screen, region, and window captures, and integrates into the system tray or keybindings easily. It respects the minimal dependencies goal while offering a polished interface.

### **Overall Integration Strategy**

* **Toolkit Consistency**: Prioritize GTK-native applications (Thunar, Rofi, LightDM greeter, Geany, nm‑applet, GNOME Disks, Firefox, Celluloid, Lollypop, gThumb, Engrampa, Evince/Foliate, Calcurse) with minimal Qt/Electron only where indispensable.
* **Theming Pipeline**: Centralize all theming in `~/.config/gtk-3.0/gtk.css` (and matching Rofi `.rasi`), ensuring CSS tweaks propagate across terminal, file manager, greeter, and viewer interfaces.
* **Workflow Balance**:
    * **GUI for exploration & media**: Thunar, Firefox, Celluloid, Lollypop, gThumb, Engrampa, Evince/Foliate
    * **TUI & Terminal for power tasks**: Kitty, btop, ncdu, Calcurse, Geany (text-mode view)
* **Modularity & Privacy**: Each app selected for best-in-class functionality—no monolithic DE—while avoiding Electron/Snap/Flatpak to reduce attack surface and maintain lean resource usage.
* **Extensibility**: Leverage Qtile Python scripts and plugin hooks (Rofi modes, Thunar custom actions, Calcurse hooks) to weave these standalone tools into cohesive, automated workflows.

## Versioning and Git Strategy

* Follows [Semantic Versioning](https://semver.org/)
* Git tracks all config, theme, and documentation changes
* Each stable release will correspond to a reproducible state of the OS
* Licensing: GPL 3.0, with per-file copyright headers

## Project File Overview and Intercorrelation

This section provides a detailed breakdown of the files within the SoulmateOS project, explaining their purpose and how they interact to form the complete operating environment.

### Core Installation and Configuration Scripts

These scripts are responsible for setting up the SoulmateOS base system, installing necessary packages, and deploying configurations.

* **`installation.sh`**: This is the main orchestrator script for the entire SoulmateOS setup. It manages the installation phases, including enabling DNF repositories, running module-specific installation scripts, and performing post-installation cleanup. It also handles command-line flags for retaining specific directories (e.g., `--keep-repo`, `--keep-docs`, `--keep-devlogs`) and prompts for a system reboot upon completion.
    * **Correlates with**: Directly calls `graphics.sh`, `qtile.sh`, `user.sh`, and `config.sh` to execute the different phases of the installation.

* **`graphics.sh`**: This script handles the installation and configuration of the X11 display server and LightDM, which serves as the display manager and login greeter. It enables LightDM to start at boot and sets the system's default target to a graphical environment.
    * **Correlates with**: `installation.sh` (called during Phase 1). It also enables LightDM, which is the chosen Display Manager for SoulmateOS.

* **`qtile.sh`**: This script is dedicated to installing Qtile, the chosen tiling window manager, and its dependencies. It installs Python 3.11, development tools, C/C++ headers, and Python bindings, then installs Qtile itself using `pip`. Crucially, it configures a Qtile session for LightDM, allowing users to select Qtile at login.
    * **Correlates with**: `installation.sh` (called during Phase 2). It sets up Qtile as the window manager and creates the `qtile.desktop` file for LightDM integration.

* **`user.sh`**: This script focuses on installing user-level applications and UX enhancements. It installs basic desktop applications (e.g., Kitty, Geany, Thunar, btop) via `sudo dnf install` and user-level apps (e.g., Celluloid, Lollypop, Foliate, Calcurse, Polybar, Eww) and Picom via Nix. It also handles the installation of UX enhancers like `xfce4-notifyd`, `xfce4-screenshooter`, and `xfce4-clipman-plugin`.
    * **Correlates with**: `installation.sh` (called during Phase 3). It installs many of the applications detailed in the "Apps Selection" and "UX Enhancers" sections of `architecture.md`.

* **`config.sh`**: This script is responsible for deploying all configuration files and themes from the SoulmateOS repository to the appropriate user directories (typically `~/.config/soulmateos`). It makes Qtile's autostart script executable, extracts compressed theme files (GTK, icons, cursors), and creates symlinks for various configuration directories (e.g., `qtile`, `polybar`, `gtk-3.0`, `picom`) to their standard locations in `~/.config` or `~/.local/share`.
    * **Correlates with**: `installation.sh` (called during Phase 4). It manages the deployment of all other configuration files (`picom.conf`, `settings.ini`, `config.ini`, `eww.css`) and links them to their active locations. It ensures `autostart.sh` is executable.

### Runtime Configuration and Startup Scripts

These files define the behavior and appearance of the desktop environment once it's running.

* **`config.py`**: This is the main configuration file for Qtile, written in Python. It defines the core behavior of the window manager.
    * It sets keybindings for window navigation, manipulation (moving, growing, shrinking, killing), and layout switching.
    * It defines how windows are grouped (workspaces) and provides keybindings for switching between and moving windows to different groups.
    * It specifies the available window layouts, such as `Columns` and `Max`.
    * The `@hook.subscribe.startup` decorator ensures that `autostart.sh` is executed when Qtile starts, initiating other essential services and configurations.
    * The `@hook.subscribe.setgroup` decorator triggers `polybar-msg hook groups 0` whenever the active group changes, which is used to update the Polybar group indicator via `qtile-groups.sh`.
    * It defines mouse bindings for dragging and resizing floating windows.
    * It includes rules for floating windows, ensuring certain applications (e.g., dialogs, password prompts) appear as floating rather than tiling.
    * **Correlates with**: `qtile.sh` (which installs Qtile). `autostart.sh` (which it calls at startup). `qtile-groups.sh` (which it notifies of group changes via `polybar-msg`). It dictates how the user interacts with the system, managing windows and leveraging other scripts and configurations.

* **`autostart.sh`**: This script is executed when Qtile starts a new session. It sets the cursor theme, dynamically updates Polybar's configuration using `change-config.sh`, starts the Picom compositor, launches various Polybar instances (datetime, weather, groupsbar, volumebar, netbar), starts the Eww daemon and updates its volume, and initiates `xfce4-clipman` and X display power management settings.
    * **Correlates with**: `config.sh` (ensures it's executable). It initiates `picom` using `picom.conf`, starts Polybar instances configured by `config.ini` (which is in turn generated by `change-config.sh`), manages `eww` using `eww.css`, and starts `xfce4-clipman`.

* **`picom.conf`**: This is the configuration file for Picom, the X11 compositor. It defines visual effects such as window shadows (radius, offset), fading behavior (fade-in/out steps), transparency for window frames, and rounded corners. It also specifies the backend (`glx`), enables VSync, and includes rules for specific window types (e.g., tooltips, docks).
    * **Correlates with**: `autostart.sh` (Picom is started with this configuration).

* **`settings.ini`**: This file contains GTK settings for applications that use the GTK toolkit. It specifies the GTK theme (`Nordic`), icon theme (`nordzy`), and cursor theme (`Layan-white-cursors`). These settings ensure a consistent visual appearance across GTK applications.
    * **Correlates with**: `config.sh` (the themes specified here are extracted and symlinked during configuration deployment). It influences the "Theming Pipeline" strategy outlined in `architecture.md`.

### Polybar Configuration and Scripts

These files configure and populate the Polybar panel, which displays system information.

* **`config.ini`**: This file (as initially provided, but later dynamically generated) defines the various Polybar bars and the modules they display. It specifies properties like width, offset, height, background, foreground, radius, padding, and the specific modules to be shown (e.g., `datetime`, `weather`, `groups`, `volume`, `network`).
    * **Correlates with**: `autostart.sh` (launches the Polybar instances defined here). It's dynamically generated by `change-config.sh`.

* **`polybar_theme.ini`**: This INI file stores a collection of variables used to define the universal and module-specific visual properties of the Polybar instances. This includes background/foreground colors, fonts, radius, height, padding, and precise `offset-x` and `width` values for each bar (datetime, weather, groups, volume, and network).
    * **Correlates with**: `change-config.sh` (this script reads and exports these variables to dynamically generate the `config.ini` for Polybar). This file is critical for implementing the "Theming Pipeline" strategy mentioned in `architecture.md` by externalizing Polybar's visual configuration.

* **`change-config.sh`**: This script is crucial for dynamic theming of Polybar. It reads theme variables (like `DATETIME_BAR_WIDTH`, `BACKGROUND`, `FONT`, etc.) from `~/.config/soulmateos/themes/polybar_theme.ini`. Using these variables, it then programmatically generates and overwrites the `~/.config/polybar/config.ini` file, ensuring that Polybar's appearance and module positions adapt to the chosen theme.
    * **Correlates with**: `autostart.sh` (called at startup to configure Polybar). It generates `config.ini`, making it dependent on `polybar_theme.ini` (not provided in the context, but implied by the script) and `xrandr` for screen resolution.

* **`qtile-groups.sh`**: This script is designed to be used as a custom module in Polybar to display the status of Qtile's workspaces (groups). It queries Qtile to identify the currently active group and then outputs a visual representation (e.g., '●' for active, '○' for inactive) for groups 1 through 9.
    * **Correlates with**: `config.ini` (used as the `exec` command for the `module/groups`).

* **`volume.sh`**: This script provides a dynamic volume indicator for Polybar. It uses `wpctl` to retrieve the current volume percentage and mute status from the default audio sink. Based on these values, it selects an appropriate Unicode icon (muted, low, mid, or high volume) and outputs the icon followed by the volume percentage.
    * **Correlates with**: `config.ini` (used as the `exec` command for the `module/volume`).

* **`volume-monitor.sh`**: This script is similar to `volume.sh` in its purpose but specifically designed for continuous monitoring rather than a single output. It immediately outputs the current volume using `wpctl` and then includes a placeholder for further monitoring logic. While `volume.sh` is used in Polybar for its direct output, `volume-monitor.sh` suggests a more persistent background process.
    * **Correlates with**: Potentially a custom Qtile widget for continuous volume display or a different monitoring tool, as mentioned in the `architecture.md` regarding the planned custom Qtile volume widget.

* **`network.sh`**: This script monitors network activity (upload and download speeds) for a specified network interface (e.g., `enp2s0`) and outputs the information for display in Polybar. It calculates speeds by comparing byte counts over a short interval and includes Unicode icons for Ethernet, upload, and download.
    * **Correlates with**: `config.ini` (used as the `exec` command for the `module/network`).

### Eww Configuration

* **`eww.yuck`**: This file contains the Eww configuration, defining a `volume` window and a `volume-slider` widget. The `volume` window is positioned at the top right of the monitor, with a specific width and height. The `volume-slider` widget uses a horizontal scale to display and control the system volume, which is updated via `wpctl set-volume` when the slider is changed]. It also defines a `menu-closer` window with a `closer` widget that closes all Eww windows when clicked.
    * **Correlates with**: `autostart.sh` (Eww is daemonized, and the `volume` variable is updated at startup). `volume-monitor.sh` (this script is the `deflisten` source for the `volume` variable in `eww.txt`). `eww.css` (this file provides the styling for the Eww windows and widgets defined here).

* **`eww.css`**: This CSS file is for styling Eww (Extensible Wayland Widgets). It defines the visual properties of horizontal elements, including background color, border-radius, padding, and specific styling for the progress bar's trough and slider (including a custom knob image).
    * **Correlates with**: `autostart.sh` (Eww is daemonized and updated with volume, implying this CSS is loaded by Eww) and `eww.yuck` as it directly provides styling for the widgets defined there.

* **`volume-monitor.sh`**: This bash script is used as a `deflisten` source for Eww. Its primary function is to continuously output the current system volume as an integer (0-101) by querying `wpctl get-volume @DEFAULT_AUDIO_SINK@`. It also explicitly flushes its output.
    * **Correlates with**: `eww.yuck` (provides the volume data to the Eww `volume` variable). `volume.sh` (both scripts interact with `wpctl` for volume information, though `volume-monitor.sh` is specifically designed for continuous Eww listening).
