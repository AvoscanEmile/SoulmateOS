## SoulmateOS Roadmap

A structured, modular approach to building a lightweight, secure, and cohesive Linux-based environment using AlmaLinux Minimal and Qtile.

---

### Phase 0 — Github repo creation

**Goal:** Create the github repo with the basic structure, and the initial documentation.

* Add every relevant folder the project will have
* Add architecture.md, changelog.md, and roadmap.md to /docs
* Write initial `README.md`
* Choose a license.
* **Version Tag:** `0.1.0`

---

### Phase 1 — AlmaLinux installation and Qtile installation

**Goal:** Set the barebones of the project in place.

* Install Alma Linux
* Install Qtile and X11
* Install a lightweight login manager
* Boot into graphical environment
* Install minimal terminal and file manager
* **Version Tag:** `0.2.0`

---

### Phase 2 — System Utilities Layer + Git Setup

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

---

### Phase 3 — User Applications Layer

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

---

### Phase 4 — UX Enhancers & Session Polish

**Goal:** Complete the user experience with session utilities.

* Notification daemon
* Screenshot tool
* Clipboard manager
* Autostart configuration
* Idle monitor/screen locker (e.g., xss-lock + i3lock or alternatives)
* **Version Tag:** `0.5.0`

---

### Phase 5 — Theming, Visual Cohesion, Widget Addition and Error Correction.

**Goal:** Build a unified aesthetic, a base widget environment and resolve any problems related to app usage.

* Build relevant custom widgets (e. g. volume control, power menu). 
* GTK/QT theme
* Fonts and icons
* Wallpaper, cursor
* Align visuals across all apps
* Lightweight compositor (e.g., picom) for transparency, shadows, and effects
* Save themes in `themes/`
* **Version Tag:** `0.6.0`

---

### Phase 6 — Security Hardening

**Goal:** Lightweight but strong security baseline.

* Configure `firewalld` or `nftables`
* Harden SSH (disable root, change port)
* Enable SELinux
* Disable unnecessary services
* Document security in `docs/security.md`
* **Version Tag:** `0.7.0`

---

### Phase 7 — Automation, Optimization and Reproducibility

**Goal:** Optimize and automate deployment of the entire environment.

* Minimize default packages with the usage of dng-graph
* Bash or Ansible-based installer
* Dotfile deployment
* Scripted security and config setup
* Test in VM for reproducibility
* **Version Tag:** `0.9.0`

---

### Phase 8 — Finalization and 1.0 Release

**Goal:** Final testing, cleanup, and release.

* Final QA and stress test
* Polish all documentation
* Tag release as `1.0.0`
* Optional: Build ISO
* **Version Tag:** `1.0.0`

---

### Summary Table

| Phase | Focus Area                    | Tag     |
| ----- | ----------------------------- | ------- |
| 0     | Bootstrap + Git + Docs        | `0.1.0` |
| 1     | Qtile Base Setup              | `0.2.0` |
| 2     | System Utilities Layer        | `0.3.0` |
| 3     | User Applications Layer       | `0.4.0` |
| 4     | UX Enhancers & Session Polish | `0.5.0` |
| 5     | Theming & Visual Integration  | `0.6.0` |
| 6     | Security Hardening            | `0.7.0` |
| 7     | Installation Automation       | `0.8.0` |
| 8     | QA + Docs + Final Release     | `1.0.0` |
