# Devlog Entry 03 — Attempted AwesomeWM Installation

**Date**: 2025-June-8  
**Author**: Emile Avoscan  
**Entry ID**: #03  
**Target Version**: 0.2.0  

### Objective

Begin **Phase 1** by installing and configuring the Awesome Window Manager (AwesomeWM) on a fresh AlmaLinux 9.6 Minimal install, alongside key GUI utilities.

### 🛠 Steps Taken

1. **Prepared repositories**: Enabled CodeReady Builder (CRB) and EPEL to access development headers and community packages.
2. **Installed core dependencies**: Attempted to install `awesome` and `rxvt-unicode` via `dnf`—success for `urxvt`, `awesome` not found.
3. **Explored RPM fallback**: Searched community RPM sources (pkgs.org, Fedora Copr) but no AlmaLinux-compatible AwesomeWM RPM found.
4. **Source build path**:

   * Installed Development Tools group
   * Installed myriad `*-devel` packages (XCB, Cairo, Pango, Lua, etc.)
   * Encountered missing libraries (`xcb-util-xinerama-devel`, `xcb-util-xkb-devel`)
   * Built and installed missing XCB extensions from source
   * Installed CMake for build configuration
   * Installed ImageMagick (`convert`) for graphical asset processing
   * Repeated builds, but ultimately hit unresolved dependency errors and build failures
5. **Debugging SSH**: Attempted to fetch libraries via GitLab, faced SSH and repository authentication issues that delayed progress.

### Challenges & Errors

* **Package availability**: Many development and GUI packages were unavailable in official AlmaLinux or EPEL repos.
* **Manual source builds**: Dependency churn—resolving `cmake`, ImageMagick, and XCB extensions proved time-consuming.
* **Authentication detours**: SSH key setup issues diverted focus from the core task.
* **Build errors**: `make` errors (127), missing commands, and unresolved `virtual:world` repository errors.

### Reflections

* **AwesomeWM on AlmaLinux** demands heavy manual dependency management, contrary to the goal of clean reproducibility. I've concluded that's possible to install it, but not simple at all, this makes reproducibility very hard to achieve.
* The friction from missing or misnamed RPMs undermines efficiency, delaying the start of usable WM configuration.

### Conclusion & Next Steps

* Abandon AwesomeWM for this project in favor of Qtile, which has a simpler installation process and the same or greater capacity for customization. It's slightly heavier and unnoticeably slower, but I think it's a valid tradeoff. 
* Prepare for a **fresh install** and update roadmap and architecture to reflect the switch.
