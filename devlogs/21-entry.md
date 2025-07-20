# Devlog Entry 21 — Project Reconceptualization due to Foundational Incompatibilities

**Date**: 2025-07-19

**Author**: Emile Avoscan

**Target Version**: Foundational Pivot

## Objective 1: Initial Pivot to AlmaLinux 10 due to GLIBC Incompatibility

This development cycle was initially focused on migrating user-space applications to Nix on AlmaLinux 9.6. However, this objective quickly evolved into diagnosing and resolving a fundamental `glibc` incompatibility, which ultimately forced a strategic pivot to AlmaLinux 10.0 as the project's new operating system foundation to enable a modern, Nix-managed desktop environment.

### Implementation

The process began with a test migration of the `kitty` terminal emulator from a DNF-installed package to a Nix-managed one using `nix-env -iA nixpkgs.kitty`. Upon migration, the application failed to launch via its `.desktop` file. Investigation revealed that while a `.desktop` file was correctly placed in `~/.nix-profile/share/applications/`, the desktop environment was not inheriting the necessary Nix environment variables, particularly `PATH`, for the `Exec=` command to locate the `kitty` binary. The resolution involved modifying the `Exec=` and `TryExec=` lines within the `.desktop` file to explicitly use the `nixgl` wrapper and its absolute path, ensuring correct environment setup, including `LD_LIBRARY_PATH` for GPU acceleration.

Despite the successful launch, a persistent `ImportError: ... GLIBC_2.38' not found` was observed. This error highlighted a critical version mismatch between Nix-built packages, which required GLIBC 2.38, and the AlmaLinux 9.6 host system, which provided GLIBC 2.34. This problem persisted even with `nixgl`, which addresses GPU library paths but not core library mismatches. Attempts were made to resolve this by downgrading the Nixpkgs channel to `nixos-23.05` and then `nixos-22.11` in an effort to find a channel built against a compatible GLIBC.

Realizing that AlmaLinux 9.6's frozen GLIBC version was a fundamental blocker for using modern Nixpkgs, the strategic decision was made to migrate the core OS foundation to AlmaLinux 10.0. This was informed by research indicating it ships with GLIBC 2.39, which would be compatible. In preparation, the `graphics.sh` script was adapted; the deprecated `base-x` groupinstall was replaced with individual packages like `xwayland`, `wayland`, `libdrm`, `mesa-libGL`, and `libglvnd-glx`.

### Challenges & Resolutions

* **Challenge**: Initial failure to launch Nix-installed `kitty` via `.desktop` file on AlmaLinux 9.6.
    * **Resolution**: The `.desktop` file in `~/.nix-profile/share/applications/` was modified to explicitly call the `nixgl` wrapper with the absolute path (`Exec=/home/youruser/.nix-profile/bin/nixgl kitty`). This ensured the correct environment variables were set for Kitty's execution.
* **Challenge**: Persistent `GLIBC_2.38' not found` error, indicating a fundamental `glibc` version mismatch between Nixpkgs and AlmaLinux 9.6.
    * **Resolution**: While downgrading to `nixos-23.05` provided a Kitty version that did not immediately crash, the GLIBC 2.38 error persisted, indicating even older stable channels had incompatible dependencies. The challenge was deemed unresolvable on AlmaLinux 9.6, leading to a strategic pivot to AlmaLinux 10.0.

### Testing & Validation

Initial testing consistently reproduced the `GLIBC_2.38' not found` error on AlmaLinux 9.6, validating the presence of the deep `glibc` incompatibility. The failure of older Nixpkgs channels to resolve the issue further confirmed that a platform change was necessary.

### Outcomes

This cycle resulted in the definitive identification of AlmaLinux 9.6's GLIBC 2.34 as a fundamental blocker. The primary outcome was the strategic decision to pivot the project's core foundation to AlmaLinux 10.0. While the immediate goal was not achieved, the process provided invaluable insights into platform-level compatibility issues and resulted in an updated `graphics.sh` script ready for the new OS.

## Objective 2: Migrating the Desktop Stack and Discovering the Wayland Imperative

With the OS foundation shifted to AlmaLinux 10, the objective was to establish a minimal graphical session using a lightweight Display Manager (DM) and a tiling Window Manager (WM) managed by Nix. This process revealed that AlmaLinux 10's architectural changes required a fundamental pivot from an X11-centric design to a Wayland-native approach.

### Implementation

Initially, GDM was installed (`sudo dnf install gdm`) but was found to pull in a significant portion of GNOME Shell, conflicting with minimalist goals. It was replaced with SDDM (`sudo dnf install sddm`), a more desktop-agnostic alternative. The core challenge arose when attempting to launch the X11-based Qtile WM. This resulted in a critical system failure, triggering a kernel dump (`kdump`). Investigation revealed that AlmaLinux 10 has deprecated the traditional Xorg session model, and the `base-x` package group no longer exists.

This architectural limitation forced the decision to abandon the X11/Qtile stack. A potential workaround, running Qtile inside a minimal Wayland compositor like `Cage`, was investigated but found to be unviable as `Cage` is not packaged for AlmaLinux 10. A native Wayland compositor, Hyprland, was selected as a replacement.

A minimal `hyprland` and `kitty` environment was installed via Nix (`nix-env -iA nixpkgs.hyprland nixpkgs.kitty`). A minimal `hyprland.conf` was created in `~/.config/hypr/`, and a `.desktop` session file was created to advertise the Hyprland session to SDDM. However, a new problem emerged: SDDM failed to detect the session file when it was placed in the standard user directory (`~/.local/share/wayland-sessions/`).

### Challenges & Resolutions

* **Challenge**: The initial DM, GDM, pulled in excessive GNOME dependencies.
    * **Resolution**: GDM was replaced with the more lightweight and modular SDDM.
* **Challenge**: A kernel crash occurred when attempting to launch the X11-based Qtile WM.
    * **Resolution**: Investigation revealed that Xorg sessions are deprecated in AlmaLinux 10. This required a major architectural pivot to a Wayland-native compositor.
* **Challenge**: The `Cage` compositor, a potential workaround for running X11 WMs, was not available in AlmaLinux 10 repositories.
    * **Resolution**: The plan to use an X11 WM was abandoned entirely in favor of a native Wayland compositor.
* **Challenge**: SDDM failed to detect the user-level `hyprland.desktop` session file.
    * **Resolution**: A systematic series of diagnostic tests ruled out file permissions, SELinux, and `systemd` sandboxing as causes. It was concluded that the SDDM package is intentionally configured to ignore user directories, a limitation that would need to be addressed.

### Testing & Validation

To diagnose the SDDM session issue, `ausearch` and temporarily setting `setenforce 0` were used to confirm SELinux was not the cause. The `systemctl show sddm.service` command was used to verify that `ProtectHome` was not active. A definitive test involved creating a custom `systemd` service that successfully accessed the file as the `sddm` user, thus isolating the issue to SDDM's internal logic.

### Outcomes

A minimal graphical stack using SDDM and Hyprland was defined for AlmaLinux 10. A deep understanding of the new graphical architecture of RHEL 10 derivatives was achieved. This cycle successfully redefined the project's technical scope to a Wayland-native foundation but ended with a new, specific problem: how to launch a user-managed Wayland session from a system-level display manager that ignores user session files.

## Objective 3: The AlmaLinux Dead End: Graphics Incompatibility and Strategic Re-evaluation

This objective began as an attempt to solve the SDDM session problem but evolved into an exhaustive investigation that uncovered a foundational, unresolvable incompatibility between the Nix-packaged graphics stack and the AlmaLinux 10 host. This failure prompted a strategic re-evaluation of the entire project platform.

### Implementation

#### Launcher Session and Graphics Troubleshooting
To bypass the SDDM issue, a "Launcher Session" strategy was devised. The plan was to create a minimal, system-wide session that SDDM could detect, which would then execute a script to launch the user's desired compositor. Attempts to use a lightweight WM like Sway, IceWM, or Openbox for this failed due to their unavailability in the AlmaLinux 10 repositories. As a fallback, the more readily available KWin was selected. An attempt to use a `--script` flag failed, so the implementation was revised to use the standard XDG autostart mechanism (`~/.config/autostart/`).

However, all attempts to launch Hyprland, either from the launcher or directly from a TTY, failed with persistent graphics errors, beginning with a `gbm failed to create a device` error. This kicked off an extensive troubleshooting process:
1.  **Permissions & Environment**: The user was added to the `video` and `input` groups. After this, a `wl_display_connect failed` error appeared, suggesting Hyprland was incorrectly trying to launch as a nested client. `DISPLAY` and `WAYLAND_DISPLAY` variables were unset, and `WLR_BACKENDS=drm` was exported to force the correct backend.
2.  **Iterative Nix Channel Switching**: With the environment cleaned, the core `gbm` and `EGL` errors returned, pointing to a deep driver incompatibility. A series of Nix channel switches was undertaken to find a compatible graphics stack:
    * `nixpkgs-unstable` and `nixos-25.05` (Mesa 24.x) both resulted in `gbm` errors, a known issue with the host's `i915` kernel driver.
    * `nixos-23.11` (Hyprland v0.32.3) resolved the `gbm` issue but introduced a new `EGL_EXT_platform_base not supported` error.
    * `nixos-24.05` (Hyprland v0.41.2) presented the same EGL error.
    * `nixos-23.05` (Hyprland v0.25.0) failed even earlier with a `m_sWLRRenderer was NULL!` error, indicating a complete failure to initialize the GPU.

#### Strategic Re-evaluation
The persistent incompatibilities led to a critical conclusion: the project's vision was not feasible on AlmaLinux 10. This prompted a research cycle to analyze the Linux desktop distribution landscape. Acknowledging the difficulty in finding precise market share data, the analysis synthesized qualitative data to identify four prominent families for desktop usage: **Debian**, **Arch**, **Fedora**, and **openSUSE**. It was concluded that focusing on these four would cover over 90% of the target user base.

### Challenges & Resolutions

* **Challenge**: Lightweight WMs (Sway, IceWM, Openbox) for the launcher session were not available in AlmaLinux 10 repositories.
    * **Resolution**: The plan was revised to use the more readily available KWin compositor as the launcher base.
* **Challenge**: Persistent `gbm` and `EGL` errors across all tested Nix channels, indicating a deep incompatibility between the Nixpkgs graphics stack and the AlmaLinux 10 kernel/Intel HD 530 driver.
    * **Resolution**: This was deemed unresolvable under the project's constraints. The resolution was a strategic decision to migrate SoulmateOS's base OS focus away from the RHEL family.
* **Challenge**: A lack of precise market share data for desktop Linux distributions.
    * **Resolution**: A qualitative analysis was performed by synthesizing community data, subreddit membership numbers, and niche surveys to identify the most prominent desktop families.

### Testing & Validation

Each Nix channel switch was validated by observing the change in Hyprland's version and the evolution of the crash report messages. The persistence of fatal errors after forcing backends and cleaning environment variables provided definitive evidence of the foundational incompatibility.

### Outcomes

This cycle resulted in a definitive, evidence-based diagnosis of an unresolvable incompatibility between Nix-packaged `wlroots`-based compositors and the AlmaLinux 10 graphics stack. This research prevented further wasted time and led to a strategic pivot. The project's focus was officially shifted away from AlmaLinux towards major desktop-oriented families, with Debian selected as the next target.

## Objective 4: A New Beginning: Establishing the Debian Foundation

Following the strategic decision to abandon AlmaLinux, the final objective was to execute that pivot by installing a minimal Debian base system. This process involved overcoming complex UEFI bootloader challenges to establish a stable and reproducible foundation for all future development.

### Implementation

The installation was initiated using a Debian "netinst" ISO with the text-based installer. Initial attempts resulted in a "no bootable device found" error. A meticulous troubleshooting process was required:
1.  **BIOS/UEFI Configuration**: Firmware settings were exhaustively reviewed. UEFI boot mode was enabled, Secure Boot and Fast Boot were disabled, SATA mode was set to AHCI, and old "ghost" boot entries from previous OS installations were manually removed from the boot order in the firmware.
2.  **Installation Media Integrity**: After an integrity check failed, the downloaded ISO's SHA256 checksum was verified against the official source, and the USB installer was recreated using Rufus in "DD Image mode" to ensure a bit-perfect copy.
3.  **Manual Partitioning**: To ensure a correct setup, manual partitioning was performed to explicitly create a 1GB EFI System Partition (ESP) formatted as FAT32 and mounted at `/boot/efi`, along with root (`/`, ext4) and swap partitions.
4.  **GRUB Installation**: During setup, GRUB was explicitly installed to the physical disk (`/dev/sda`). Critically, when prompted, the option to **"Force GRUB installation to the EFI removable media path"** was accepted. This provides a universal fallback bootloader location (`\EFI\BOOT\BOOTX64.EFI`) that all UEFI firmware is guaranteed to check, bypassing potential quirks with vendor-specific named boot entries. NVRAM variables were also updated to boot into the named "Debian" entry.
5.  **Kernel Selection**: The `linux-image-amd64` meta-package was selected to ensure automatic updates, and "generic" drivers were chosen for the `initramfs` to maximize portability.

### Challenges & Resolutions

* **Challenge**: Post-installation resulted in a "no bootable device found" error due to misconfigured UEFI settings and persistent old NVRAM entries.
    * **Resolution**: BIOS/UEFI settings were meticulously configured, and old boot entries were manually deleted from the firmware interface.
* **Challenge**: The Debian installer reported invalid installation media.
    * **Resolution**: The ISO checksum was verified, and the USB installer was recreated in "DD Image mode."
* **Challenge**: Potential for UEFI firmware to ignore the standard named "Debian" boot entry.
    * **Resolution**: The option to force GRUB installation to the EFI removable media path was accepted, creating a reliable fallback boot entry that solved the final boot issue.

### Testing & Validation

Each configuration change (BIOS, partitioning, USB creation) was followed by a full reboot to test bootability. System utilities like `lsblk`, `fdisk -l`, and `efibootmgr -v` were used to inspect the disk and bootloader state after installation. The definitive validation was the appearance of the GRUB menu and, ultimately, the Debian login prompt on the TTY.

### Outcomes

A minimal, headless Debian base system was successfully installed and configured. Complex UEFI bootloader issues were diagnosed and resolved, establishing a stable and reproducible foundation for the next phases of SoulmateOS development. This successful migration marks the end of a long and challenging diagnostic cycle and the true starting point for building the cross-distro desktop environment on a viable platform. Valuable experience was gained in diagnosing intricate cross-ecosystem compatibility issues and low-level boot processes.

## Reflection

This development cycle was a powerful lesson in the friction between a clean architectural vision and the messy, complex reality of implementation. The journey from AlmaLinux 9 to Debian 12 was not merely a sequence of technical hurdles, but a practical education in pragmatism. The initial assumption—that any stable enterprise base could host a modern, Nix-managed desktop environment—was thoroughly tested and proven false. This cycle underscored a critical project truth: a truly reproducible system cannot be built on an incompatible foundation, no matter how robust that foundation is in its intended context. The persistent, low-level failures with GLIBC and the graphics stack were not mere bugs, but symptoms of a fundamental ecosystem mismatch, forcing a pivot that, while costly in time, was essential for the project's long-term viability.

The most significant outcome of this period was not the final Debian installation, but the validation of a "fail forward" methodology. Each dead end, from the GLIBC mismatch to the final Hyprland crash on AlmaLinux 10, provided the incontrovertible evidence needed to justify the next, more drastic step. It proves that the most valuable progress is sometimes the definitive understanding of what doesn't work and why. This experience reinforces the core vision of SoulmateOS not as a static product, but as a process of continuous discovery. The deep, frustrating dive into the incompatibilities of one ecosystem has forged invaluable knowledge that will directly inform the strategy for achieving true cross-distro compatibility on the platforms that actually power the modern Linux desktop.
