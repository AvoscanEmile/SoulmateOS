## SoulmateOS Roadmap

A structured, modular approach to building a lightweight, secure, and cohesive Linux-based environment using AlmaLinux Minimal and AwesomeWM.

* * *

### Phase 0 — Bootstrap and Repo Initialization

**Goal:** Establish Git, project folders, and documentation.

- Install AlmaLinux Minimal
    
- Initialize Git and connect to remote
    
- Create `scripts/`, `config/`, `docs/`, etc.
    
- Write initial `README.md`
    
- **Version Tag:** `0.0.1`
    

* * *

### Phase 1 — Window Manager and Graphical Base

**Goal:** Functional graphical desktop using AwesomeWM.

- Install AwesomeWM and X11
    
- Configure `.xinitrc` or login manager
    
- Boot into graphical environment
    
- Install minimal terminal and file manager
    
- **Version Tag:** `0.1.0`
    

* * *

### Phase 2 — Core System Configuration

**Goal:** Make the system daily-driver capable.

- Configure locale, keyboard, time, power
    
- Install and configure shell (e.g., bash or zsh)
    
- Create keybindings and autostart scripts
    
- **Version Tag:** `0.2.0`
    

* * *

### Phase 3 — Security Hardening

**Goal:** Lightweight but strong security baseline.

- Configure `firewalld` or `nftables`
    
- Harden SSH (disable root, change port)
    
- Enable SELinux
    
- Disable unnecessary services
    
- Document security in `docs/security.md`
    
- **Version Tag:** `0.3.0`
    

* * *

### Phase 4 — System Utilities Layer

**Goal:** Add foundational system tools.

- Terminal emulator
    
- File manager
    
- Text editor
    
- Network manager
    
- System monitor
    
- Disk utility
    
- Optional: package manager frontend
    
- **Version Tag:** `0.4.0`
    

* * *

### Phase 5 — User Applications Layer

**Goal:** Add commonly expected user-facing applications.

- Web browser
    
- Media player
    
- Office/markdown tool
    
- Image viewer
    
- Archiver
    
- **Version Tag:** `0.5.0`
    

* * *

### Phase 6 — UX Enhancers & Session Polish

**Goal:** Complete the user experience with session utilities.

- Notification daemon
    
- Screenshot tool
    
- Clipboard manager
    
- Brightness/volume tools
    
- Power menu
    
- Autostart configuration
    
- **Version Tag:** `0.6.0`
    

* * *

### Phase 7 — Theming and Visual Cohesion

**Goal:** Build a unified aesthetic.

- GTK/QT theme
    
- Fonts and icons
    
- Wallpaper, cursor
    
- Align visuals across all apps
    
- Save themes in `themes/`
    
- **Version Tag:** `0.7.0`
    

* * *

### Phase 8 — Automation and Reproducibility

**Goal:** Automate deployment of the entire environment.

- Bash or Ansible-based installer
    
- Dotfile deployment
    
- Scripted security and config setup
    
- Test in VM for reproducibility
    
- **Version Tag:** `0.9.0`
    

* * *

### Phase 9 — Finalization and 1.0 Release

**Goal:** Final testing, cleanup, and release.

- Final QA and stress test
    
- Polish all documentation
    
- Tag release as `1.0.0`
    
- Optional: Build ISO
    
- **Version Tag:** `1.0.0`
    

* * *

### Summary Table

| Phase | Focus Area | Tag |
| --- | --- | --- |
| 0   | Bootstrap + Git + Docs | `0.1.0` |
| 1   | AwesomeWM Base Setup | `0.2.0` |
| 2   | Core System Configuration | `0.3.0` |
| 3   | Security Hardening | `0.4.0` |
| 4   | System Utilities Layer | `0.5.0` |
| 5   | User Applications Layer | `0.6.0` |
| 6   | UX Enhancers & Session Polish | `0.7.0` |
| 7   | Theming & Visual Integration | `0.8.0` |
| 8   | Installation Automation | `0.9.0` |
| 9   | QA + Docs + Final Release | `1.0.0` |
