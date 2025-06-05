# SoulmateOS Architecture

## Philosophy

SoulmateOS is built with a singular goal: to create a personalized, minimal, highly cohesive Linux environment that merges lightweight performance with curated design. It is not meant to serve the average user — it is designed to be a long-term companion OS for users who value total control over their computing experience.

The focus is on **manual configuration**, **sane defaults**, and a **harmonized visual style**, all while remaining transparent, versioned, and reproducible.

## Base Design Decisions

### OS Base: AlmaLinux Minimal
- Chosen for its **stability**, **predictability**, and **RPM ecosystem**
- A downstream RHEL rebuild that provides enterprise-grade robustness
- Easy to script and reproduce across systems

### Window Manager: AwesomeWM
- Tiling window manager chosen for:
  - Scriptability in Lua
  - Performance and responsiveness
  - High configurability and minimal dependencies

### Package Philosophy
- No full DEs (GNOME, KDE); instead, curated standalone tools
- Each major DE component (file manager, terminal, panel, etc.) is selected and integrated manually
- Tools chosen for functionality, aesthetic harmony, and resource efficiency

## Versioning and Git Strategy

- Follows [Semantic Versioning](https://semver.org/)
- Git tracks all config, theme, and documentation changes
- Each stable release will correspond to a reproducible state of the OS
- Licensing: Apache 2.0, with per-file copyright headers

## Security & Reproducibility

- One of the future design phases will involve creating an **installation script** with hardened defaults
- Scripts and configs will be designed to be portable and cleanly reinstallable
- The final state of the system will be version-pinned

## Planned Extensions

- Full documentation for every config choice
- Installer support
- Custom GTK and icon themes
- Optional layers for cloud, dev, or cybersecurity tooling
