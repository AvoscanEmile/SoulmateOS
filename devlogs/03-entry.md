# Devlog Entry 03 — When AlmaLinux Meets AwesomeWM

**Date**: 2025-06-08  
**Author**: Emile Avoscan  
**Target Version**: 0.2.0  

## Why AwesomeWM?

For Phase 1 of the environment setup, I aimed to deploy **AwesomeWM** — a fast, Lua-scriptable window manager known for its extensibility. My goal was to install and configure it atop a **minimal AlmaLinux 9.6** install. The challenge was to do this cleanly, using only reproducible package sources or, when necessary, well-documented source builds.

## Initial Setup: Repos and Expectations

AlmaLinux doesn’t ship with many GUI tools by default, so the first step was to enable the necessary repositories:

* **CRB (CodeReady Builder)** for development headers
* **EPEL** for access to community-maintained packages

After that, I ran the first pass of installations: `dnf install rxvt-unicode awesome`.

* **Result**: `urxvt` installed cleanly, but `awesome` wasn’t found. Not in BaseOS, AppStream, EPEL, or CRB.

This made it immediately clear I’d need either:

* A third-party RPM (via Copr or pkgs.org), or
* A full source build.

## RPMs: Dead Ends and Compatibility Walls

Before compiling anything, I explored prebuilt packages:

* Searched Copr, pkgs.org, and GitHub RPM repos.
* Found RPMs for Fedora and Arch derivatives, but none targeting **EL9** (RHEL/AlmaLinux 9).
* Fedora RPMs failed on dependency resolution or were outright incompatible due to missing base packages.

This wasn’t just about convenience — **using unverified RPMs compromises reproducibility and long-term maintainability**. With no stable RPM path, I pivoted to compiling from source.

## Going Manual: Source Build Breakdown

Building AwesomeWM from source on AlmaLinux required several steps — and a number of unexpected detours.

### Core Steps:

1. **Development Toolchain**
   Installed with:

   ```bash
   dnf groupinstall "Development Tools"
   ```

   Along with:

   ```bash
   dnf install cmake lua-devel gcc-c++ make
   ```

2. **Dependencies (XCB, Cairo, Pango, etc.)**
   Manually installed a laundry list of `*-devel` packages:

   * `xcb-util`, `xcb-util-keysyms`, `xcb-util-wm`, `xcb-util-cursor`
   * `libX11-devel`, `cairo-devel`, `pango-devel`, `glib2-devel`, etc.

3. **Missing XCB Extensions**
   Several key XCB libraries weren’t available:

   * `xcb-util-xinerama-devel`
   * `xcb-util-xkb-devel`

   These had to be cloned from upstream, built with `autotools`, and installed manually.

4. **ImageMagick / Graphical Asset Tools**
   Installed `ImageMagick` primarily for `convert`, which AwesomeWM’s build scripts call indirectly.

5. **SSH / Git Integration Hurdles**
   Some sources had to be cloned from GitLab via SSH, which led to detours:

   * SSH keys were misconfigured
   * Git remotes failed with authentication issues

   These were resolved eventually, but they **distracted from the main objective** and added avoidable friction.

6. **Build Failures**
   Even after resolving most dependencies:

   * Ran into `make` error 127 (command not found), often linked to path assumptions
   * Multiple rounds of fixing missing build tools (e.g., `pkg-config`, `luarocks`)
   * Encountered `virtual:world` repository resolution failures, likely due to unmet logical groupings in the dependency tree

## What Went Wrong — The Technical Summary

| Category             | Problem                                                                  |
| -------------------- | ------------------------------------------------------------------------ |
| Package Availability | Many GUI-related development libraries not in EPEL or CRB                |
| RPM Compatibility    | No AlmaLinux-ready AwesomeWM builds; Fedora RPMs failed to install       |
| Build Toolchain      | Manual builds exposed fragile assumptions and dependency inconsistencies |
| SSH + Git Issues     | Repository access blocked by key misconfiguration                        |
| Build Reliability    | Unresolved dependencies and broken build scripts                         |

## Reflections

I expected AlmaLinux to demand some manual work, but **AwesomeWM proved excessively brittle in this environment**. The distro’s enterprise focus and the WM’s bleeding-edge community orientation just don’t align well.

The process revealed a broader insight: **reproducibility on AlmaLinux breaks down quickly when the required packages stray outside the standard ecosystem**. Even meticulous documentation can’t make up for a dependency tree built on unstable ground.

## Decision: Drop AwesomeWM, Pivot to Qtile

Qtile emerged as the better alternative:

* Available via pip or AUR-like routes with fewer system dependencies
* Python-based, with strong modularity and built-in theming
* Slightly heavier, but startup latency is effectively negligible (\~100ms)

Given that the goal is to provide **a customizable yet reproducible GUI** across installs, Qtile offers the best compromise between flexibility and stability.

## Next Steps

* Wipe and reinstall AlmaLinux for a clean Qtile configuration
* Rewrite Phase 1 to reflect the change in WM stack
* Document Qtile install paths and window manager scripts

## Closing Thought

This wasn’t a failure — it was an exercise in constraint discovery. **AwesomeWM might still be viable in other environments**, but on AlmaLinux, it demands too much manual scaffolding to be maintainable. Qtile provides a better foundation moving forward.

