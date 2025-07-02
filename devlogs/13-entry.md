# Devlog Entry 13 — Establishing Foundational Theming and Compositing

**Date**: 2025-06-28

**Author**: Emile Avoscan

**Target Version**: 0.6.0

## First Objective

This development cycle was focused on transitioning the SoulmateOS environment from a functional but unstyled state to a visually cohesive desktop. The primary objective was to select, install, and configure the foundational visual components, including the system-wide GTK theme, icon and cursor themes, and the Picom compositor for hardware-accelerated effects. This work represents the core of Phase 5: "Theming, Visual Cohesion, Widget Addition and Error Correction."

### Implementation

The implementation was approached by methodically layering each component of the visual stack, from the base GTK theme to the compositor responsible for effects.

#### Theming Foundation Selection

The Nordic theme suite was selected as the foundational visual identity for SoulmateOS. This choice was based on its subdued, low-contrast, and consistent color palette, which is well-suited for long-term use by developers and power users, minimizing distraction and eye strain. To ensure high visibility and contrast against the dark Nordic theme, a white cursor theme, Bibata, was also chosen.

#### System-Wide Asset Installation

To ensure a consistent look across all applications and user contexts, the theme assets were installed system-wide. The process for the GTK, icon, and cursor themes was standardized:

1.  The latest release archives were downloaded directly from the official project GitHub repositories using `curl`.
2.  The archives were extracted using `tar`.
3.  The resulting directories were moved to their respective system-wide locations using `sudo mv`.
      * GTK Themes: `/usr/share/themes/`
      * Icon & Cursor Themes: `/usr/share/icons/`

#### Theme Activation via Configuration File

After significant troubleshooting with various settings daemons and command-line tools, a direct, daemon-free configuration method was implemented. The system's visual theme settings are now declared in a single, centralized INI file at `~/.config/gtk-3.0/settings.ini`. This approach was determined to be the most robust and transparent for a minimal environment. The file was initially configured as follows:

```ini
[Settings]
gtk-theme-name=Nordic
gtk-icon-theme-name=Nordic-darker
gtk-font-name=DejaVu Sans 11
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
```

#### Compositor Setup and Hardware Acceleration

Picom was installed via a single-user Nix profile to manage its dependencies without affecting the base system. The default configuration file was sourced from the official repository and placed at `~/.config/picom/picom.conf`. Initially it didn't work, so it became the next objective to make it fully functional.

### Challenges & Resolutions

  * **Challenge:** The Picom compositor failed to launch with the `glx` backend, producing a `Root visual is not a GL visual` error.

      * **Resolution Attempt:** After verifying that all Mesa drivers were installed, the Xorg log file was analyzed. It revealed that while the `glx` module was loaded, Direct Rendering Infrastructure (DRI) and Accelerated Indirect GLX (AIGLX) were not being enabled by default. The creation of a `20-intel.conf` file attempted to resolve the problem, but failed. 

  * **Challenge:** The GTK theme was not being applied to the Thunar file manager, despite attempts to set it with `gsettings` and `xfconf-query`.

      * **Resolution:** It was determined that in a minimal Qtile session without a running settings daemon, applications were not receiving the configuration broadcast. Instead of introducing a potentially conflicting daemon, the direct `settings.ini` fallback method was adopted, which proved to be a more stable and reliable solution.

  * **Challenge:** A fresh installation exhibited a complete failure of all Qtile keybindings, initially suggesting a catastrophic software or configuration conflict.

      * **Resolution:** After extensive software troubleshooting, the issue was traced to a hardware-level "Win Lock" feature on the keyboard. The lock was disabled using the `Fn + Win` key combination, immediately restoring all functionality. This served as a critical reminder to validate the hardware layer before diving into complex software diagnostics. And it was quite funny too.

### Testing & Validation

  * Hardware acceleration was definitively verified using `glxinfo | grep "direct rendering"`, which returned `direct rendering: Yes` after the fix. The `glxgears` utility was also used to observe smooth, high-FPS rendering.
  * Keyboard functionality was tested at both the kernel level with `showkey` and the X11 level with `xev` to diagnose the keybinding failure.
  * Successful theming was verified by visually inspecting Thunar and other GTK applications to ensure the Nordic theme, icons, and cursors were all correctly applied.

### Outcomes

  * A consistent, system-wide visual theme (Nordic) has been successfully implemented.
  * Hardware-accelerated compositing via Picom's `glx` backend is fully functional, enabling effects like transparency without performance degradation.
  * A robust, daemon-free, and transparent method for theme application (`settings.ini`) has been established as the standard for SoulmateOS, perfectly aligning with the project's core principles.

## Reflection

This implementation cycle was a profound lesson in the core philosophy of SoulmateOS. The initial attempts to integrate components from full desktop environments (like `xfce4-settings`) resulted in complex, hard-to-diagnose session conflicts. The resolution, in every case, was to retreat from this complexity and embrace a more direct, simple, and transparent solution.

The decision to use a plain text `settings.ini` file over a settings daemon and a binary database is a perfect embodiment of the "Minimalism with Power" and "Total User Control" pillars. It provides the desired outcome with zero process overhead and a configuration that is both human-readable and easily reproducible.

Furthermore, the keyboard lock issue was a humbling reminder that the troubleshooting process must be holistic. Hours spent investigating intricate software interactions were ultimately resolved by a simple hardware-level check. This experience reinforces the need for methodical, layered diagnostics, starting from the physical and working up to the abstract. Ultimately, the challenges encountered have served to validate the project's foundational approach: building up from a minimal base, with each component deliberately chosen and understood, leads to a more stable and resilient system.

## Second Objective

The primary objective of this session was to enable hardware-accelerated compositing on the SoulmateOS base system. The goal was to successfully launch the Picom compositor, which was installed via a single-user Nix environment, using its high-performance `glx` backend. This required ensuring the host AlmaLinux 9 system was correctly configured to provide OpenGL acceleration and that the Nix environment could properly interface with the host's graphics drivers.

### Implementation

The implementation process was divided into two distinct phases: configuring the host system and then attempting to bridge the environment gap to the Nix-installed application.

#### Host System Graphics Configuration

First, a baseline for system-level hardware acceleration was established. The necessary Mesa drivers (`mesa-dri-drivers`) and OpenGL utilities (`glx-utils`) were confirmed to be installed via the `dnf` package manager. An inspection of the device files in `/dev/dri` revealed that the kernel had correctly created the `card0` and `renderD128` nodes for the Intel integrated GPU.

A critical configuration step was performed to grant the user account access to these hardware devices. The user account, `emile`, was added to the `video` and `render` groups using the command `sudo usermod -a -G video,render emile`. A full system reboot was performed to ensure these new group memberships were applied to the user's graphical session.

#### Verification of Host System Acceleration

Following the permission changes and reboot, the host system's graphics stack was validated. The `glxinfo -B` command was executed. The output successfully confirmed that direct rendering was enabled (`direct rendering: Yes`) and that the correct OpenGL renderer (`Mesa Intel(R) HD Graphics 530 (SKL GT2)`) was being utilized. This step concluded the successful configuration of the host system's hardware acceleration.

### Challenges & Resolutions

The path to enabling the compositor was met with significant challenges, primarily related to environment isolation.

* **Challenge:** The initial and persistent issue was the failure of the Nix-installed Picom to launch. It consistently aborted with the fatal error: `Root visual is not a GL visual`. This occurred even after the host system's hardware acceleration was confirmed to be working correctly.
* **Solution Attempt:** The hypothesis was formed that Picom, living within the isolated Nix store, was unable to locate the host system's Mesa drivers. The proposed solution was to explicitly define the driver location by setting the `LIBGL_DRIVERS_PATH` environment variable before launching the application.

* **Challenge:** The primary difficulty then became programmatically discovering the correct host driver path for this variable. Several methods were attempted to find the location of the `iris_dri.so` file.
* **Solution Attempt:** Three distinct commands were executed in sequence to find the path. First, a `find` command was used, which yielded no results. Second, an `rpm -ql` query was attempted, which also failed to return the path. Finally, a more advanced technique using `lsof` to inspect the files opened by a running `glxinfo` process was attempted. This also failed, as the `pidof glxinfo` subcommand did not capture the process ID before it terminated. All automated discovery methods were exhausted without success.

### Testing & Validation

* **Host System Test:** The `glxinfo -B` command served as the definitive validation test for the host system. The positive result (`direct rendering: Yes`) confirmed that the base OS was no longer the source of the problem.
* **Application Test:** The test for the final objective was launching `picom` from the terminal. This test continues to fail with the `Root visual is not a GL visual` error, indicating the environment variable issue remains unresolved.

### Outcomes

The work performed resulted in a significant step forward. The host AlmaLinux system is now fully and correctly configured to provide hardware-accelerated OpenGL rendering for any native application that requires it. The core problem has been successfully isolated from a system-wide issue to a specific, well-understood challenge of environment interaction between the host OS and the Nix-managed application. The final resolution is pending the successful identification of the host's DRI driver path.

## Reflection

This troubleshooting session underscores a foundational principle of the SoulmateOS project: transparency. The layered complexity of a modern Linux system, especially when integrating an isolated environment like Nix, requires a methodical, bottom-up approach to debugging. Verifying the base system's functionality before addressing the application layer was a critical decision that prevented wasted effort.

The failure of multiple automated discovery methods highlights the importance of not relying on "magic" commands. It reinforces the need for a deeper understanding of how the system's components—in this case, RPM packages and their file manifests—are structured. The problem has evolved from a vague "graphics don't work" issue to a precise question: "What is the exact file path to the Mesa DRI drivers provided by the `mesa-dri-drivers` package on AlmaLinux 9?" This level of specificity is a hallmark of a well-understood problem and is essential for achieving the project's goal of total user control and reproducibility.

## Final Objective

The primary objective of this session was to achieve a fully hardware-accelerated desktop environment by enabling the Picom compositor on a bare-metal AlmaLinux 9 system. Picom, installed via a single-user Nix environment, was failing to launch, preventing any graphical effects like transparency. The goal was to diagnose the root cause of the failure and implement a stable, persistent solution that integrates correctly with the Qtile window manager's startup sequence.

### Implementation

#### Host System Graphics Driver Configuration

Initial investigation pointed towards a permissions issue on the host AlmaLinux system. To resolve this, the active user account was granted access to the system's Direct Rendering Infrastructure (DRI) devices. This was accomplished by adding the user to the `video` and `render` groups. The change was applied after a system reboot.

```bash
# Command used to grant hardware access permissions
sudo usermod -aG video,render $USER
```

#### Nix Environment Graphics Driver Bridging

With host acceleration confirmed, the focus shifted to the Nix environment. The inherent isolation of Nix was preventing the sandboxed Picom application from accessing the host's Mesa drivers. The `nixGL` package was identified as the correct solution. It was designed specifically to act as a bridge, wrapping Nix applications to provide them with access to the host system's OpenGL libraries. `nixGL` was installed into the user's Nix profile.

```bash
# Command to install Picom and the necessary wrapper
nix-env -iA nixpkgs.picom nixpkgs.nixGL
```

#### Qtile Autostart Configuration

To ensure Picom and other services launch correctly upon login, the Qtile `autostart.sh` script was refined. A race condition was identified where Polybar could initialize before Picom, resulting in rendering artifacts. To create a more robust startup sequence, it was decided to run `pkill picom && NixGL picom` before initializing polybar. Very rarely picom initializes before polybar, but this is usually fixed by reloading qtile with the assigned keybind. 

### Challenges & Resolutions

  * **Challenge**: Picom failed to launch immediately, producing a fatal error: `Root visual is not a GL visual` followed by an assertion failure in `epoxy_get_proc_address`.

      * **Resolution Attempt**: This was traced to the host system. The user account lacked the necessary permissions to access the graphics hardware. The issue was resolved by adding the user to the `video` and `render` groups and rebooting the system.

  * **Challenge**: After fixing host permissions, the Nix-installed Picom still failed. It was determined that the Nix sandbox was isolating Picom from the host's Mesa drivers.

      * **Resolution**: The `nixGL` package was installed. Launching Picom via the `nixGLIntel` wrapper successfully provided the sandboxed application with the required OpenGL context from the host, resolving the launch failure.

  * **Challenge**: Initial attempts to manually discover the host's DRI driver path (for use with the `LIBGL_DRIVERS_PATH` variable) via `find`, `rpm -ql`, and `lsof` were unsuccessful.

      * **Solution Attempt**: These diagnostic methods failed to produce the required path, confirming that a manual override was not a straightforward solution. This failure reinforced the need for a specialized tool, leading to the adoption of `nixGL`.

### Testing & Validation

  * Host system acceleration was verified by running `glxinfo -B`. The output confirmed `direct rendering: Yes` and that the correct `Mesa Intel(R) HD Graphics 530 (SKL GT2)` (For the specific hardware used in the test) renderer was in use.
  * The primary validation was the successful, error-free launch of Picom using the command `nixGL picom`.
  * The final `autostart.sh` configuration was validated by logging out and back into the Qtile session multiple times. On each login, Polybar correctly displayed with the intended transparency, confirming Picom was initialized first.

### Outcomes

  * A fully functional, hardware-accelerated desktop environment was successfully established.
  * The Picom compositor is now operational, providing system-wide graphical effects as intended.
  * A robust, deterministic autostart script was created, ensuring a consistent and visually correct user session on every login.

## Reflection

This undertaking highlights the critical importance of layered problem-solving. The initial error message was from Picom, but the root cause spanned two distinct domains: host system permissions and package manager sandboxing. By first validating the foundational layer (the host OS) before addressing the application layer (the Nix environment), a clear diagnostic path was maintained.

Furthermore, this experience serves as a key insight into the philosophy of using Nix for package management on a non-NixOS system. The isolation provided by Nix is a powerful feature for ensuring reproducible builds, but it necessitates the use of explicit "bridge" tooling like `nixGL` when interaction with host-level resources like hardware drivers is required.

Finally, the refinement of the autostart script from a simple `sleep` to a state-aware `pgrep` loop is a microcosm of the SoulmateOS project's ethos: preferring robust, deterministic solutions over simple but brittle workarounds. The goal is not just to make something work, but to make it work correctly and reliably under all conditions.

## Final Conclusion

This development cycle successfully transitioned SoulmateOS from a bare-bones framework into a visually cohesive and performant desktop environment. By establishing the Nordic theme suite as the foundational aesthetic and enabling hardware-accelerated compositing with Picom, the core objectives of this phase were met. A consistent, daemon-free theming strategy using a simple `settings.ini` file now stands as a testament to the project's principle of "Minimalism with Power."

The journey was as much about problem-solving philosophy as it was about technical implementation. The challenges encountered, from a simple hardware keyboard lock to the complex interaction between the Nix sandbox and host system graphics drivers, consistently reinforced a critical lesson: methodical, layered diagnostics are paramount. The resolution was never found in adding more complexity, but in retreating to simpler, more transparent solutions. Verifying the host system's hardware access before debugging the application and choosing a dedicated bridging tool like `nixGL` over manual, brittle workarounds proved this approach correct.

Ultimately, this work has forged a desktop environment that is not only functional but also philosophically sound. The challenges have validated the core tenets of SoulmateOS—Total User Control, transparency, and deliberate simplicity—resulting in a stable, resilient, and deeply understood foundation poised for future development.

The next devlog will most likely focus on refining the ground for the scripting of the theming process. As well as resolving any bugs caused by the interaction between picom, eww, and gtk. 
