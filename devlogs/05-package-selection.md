# Devlog Entry 05 — Basic Package Selection

**Date**: 2025-June-11  
**Author**: Emile Avoscan  
**Entry ID**: #05  
**Target Version**: 0.3.0  

## Objective
This development log records the reasoning process behind major package selections in SoulmateOS. The goal was not only to choose the "best" tool, but to ensure coherence across the system in terms of performance, aesthetics, configurability, and long-term maintenance.

## Selection Criteria (General)

All package selections were evaluated against the following overarching principles:

- **Lightweight**: Minimal memory/CPU footprint when idle.
- **Scriptable/Extensible**: Configurable through files or scripting (Python, Bash, etc.).
- **Aesthetic Harmony**: Should integrate visually with GTK-based theming and other selected tools.
- **Manual Configuration Preferred**: Avoids monolithic DEs and unnecessary abstraction.
- **Stability and Maturity**: Should be actively maintained and stable on RHEL-derived distros.
- **Licensing**: Must be permissively licensed (MIT, Apache 2.0, GPL okay with minimal viral footprint).

## Terminal Emulator: `Kitty`

### ✔ Selected:
**Kitty**

### 🔍 Alternatives Considered:
- **WezTerm**: Feature-rich, GPU-accelerated, built-in multiplexing
- **Ghostty**: Extremely fast, statically compiled; still early-stage
- **Alacritty**: Fast but limited configurability (no tabs, no native scrollback)
- **st**: Suckless terminal; minimal but difficult to theme

### 🧠 Rationale:
- GPU-acceleration offers fast rendering without excessive CPU usage.
- Scriptable extensions (`kittens`) support long-term customization.
- Balanced between performance and configurability without being bloated.

## App Launcher: `Rofi`

### ✔ Selected:
**Rofi**

### 🔍 Alternatives Considered:
- **dmenu**: Smallest possible launcher, but lacks theming.
- **Ulauncher / Albert**: Electron or heavy Python dependencies.
- **wofi**: Wayland-native, but not ideal for X11-first setup.

### 🧠 Rationale:
- Lightweight (\~2 MB RAM).
- `.rasi` theming integrates tightly with GTK-based style.
- Supports scriptable modes (SSH selector, clipboard history, power menus).

## File Manager: `Thunar`

### ✔ Selected:
**Thunar**

### 🔍 Alternatives Considered:
- **PCManFM-Qt**: Lighter Qt-based option; lacks deep plugin ecosystem.
- **Double Commander**: Powerful but less polished UI.
- **Sunflower**: Unmaintained.
- **Dolphin/Nemo**: Feature-rich but heavy.
- **nnn/ranger**: Terminal-based; excellent for experts but poor for drag-and-drop.

### 🧠 Rationale:
- GTK-based, so theming is consistent.
- Lightweight with modest plugin support.
- Fast and stable on AlmaLinux.

## Text Editor: `Geany`

### ✔ Selected:
**Geany**

### 🔍 Alternatives Considered:
- **FeatherPad**: Lightweight but Qt-based; lacks LSP.
- **Kate**: Rich in features; Qt-heavy.
- **Lite XL**: Lua-based; plugins require manual installation.
- **Neovim/Kakoune**: Great for power users, steep learning curve.

### 🧠 Rationale:
- GTK3-based, aesthetically consistent.
- Plugin support and autocomplete balance between simplicity and power.
- Clean UI when sidebars and toolbars are disabled.

## System Monitor: `btop`

### ✔ Selected:
**btop**

### 🔍 Alternatives Considered:
- **htop**: Simpler UI; fewer features.
- **Xfce Task Manager / LXTask**: GUI-based but functionally shallow.
- **GNOME System Monitor**: Too heavy, pulls in GNOME dependencies.

### 🧠 Rationale:
- Fully terminal-based.
- Zero dependencies beyond libc.
- Modern UI, mouse support, filtering, and sorting capabilities.

## Disk Utilities: `gnome-disk-utility`

### ✔ Selected:
**GNOME Disks**

### 🔍 Alternatives Considered:
- **GParted**: Great for partitioning, but lacks SMART and live device info.
- **KDE Partition Manager**: Qt-based, too heavy.
- **CLI Tools (`fdisk`, `parted`)**: Used as fallbacks.
- **Disks from Xfce or MATE**: Lack SMART monitoring or feel dated.

### 🧠 Rationale:
- GTK3-based and themable.
- Full-featured disk manager (SMART, mount/unmount, partitions).
- Lighter than KDE or GNOME full stacks.


## Reflections on Process

The process prioritized:
- Functional isolation: Each tool does one thing well.
- Visual/thematic integration: GTK wherever possible.
- Maintainability: Avoid bleeding-edge or unmaintained tools.
- Avoiding DE lock-in: Each package can be swapped out without breaking the overall system.

While certain choices might seem “mid-weight” (e.g., Thunar or Geany), they are optimal for the long-term **companion OS** vision: highly usable now, customizable later.

## Future Work

- Reevaluate each choice under Wayland-native pipeline once Wayland support matures in Qtile.
- Consider adding optional declarative config via YAML + script generators.
- Develop install profiles with reduced package sets (e.g., “Server Headless”, “Minimal GUI”, “Dev Workstation”).
