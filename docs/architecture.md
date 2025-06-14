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

| Distro     | Reason for Rejection                                                          |
| ---------- | ----------------------------------------------------------------------------- |
| **Arch**   | Too bleeding-edge; breaks reproducibility.                                    |
| **Void**   | Too niche; lacks widespread enterprise tools.                                 |
| **Alpine** | Designed for containers, not full desktops.                                   |
| **Fedora** | Too volatile; fast-changing packages.                                         |
| **NixOS**  | Excellent reproducibility, but steep learning curve and ecosystem complexity. |

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

1. **Git-Pinned State Management**:

   * All dotfiles and config files stored in versioned Git repositories
   * Each release corresponds to a Git tag and a SemVer version

2. **Portable Setup Scripts**:

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
  * Extremely lightweight (\~2 MB RAM idle), near-zero CPU when idle
  * Fully themeable via `.rasi` (colors, fonts, padding)
  * Scriptable “modes” for run, drun, ssh, custom menus

* **Considered Alternatives**:
  * dmenu (simpler, less themeable)
  * Ulauncher / Albert (heavier Python/Electron dependencies)

### File Manager
**Selected: Thunar**

* **Reasons**:
  * GUI-based, fast (\~25 MB RAM), full mouse support and drag-and-drop
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

### 🎯 **Overall Integration Strategy**

* **Toolkit Consistency**: Lean GTK (Thunar, Rofi, LightDM greeter, Geany, nm-applet, GNOME Disks) with minimal Qt/Electron only where needed
* **Theming Pipeline**: Central `~/.config/gtk-3.0/gtk.css` (and matching Rofi `.rasi`) as single source of theming
* **Workflow Balance**: GUI tools for broad navigation (Thunar, GParted, Conky), TUI/terminal tools for power users (kitty, btop, ncdu)
* **Modularity**: Each component chosen for best-in-class functionality while avoiding monolithic desktop environments

## Versioning and Git Strategy

- Follows [Semantic Versioning](https://semver.org/)
- Git tracks all config, theme, and documentation changes
- Each stable release will correspond to a reproducible state of the OS
- Licensing: Apache 2.0, with per-file copyright headers
