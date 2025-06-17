# **Development Log Entry #06 — Automating Nix and Rofi Installation Without Manual Sourcing or Reboot**

**Date:** 2025-06-11  
**Author:** Emile Avoscan  
**Target Version:** 0.3.0  

## Objective I: Initial Package Integration

This stage focused on installing core components required for the base setup:

* **Application launcher**: Rofi
* **Terminal emulator**: Kitty
* **File manager**: Thunar
* **User-level package management**: Nix (rootless mode)

To consolidate these, a reproducible automation process was designed using `installation.sh` for system-level setup and a helper script `user-nix-setup.sh` for user-scoped operations.

The investigation into Rofi's packaging led to exploring EPEL, Flatpak, COPR, and manual builds. However, due to inconsistent availability (e.g., Rofi absent in EPEL 9), Nix was selected as the delivery channel for its reproducibility and isolation.

Nix was initially installed in single-user mode using the `--no-daemon` flag. While functional, this setup introduced limitations, particularly around environment persistence and permission separation. These limitations later motivated a pivot to multi-user installation.

Kitty and Thunar were both installed using DNF, with Kitty being integrated into the Qtile config and a new keybinding assigned.

Script modularization followed. Two scripts were drafted: one for privileged steps and one for unprivileged installation. Challenges included ensuring correct path resolution, ownership of `/nix`, and executing scripts from any working directory. These were addressed using `$SUDO_UID/$SUDO_GID` and absolute paths.

### Key Issues Encountered:

* Rofi missing from official sources
* Missteps in sourcing the Nix profile
* Overengineering with flakes and unnecessary features
* Relative path failures in script chaining
* Permission entanglement from mixing root and user logic

### Lessons Learned:

* Separation of concerns between user and system operations simplifies permission management.
* Environment setup must be explicit and defensively written.
* Minimalism in configuration lowers complexity and failure surface.
* Manual command validation before scripting prevents brittle automation.

## Objective II: Transition to Multi-User Nix Installation

The switch to a daemon-based Nix setup on AlmaLinux required a clean reinstallation. The single-user configuration was removed, and the daemon installer rerun under `sudo`. The `nix-daemon` service was enabled, and a global environment configuration was introduced in `/etc/profile.d/nix.sh`.

To make the environment immediately available, attempts were made to source the new profile in the running session using `bash -l -c` and heredocs. These approaches initially failed due to subshell isolation and misuses of `sudo`.

Eventually, a successful method emerged: a `sudo bash -l -u "$SUDO_USER" << 'EOF'` block, ensuring the shell ran as a login session and sourced the necessary profiles. This provided a temporary but functional environment to validate the installation.

### Key Issues Encountered:

* Confusion between user and system-level profiles
* Invalid heredoc usage under `sudo`
* Misinterpretation of shell layers and environment inheritance
* AlmaLinux-specific profile sourcing behavior

### Lessons Learned:

* Explicit sourcing is essential in cross-shell scripting.
* `source` is a shell builtin, and thus cannot be passed through `sudo` directly.
* Subshells do not persist environment changes to the parent, necessitating strategic sourcing in the login shell.
* Distributions differ in how they invoke global profile scripts.

## Objective III: Automating Multi-User Nix Installation with SELinux Support

This phase emphasized full automation of Nix's daemon install, designed for reproducibility and compatibility with AlmaLinux 9.6 under the Qtile environment (SoulmateOS).

The installation was consolidated into a `nix-setup.sh` script, with privilege checks and minimal dependencies. SELinux enforcement required special handling:

* Temporarily disabled with `setenforce 0`
* AVC logs captured via `ausearch`
* Policy module created using `audit2allow`
* Re-enforcement guarded with `trap` to prevent persistent permissiveness

The environment was configured to persist across sessions by placing a profile script in `/etc/profile.d/` and sourcing it during installation. Package prerequisites were ensured with DNF, and script idempotency achieved with appropriate guards.

### Key Issues Encountered:

* Misuse of `exec bash`, which terminated the script prematurely
* Distinguishing which commands required root vs. user context
* SELinux denials due to improper enforcement state
* Missing audit tools for policy generation
* Small errors in here-documentation and profile sourcing

### Lessons Learned:

* SELinux must be handled cautiously; policy modules are preferable to disabling enforcement.
* Environment variables should be configured via defensively written scripts.
* Root-only scripts should avoid internal `sudo` calls to prevent privilege confusion.
* `set -euo pipefail` is critical for safe and clear execution paths.

## Objective IV: Delayed Execution via Systemd Oneshoot Service

A remaining issue was that environment changes made during the script were not retained by the invoking shell. The initial workaround tried to re-source the environment using `sudo -u "$SUDO_USER" source ...`, which failed because `source` is a shell builtin.

Quoting and fallback logic using `logname` helped restore correct user context. Eventually, the idea of splitting the installation into two stages emerged. The second script would run post-reboot using a `systemd` service marked `Type=oneshot`.

This cleanly avoided shell inheritance issues and provided a deterministic environment. Alternatives such as `cron @reboot` and `rc.local` were considered but rejected due to inconsistency across distros.

### Key Issues Encountered:

* Builtin vs executable confusion
* Incorrect user detection due to unset `SUDO_USER`
* Quoting and heredoc edge cases
* Non-persistent environment updates due to subshell semantics

### Lessons Learned:

* Delaying script execution until after reboot simplifies environment management.
* The Unix process model requires explicit orchestration when crossing user contexts.
* Using `systemd` for post-installation steps provides portability and reliability.

## Objective V: Eliminating the Reboot Requirement

This final step aimed to avoid rebooting altogether, streamlining installation by refining privilege escalation and environment handling. A hybrid user-root script model was adopted, using `sudo` selectively and a keep-alive loop (`sudo -v`).

Process substitution was abandoned due to permission issues under `sudo`. Instead, temporary files or plain piping were used to execute the Nix installer.

It was discovered that sourcing `/etc/profile.d/nix.sh` within a subshell sufficed to immediately install packages like Rofi. Persistence was ensured via the user's Nix profile.

Ultimately, the `nix-env -iA nixpkgs.rofi` invocation was performed in a subshell with the environment pre-sourced. This sidestepped parent shell pollution and offered a clean, immediate install path.

### Key Issues Encountered:

* Subshells do not affect parent environments
* `source` must occur within the same shell context to persist changes
* User privilege recovery (`sudo -u`) needed correct UID detection
* Misconceptions about how Nix profiles are loaded led to redundant steps

### Lessons Learned:

* Subshell-based operations are sufficient for user-scoped, profile-based installations
* Minimizing root usage and adopting least privilege principles improves maintainability
* The simplest solution—subshell sourcing—often goes unnoticed due to complexity bias
* Nix's internal handling of environment setup reduces the need for manual post-install hooks

## Final Remarks and Next Steps

This development phase succeeded in producing a reliable, flexible, and reboot-free Nix installation path. The solution balances privilege, persistence, and reproducibility, leveraging Nix's user profile design and Unix’s shell semantics.

**Next Steps:**

1. Document the package installation procedure in project docs.
2. Merge the alternative installation method into the main branch if testing confirms stability.
3. Initiate the next development milestone.

