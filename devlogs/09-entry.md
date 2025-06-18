# Devlog 09 — UX Enhancers, Session Polish and symlinking

**Date**: 2025-06-16  
**Author**: Emile Avoscan  
**Target Version**: 0.5.0  

## First Objective

In Phase 4, my focus shifted from merely assembling system utilities to refining the user session into something cohesive and intuitive. The goal was to integrate UX enhancements—notifications, screenshots, clipboard history, volume controls, cursor theming, and power management—into a lean Qtile + AlmaLinux minimal environment without burdening the base with unnecessary services.      
### Implementing a Notification Daemon

AlmaLinux minimal comes without a Freedesktop‑compliant notification daemon and after some consideration chose **xfce4-notifyd** and isntalled for its GTK3 compatibility and minimal footprint. It was necessary to configure it for it to work properly, as it didn't out of the box. 

* **Discovery**: Located the binary at `/usr/lib64/xfce4/notifyd/xfce4-notifyd` after `rpm -ql xfce4-notifyd`.
* **DBus Activation**: Created `~/.local/share/dbus-1/services/org.freedesktop.Notifications.service` to bind the `org.freedesktop.Notifications` name to the daemon’s executable.
* **Validation**: Confirmed the setup with `notify-send "Test" "Notification active!"`, ensuring on‑demand launches without manual backgrounding.

### Selecting and Binding Screenshot Tools

To mimic a snipping‑tool experience under GTK3, I compared **xfce4-screenshooter** and **Shutter** and settled on **xfce4-screenshooter** for its simplicity:

* Installed via `sudo dnf install xfce4-screenshooter`.

### Integrating Clipboard History with Clipman

To avoid full XFCE panel dependencies, I ran the **xfce4-clipman-plugin** headlessly:

* Installed via `sudo dnf install xfce4-clipman-plugin`.
* Launched with `xfce4-clipman &` in `~/.config/qtile/autostart.sh`.

### Power Management via DPMS

To meet my requirement—blank after 20 min, lock at 30 min, never power off I attempted to configure X11’s DPMS:

```bash
# ~/.xsessionrc
xset s 1200 1200            # blank after 20 min
xset dpms 1200 1800 0          # only standby at 20 min
```

This combination delivers a black screen at 20 min and a secure lock at 30 min without ever reaching the off state, nonetheless, problems were encountered. As the current setup was incapable of locking the session, and the .xsessionrc didnt work properly, we move into the second objective. 

## Second Objective

To integrate a functional, lightweight screen locking solution for **Qtile** under **AlmaLinux 9.6**, using **LightDM** as the session manager and **X11** as the display stack. The target behavior included:

* 20 minutes: blank screen + standby (DPMS)
* 30 minutes: automatic screen lock
* Never: full power-off

While the original goal was pragmatic and seemingly trivial, the journey revealed a deeper dissonance between modern session control, minimalist setups, and the assumptions made by desktop environments.

### Initial Setup & Assumptions

The base was a clean AlmaLinux 9.6 install, running Qtile with LightDM and X11. The session was launched via a correctly configured `qtile.desktop` entry under `/usr/share/xsessions`, using `dbus-run-session` for session bus integration.

The expectation was simple: `xscreensaver`, `dm-tool lock`, or a similar tool would suffice. This turned out to be naive.

### The Problem with Locking

It began with an attempt to use `xscreensaver`:

* It installs cleanly.
* It controls screen blanking and DPMS reliably.
* It does *not* lock LightDM sessions; rather, it manages its own lock state, entirely independent of PAM or LightDM.

Then came `dm-tool lock`, LightDM's purported locking command. It behaves oddly:

* Instead of locking the session, it switches to the greeter (usually VT8), but **without suspending or isolating** the current session.
* This results in a visible TTY switch with no integration into the user's session. You can switch back to the original session (e.g., Ctrl+Alt+F7) without any authentication.

Worse still, tools like `light-locker`, `xss-lock`, and `gnome-screensaver` were either unavailable in DNF (AlmaLinux’s repositories lack many of these), or they assumed GNOME or Xfce session environments.

### Exploratory Attempts

Multiple strategies were attempted and evaluated:

#### 1. `loginctl terminate-session`

Cleanly ends the session and returns to LightDM. This actually works—Qtile exits, LightDM respawns on VT7—but it results in a jarring kernel log screen showing systemd and service OKs.

It was tried to:

* Add `quiet splash` to the GRUB kernel line to suppress the log.
* Use `qtile.cmd_shutdown()` to see if Qtile's internal shutdown would behave more gracefully.

Results: better, but some boot text remained regardless of method.

#### 2. `dm-tool switch-to-greeter`

A better alternative. This keeps the session alive and just transfers control to the LightDM greeter, which is usually already running on VT8. Upon login, it switches back. Clean, fast, and without flicker.

This became the chosen "logout" method when graceful exit wasn’t desired.

#### 3. `i3lock`

Available in DNF. However:

* It does not time itself out.
* It does not integrate with LightDM or any session manager.
* Requires separate idle tracking and screen management.

A timer-based shell script using `xprintidle` and `i3lock` was deemed possible but fragile and added complexity.

### Decision: No Locking by Default

After several hours of investigating, compiling, and testing session locking solutions, the decision was made to drop default screen locking entirely for SoulmateOS.

Instead:

* A future Qtile-native **power menu** will be provided (Shutdown, Reboot, Logoff).
* Locking will be considered optional and delegated to the user.

Rationale:

> In a domestic or personal setup, physical access control is superior to digital screen locks. The security theater of an unintegrated lock screen does not justify its fragility.

This philosophical pivot was key: letting go of broken assumptions often reveals simpler, more user-aligned workflows.

### Final Power Menu Integration

To replace the need for locking, a minimal `rofi`-based power menu was implemented:

* **Options**: Shutdown, Reboot, Logoff
* **Implementation**: Bash script invoking `systemctl` and `loginctl`
* **Qtile binding**: Bound to `Mod+X` via `lazy.spawn("~/bin/powermenu.sh")`

This menu executes flawlessly under Qtile and LightDM, returning to the greeter without X server restart or kernel text leakage.

### Reflections

What started as a seemingly small task—"just set up a lock screen"—exposed the following realities:

* Minimalist setups suffer when compositional assumptions fail (no DE = no lock integration).
* Session locking is deeply tied to display managers and PAM stacking, not just screen blanking.
* LightDM’s toolset is underdocumented and underwhelming in this regard.

This devlog concludes not with a solved problem, but a philosophical stance:

> "When security is optional and non-critical, reliability and clarity should take precedence."

Users who need a lock screen can install one; SoulmateOS will provide a secure-by-design default, but not a convoluted or fragile one.

## Final Objective

Develop, test and validate the installation process up until the point of symlinking .config files into their respective location and installing relevant packages for the ux experience. A secondary `install-links.sh` called by `installation.sh` will be created. 

### Background

Initial attempts to control screen blanking and DPMS timeouts via `~/.xsessionrc` failed under LightDM. Investigation revealed LightDM sources `~/.xprofile` or an executable `~/.xsession`, bypassing `.xsessionrc` entirely. It was decided to simply put the configuration inside the `autostart.sh` of qtile. Parallel challenges included managing diverse config files scattered across the home directory and system paths, leading to fragmented manual edits.

### Strategy

1. **Centralize configs** in `~/soulmateos/config` and mirror them to `~/.config/soulmateos`.
2. **Automate deployment** with a linker script that synchronizes via `rsync` and creates symbolic links for critical components (Qtile configs and D‑Bus service files).
3. **Modular installer** (`install.sh`) to manage system‑level prerequisites, repository enabling, package installation (DNF and Nix), and invocation of the linker.
4. **Robust tooling**: use `set -euo pipefail` for fail‑fast behavior, sudo keepalive for smooth privilege escalation, and logging for traceability.

### Implementation

### Linker Script
Made `install-links.sh` to modularize the installation process away from the symlinking process. It gets called by `installation.sh` towards the end of the execution. The file contained:
* **Configuration mirroring**: `rsync -av --delete` from `~/soulmateos/config` to `~/.config/soulmateos`.
* **Selective executability**: only `autostart.sh` marked `+x`; `.py` and `.service` files remain read‑only.
* **Symlinks**:

  * `~/.config/qtile` → `master/qtile`
  * `~/.local/share/dbus-1/services/org.freedesktop.Notifications.service` → `master/org.freedesktop.Notifications.service`

### Challenges & Resolutions

* **LightDM’s session scripts**: Confirmed `.xprofile` usage and leveraged Qtile’s own autostart hook for reliable execution of `xset`.
* **Permission subtleties**: Distinguishing directory execute vs. script execute; limited `chmod +x` to actual shell scripts.
* **Absence of `rsync`**: Provided `cp -a` fallback until `rsync` installation was accepted.
* **Diverse package sources**: Balanced DNF’s conservative ecosystem with Nix’s broader application catalog.
* **Error handling**: Incorporated strict Bash flags and logging to trace each phase.

### Outcomes

On a fresh AlmaLinux 9.6 VM, a single invocation of `install.sh` now:

* Boots directly into a Qtile session via LightDM.
* Applies configured DPMS and screensaver settings without manual tweaks.
* Links all user‑level configs from a versioned repo into their operational locations.
* Integrates user D‑Bus notifications seamlessly.
* The workflow is setted up to merely add more directories into `install-links.sh` to automate future phases installation process. 
  
