# **Devlog Entry 08 — User Package Installation Process**

**Date:** 2025-06-16  
**Author:** Emile Avoscan  
**Target Version:** 0.4.0  

## Overview

This devlog entry documents the first manual attempt to install the core applications selected in the previous one. The objective was twofold: (1) validate software availability and compatibility, and (2) establish a coherent and functional package management approach. In doing so, a major structural transition was made: **SoulmateOS migrated to a single-user Nix installation model**. This shift proved critical for long-term stability, reproducibility, and user-space flexibility on non-NixOS systems.

## Phase I: Initial Testing and Environment Debugging

### Software Availability and Choice of Tooling

Installation efforts began by confirming the presence of key applications like `celluloid` and `lollypop`. Both were found in Flatpak and `nixpkgs`, but Nix was chosen as the preferred path due to its composability and declarative potential.

### First Install Attempt

Using the `nix-env` command, `celluloid` and `mpv` were installed:

```bash
nix-env -iA nixpkgs.celluloid nixpkgs.mpv
```

However, an immediate failure occurred on video playback:

```
failed to create EGL display
```

This was traced to a graphics stack mismatch. Nix-installed binaries couldn’t access the system's OpenGL libraries. Attempts to use `nixGL` were thwarted due to its absence from the default `nixpkgs` channel.

### Environment Repair and Daemon Issues

The Nix-provided `mpv` was uninstalled to avoid conflicts:

```bash
nix-env -e mpv
nix-collect-garbage -d
```

Another error surfaced:

```
cannot connect to the socket at daemon-socket/socket
```

This reflected an improper installation mode. `nix-env` was attempting a multi-user operation without a running daemon. I decided to revert and reaffirm **a strict single-user installation mode**. This choice bypassed the need for a daemon and provided a more controlled user-space environment.

To avoid rebooting, the environment was repaired using:

```bash
source "$HOME/.nix-profile/etc/profile.d/nix.sh"
```

With this in place, both `celluloid` and `lollypop` were confirmed to run. At this stage, deeper application-level customization was postponed; the priority was basic functionality within the new Nix user model.

### Challenges Encountered

* **OpenGL Compatibility**: EGL initialization failed due to mismatched driver bindings. The problem was solved by avoiding certain packages within Nix.
* **nixGL Absence**: A known limitation for GUI applications depending on hardware acceleration outside NixOS.
* **Improper Install Mode**: The system initially behaved as if configured for multi-user Nix. Reinstallation under single-user mode corrected the issue.
* **Runtime Conflicts**: Simultaneous presence of system and Nix packages (e.g., `mpv`) caused unpredictable behavior.
* **Path and Shell Issues**: Until the correct environment file was sourced, Nix packages were inaccessible.

### Reflections on the Transition to Single-User Nix

This milestone marked a pivotal point: SoulmateOS is now designed around a **single-user Nix installation paradigm**, emphasizing local reproducibility, clean user separation, and minimal reliance on privileged daemons. This architecture aligns with the OS's philosophy of modular, user-controlled tooling and simplifies future package definitions.

## Phase II: Completion of Application Stack Installation

With the environment stabilized, the installation of the remaining application set proceeded as follows:

### Markdown Editor Integration

* Installed `geany-plugins-markdown` via `dnf` to add live Markdown preview support.

### Archive Manager Setup

* `engrampa` and `thunar-archive-plugin` installed via `dnf` to enable archive integration in Thunar.

### Document Reader Pairing

* Reaffirmed split between EPUB (Foliate) and PDF (Evince). Installed Foliate via Nix and Evince via `dnf`.

### Calendar Application Review

* GTK3-based calendars such as Gsimplecal, Orage, and Focal were evaluated but found unsuitable.
* GNOME Calendar was rejected due to tight GNOME integration.

### Productivity Stack Decisions

* Evaluated Calcurse, Gsimplecal, and Focalboard. Only *Calcurse* provided comprehensive task management with notification hooks.
* Installed Calcurse via Nix, setting the foundation for a notification-integrated TUI productivity layer.

### Widget Development Plan

* Initiated plans to build custom GTK3 and Qtile widgets:

  * GTK: `Gtk.Calendar` interface
  * Qtile: `qtile_extras.calendar` with `KhalCalendar`
  * Hooked `notify-send` for real-time alerts from `~/.calcurse/hooks/notify`
  * Designed cron-based ICS export for integration with graphical interfaces

### Additional Installations

* `gThumb` and `Firefox` were installed via `dnf` without incident.

## Concluding Thoughts

The transition to single-user Nix proved transformative, unlocking a stable, reproducible path forward for SoulmateOS on non-NixOS systems. Despite minor frictions around graphics bindings and environment configuration, the effort succeeded in establishing a reliable foundation for continued package layering.

Future devlogs will expand on system-wide theming, dotfile management, and widget-based enhancements, all built upon the now solid Nix substrate.

