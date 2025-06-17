# Devlog Entry 05 — Basic Package Selection

**Date**: 2025-06-11  
**Author**: Emile Avoscan  
**Target Version**: 0.3.0  

## Objective

This development log outlines the rationale behind the core package selections made for SoulmateOS. Rather than aiming to select the "best" tool in isolation, the focus has been on ensuring systemic coherence in terms of performance, aesthetics, scriptability, and long-term sustainability.

## General Selection Criteria

Each package was evaluated using the following criteria:

* **Lightweight**: Minimal resource usage in idle and runtime.
* **Scriptable or Extensible**: Capable of being configured or extended through well-defined interfaces.
* **Aesthetic Compatibility**: Visual coherence with GTK-based theming and selected UI frameworks.
* **Manual Configuration**: Preference for tools that expose their internals and avoid GUI-heavy abstraction layers.
* **Stability & Maturity**: Proven functionality and maintenance history, especially on RHEL-derived distributions.
* **License Compatibility**: Open-source licenses with minimal viral provisions (MIT, Apache 2.0, and permissive GPL usage acceptable).

## Terminal Emulator

**Selected**: `kitty`

**Alternatives Considered**:

* WezTerm
* Ghostty
* Alacritty
* st (Suckless Terminal)

**Rationale**:

* Hardware-accelerated rendering with low CPU overhead.
* Supports custom extensions via `kittens`.
* Balances configurability and performance.
* Theming support integrates smoothly with the rest of the desktop environment.

## App Launcher

**Selected**: `rofi`

**Alternatives Considered**:

* dmenu
* Ulauncher / Albert
* wofi

**Rationale**:

* Theming via `.rasi` integrates with GTK.
* Extensible with scripting modes.
* Low resource usage; significantly lighter than Electron-based launchers.
* Well-documented and mature.

## File Manager

**Selected**: `thunar`

**Alternatives Considered**:

* PCManFM-Qt
* Double Commander
* Sunflower
* Dolphin / Nemo
* nnn / ranger

**Rationale**:

* GTK-based, ensuring aesthetic consistency.
* Lightweight with an actively maintained plugin ecosystem.
* Provides essential features without pulling in large desktop environment dependencies.

## Text Editor

**Selected**: `geany`

**Alternatives Considered**:

* FeatherPad
* Kate
* Lite XL
* Neovim / Kakoune

**Rationale**:

* GTK3-based interface that integrates cleanly.
* Lightweight yet extensible through plugins.
* Balanced between simplicity and development utility.
* Useful for both light scripting and basic development tasks.

## System Monitor

**Selected**: `btop`

**Alternatives Considered**:

* htop
* Xfce Task Manager / LXTask
* GNOME System Monitor

**Rationale**:

* Fully terminal-based with a modern interface.
* Requires no dependencies beyond libc.
* Provides filtering, sorting, and mouse support.
* Avoids GUI overhead while providing detailed system insight.

## Disk Utility

**Selected**: `gnome-disk-utility`

**Alternatives Considered**:

* GParted
* KDE Partition Manager
* CLI tools (`fdisk`, `parted`, etc.)
* Xfce/MATE disk tools

**Rationale**:

* GTK3-based and compatible with theming.
* Provides live device info and SMART monitoring.
* Lighter than full GNOME or KDE stack.
* Complements GParted for a full disk management toolkit.

## Reflections on Selection Process

Each choice reflects the following principles:

* **Functional granularity**: Each tool solves a single problem well.
* **Visual consistency**: GTK-first tooling allows for a coherent visual environment.
* **Long-term maintainability**: Avoiding tools that are bleeding-edge, unmaintained, or heavily dependent on upstream DEs.
* **Modular architecture**: Choices can be swapped individually without entangling the rest of the system.

While some selections (e.g., Thunar, Geany) are slightly heavier than minimalist alternatives, they provide immediate usability without compromising the OS's philosophy of clarity, control, and refinement.

## Next Steps

* Manually install each selected package.
* Add the packages to the installation script.
* Test and validate the proper functioning of the installation script. 

