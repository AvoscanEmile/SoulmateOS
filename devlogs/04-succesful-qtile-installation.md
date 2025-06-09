# Devlog Entry 04 — Qtile Installation

**Date**: 2025-June-08  
**Author**: Emile Avoscan  
**Entry ID**: #04  
**Target Version**: 0.2.0  

### Objective

Install and configure the Qtile window manager on a fresh AlmaLinux 9 minimal install, integrating LightDM as the display manager and ensuring a reproducible, automated script.

### 🛠 Steps Taken

1. **Repository preparation**
   * Enabled `baseos`, `appstream`, `crb`, `extras`.
   * Installed EPEL (`epel-release`).
   * Imported and enabled RPM Fusion (free + non-free) with GPG keys.
2. **X11 & LightDM setup**
   * Installed `base-x` group, `lightdm`, and `lightdm-gtk-greeter`.
   * Applied cosmetic fix: created `/etc/rc.d/rc.local` and made it executable to silence systemd generator warnings.
   * Enabled `lightdm` service and set default target to `graphical.target`.
3. **Python environment**
   * Installed Python 3.11 and development tools (`python3.11-devel`, `pip`, `setuptools`, `gcc`, `pkg-config`, `libffi-devel`).
   * Managed multiple Python versions side-by-side, preserving system Python 3.9.
4. **C library dependencies**
   * Installed XCB, X11, Cairo/Pango, GLib/GObject introspection, and DBus devel headers (`xcb-util-devel`, `cairo-gobject-devel`, `gobject-introspection-devel`, etc.).
5. **Python bindings & Qtile**
   * Upgraded `pip` under Python 3.11.
   * Installed `xcffib`, `cairocffi`, `pangocairocffi`, `dbus-python`.
   * Pinned `PyGObject==3.50.1` for GLib 2.68 compatibility.
   * Installed Qtile (`qtile`) system-wide for Python 3.11.
6. **Session file & automation**
   * Created `/usr/share/xsessions/qtile.desktop` with `Exec=dbus-run-session qtile start`.
   * Developed a comprehensive `installation.sh` script: she-bang, `set -e`, root-check, non-interactive flags, grouping of commands, reboot prompt.
7. **Testing & validation**
   * Verified `which qtile`, version output, and PATH resolution.
   * Conducted manual TTY test (`dbus-run-session qtile start`).
   * Confirmed LightDM login loop resolved by using `Exec=qtile start`.
   * Tested `installation.sh` on a fresh AlmaLinux 9.6 minimal installation.
8. **Documentation**
   * Modified all the documentation of the project to reflect the changes. 

### 🐞 Challenges & Errors

* **Package naming differences**: RHEL-style `xcb-util-devel`, `dbus-devel` instead of upstream names.
* **Python version mismatch**: Qtile 0.31+ requires Python 3.10+ (PEP 604 syntax) → installed Python 3.11.
* **GIR version mismatch**: PyGObject 3.52+ requires GIRepository 2.0 → pinned PyGObject 3.50.1.
* **Missing headers**: `cairo-gobject.h` fixed by installing `cairo-gobject-devel`.
* **User-site vs. system-site pip confusion**: module import errors resolved by system-wide `pip install` under Python 3.11 and PATH adjustments.
* **LightDM session misconfiguration**: initial `Exec=python3.11 -m qtile start` failed under LightDM’s sanitized environment → simplified to `dbus-run-session qtile start`.

### 💡 Reflections

* **Dependency management** on RHEL-based distros requires deep understanding of DNF group names, repository scopes, and package aliasing.
* **Python ecosystem** on enterprise distributions often lags; side-by-side installations are essential for modern Python apps.
* **Automation** must handle edge cases (SELinux, rc-local warnings, display‐manager quirks) to be truly reproducible.
* **Persistence** and iterative debugging paid off—complex failures became solvable steps rather than blockers.
