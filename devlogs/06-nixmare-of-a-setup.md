# Devlog Entry 04 — Setting up the automatic installation of Nix and Rofi while avoiding manual sourcing and rebooting. 

**Date**: 2025-June-11  
**Author**: Emile Avoscan  
**Entry ID**: #06   
**Target Version**: 0.3.0    

## First Objective

Installing the packages selected on the previous devlog:

* Integrating Rofi as an application launcher
* Installing Kitty terminal and Thunar file manager
* Adding a single-user, rootless Nix installation for user-level package management
* Bundling all steps into a reproducible `installation.sh` (plus a helper `user-nix-setup.sh`)

### Steps Taken

1. **Rofi Installation**

   * Explored EPEL, Flatpak, COPR, and manual compilation.
   * Settled on Nix for simplicity and isolation.

2. **Nix Single-User Install**

   * Ran the official script with `--no-daemon`.
   * Added `source ~/.nix-profile/etc/profile.d/nix.sh` to `~/.bashrc`.
   * Initially enabled experimental features, then reverted to minimal install.
   * Functional at the beginning, but caused serious problems down the line, the decision to change to a multi-user setup was taken later. 

3. **Rofi via Nix**

   * Installed with `nix-env -iA nixpkgs.rofi` (or `nix profile install nixpkgs#rofi`).
   * Verified with `which rofi` and `rofi -version`.

4. **Kitty Terminal Install**

   * Discovered EPEL packaged `kitty`; installed via DNF.
   * Updated Qtile’s default terminal and added a keybinding.

5. **Thunar File Manager**

   * Installed via DNF (also available via Flatpak/Nix).

6. **Script Automation**

    * Drafted `installation.sh` with root-level steps.
    * Created `user-nix-setup.sh` for unprivileged Nix install.
    * Resolved relative vs. absolute paths and correct ownership of `/nix` using `$SUDO_UID`/`$SUDO_GID`.
    * Ensured robust script execution regardless of working directory.

### Challenges and Errors

* **Rofi Unavailability**: EPEL 9 lacked Rofi; Flathub had no official Flatpak.
* **Nix Integration**: Forgetting to source the Nix profile; using root’s UID for `/nix` ownership.
* **Over-Engineering**: Enabling flakes prematurely when a simple `nix-env` was sufficient.
* **Script Path Issues**: Calling `user-nix-setup.sh` with incorrect relative paths.
* **Privilege Separation**: Mixing root and user operations in one script led to complexity.

### Reflections

* **Modular Scripts**: Splitting system-level and user-level tasks into separate scripts avoids permission and path issues.
* **Absolute Paths**: Leveraging `$HOME` or computing script directory ensures reliability.
* **Minimalism**: Starting with bare essentials (no flakes) reduces complexity and debugging overhead.
* **Iterative Testing**: Manual command testing before scripting smooths out errors in automation.

## Second Objective

Automating the installation of Nix in multi-user (daemon) mode on AlmaLinux, ensuring the Nix environment is automatically available for both current and future user sessions.

### Steps Taken

1. **Initial single-user installation** without sudo led to per-user profile (`/nix/var/nix/profiles/per-user/root/profile`).
2. **Cleanup and reinstall**: Removed single-user artifacts, reran Nix installer with `--daemon` under sudo, enabled `nix-daemon.service`.
3. **Persist system-wide environment**: Created `/etc/profile.d/nix.sh` via `tee`, containing `source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`, and set permissions to `644`.
4. **Ensure future interactive shells**: Appended `source /etc/profile.d/nix.sh` to `$USER_HOME/.bashrc` for the original user.
5. **Attempt immediate environment load**: Tried various `sudo -u "$SUDO_USER" bash -l -c 'source ...'` and heredoc patterns to source the environment in the current session.
6. **Diagnosed subshell vs. login shell issues**: Learned that `bash -l -c` spawns subshells that may not inherit environment, and `sudo` may misinterpret heredoc.
7. **Final working pattern**: Used `sudo bash -l -u "$SUDO_USER" << 'EOF'` with explicit sourcing of `/etc/profile` or `/etc/bashrc`, then `source /etc/profile.d/nix.sh`, to validate `nix --version` within one cohesive login shell instance.

### Challenges and Errors

* **Single-user vs. multi-user confusion**: Installing without privileges caused a per-user layout, missing `nix-daemon.sh`.
* **Heredoc syntax pitfalls**: Misplaced EOF markers, trailing slashes, and passing heredoc to `sudo` rather than the shell.
* **`source` in `sudo` context**: Cannot use `sudo source`, as `source` is a shell builtin and executed in root's shell.
* **`bash -l -c` layering issues**: Environment loaded in one shell instance but lost in the `-c` subshell used by `sudo`.
* **AlmaLinux-specific profile loading**: `/etc/profile` vs. `/etc/bashrc` differences on RHEL derivatives.
* **File path typos**: Sourcing `/etc/profile/` (with trailing slash) instead of `/etc/profile` caused file-not-found errors.

### Reflections

* Shell initialization mechanisms vary significantly across distributions and shell types; relying on implicit behavior can lead to non-reproducible setups.
* For automated scripts, clarity and explicit sourcing order (e.g., forcing `/etc/profile` or `/etc/bashrc`) is critical.
* Communicating to users via prompts (e.g., echo instructions) remains a robust fallback when environmental manipulation in scripts proves brittle.

### Conclusions and Next Steps

* **Conclusions**: The final heredoc approach within a single login shell ensures reliable environment activation for current and future sessions. Explicit sourcing of system-wide profiles addresses distribution quirks.
* **Next Steps**:

  1. Update the installation script to use the proven heredoc pattern.
  2. Test on a clean AlmaLinux VM and document any additional edge cases.

## Third Objective

The primary goal was to develop an **automated, multi‑user Nix installation script** for an AlmaLinux 9.6 minimal environment under a Qtile window‑manager setup (SoulmateOS), ensuring:

* **Non‑interactive** installation of Nix in daemon mode
* Proper handling of **SELinux** (install under permissive, generate a policy module, restore enforcing)
* **Global environment** persistence for all users
* Minimal external dependencies and robust error handling

### Steps Taken

1. **Initial Script Draft**

   * Began with a two‑script approach: `installation.sh` (root) invoking `user-nix-setup.sh` (user).

2. **Privilege and `sudo` Review**

   * Removed unnecessary `sudo` calls inside a script already run as root.
   * Ensured top‑level enforcement check (`EUID==0`) and eliminated `sudo -u` for multi‑user install.

3. **SELinux Workflow**

   * Switched to permissive mode (`setenforce 0`) before Nix install.
   * Captured AVC denials via `ausearch`.
   * Installed `audit2allow` from `policycoreutils-python-utils`.
   * Generated and loaded a custom `nix-install.pp` policy module.
   * Restored enforcing mode (`setenforce 1`) with a `trap` to guard against early exit.

4. **Environment Persistence**

   * Used `tee /etc/profile.d/nix.sh` to write a global profile script for all users.
   * Optionally sourced it immediately for the active shell.

5. **Final Refactor**

   * Consolidated into a single `nix-setup.sh` that assumes root context.
   * Simplified invocation in `installation.sh` via dynamic `$SUDO_USER` home lookup.
   * Added prerequisite installs (`curl`, `tar`, `audit`, `policycoreutils-python-utils`).
   * Ensured idempotency and path checks on the setup script.

### Challenges and Errors

* **`exec bash` Behavior**: Discovered that `exec bash` replaces the running script, halting subsequent steps.
* **User vs. Root Context**: Debated whether parts of install must run under invoking user vs. globally as root.
* **SELinux Denials**: Installer blocked under enforcing mode; required temporary permissive mode and policy module creation.
* **Missing Tools**: `audit2allow` not available until `policycoreutils-python-utils` was installed.
* **Here‑doc Syntax**: Minor issues writing `/etc/profile.d/nix.sh`, resolved using `tee`.
* **DNF Config‑Manager**: Needed `dnf-plugins-core` for enabling repos on minimal install.

### Reflections

This process highlights the intricacies of **automating system‑level installs** on a hardened distribution:

* **Privilege management**: Always clarify root vs. user context early.
* **SELinux**: Real‑world installs often collide with enforcing policies; policy modules are a safer alternative to disabling enforcement.
* **Idempotency & Error Handling**: A single script with `set -euo pipefail` and traps reduces the risk of leaving systems in a broken state.
* **Dynamic Paths**: Using `$SUDO_USER` to discover user home makes the installer portable across accounts.

### Conclusions and Next Steps

* **Throughly test the installation script in both a VM with a fresh AlmaLinux install and a physical machine with it. 
* **Snapshot Baseline**: Create a VirtualBox snapshot of the clean AlmaLinux + Nix state for rollbacks.
* **Documentation**: Draft a README summarizing usage and potential troubleshooting steps for users.

## Fourth Objective

Resolving the issue that forces the user to call `source /etc/profile.d/nix.sh` manually with user-level sin the script running at sudo level privileges doesnt work properly. The initial approach was trying to run the script in two separated parts, the second one running after reboot by making a service `type=oneshot`.

### Steps Taken

1. **Initial attempt**: Tried `sudo -u "$SUDO_USER" source /etc/profile.d/nix.sh`, encountered error because `source` is a shell builtin.
2. **Wrapped in shell**: Used `sudo -u "$SUDO_USER" bash -c 'source /etc/profile.d/nix.sh'`, but `SUDO_USER` was empty.
3. **Diagnosed empty `SUDO_USER`**: Discovered `SUDO_USER` was unset when not invoked via sudo. Introduced fallback methods (e.g., `logname`).
4. **Used `logname`**: Captured original user with `user=$(logname)` and ran:

   ```bash
   sudo -u "$user" bash -ic 'source /etc/profile.d/nix.sh; nix --version'
   ```
5. **Environment persistence**: Observed `nix` availability only in subshell; parent shell lost environment on exit.
6. **Captured and imported env**: Demonstrated capturing variables via `env > tmpfile` in subshell and sourcing them in main shell with `set -a`.
7. **Investigated complexity**: Explored reasons (Unix environment isolation, `sudo` context switch, shell builtin behavior).
8. **Pivot to reboot strategy**: Decided to reboot at the end of the first script and run `installation-2.sh` on startup.
9. **Reviewed methods**: Compared `systemd` service unit, `cron @reboot`, and `rc.local`.
10. **Implemented `systemd` oneshot**: Created `installation-2.service` with `Type=oneshot`, enabled it, and explained it runs once per boot.

### Challenges and errors

* **Builtins vs executables**: `source` cannot be invoked directly via `sudo` without a shell.
* **Empty `SUDO_USER`**: Occurred when not using `sudo` or using `sudo -E`.
* **Quoting and syntax**: Misplaced quotes led to `sudo` usage errors.
* **Environment isolation**: Parent shell cannot inherit environment changes from child processes.
* **Complexity of shell initialization**: Different shells and distros handle profile scripts differently.
* **Frustration**: Multiple attempts and pitfalls led to repeated failures and emotional frustration.

### Reflections

* The Unix security model's process isolation is both a strength and a source of complexity for environment management.
* Relying on login shells and full reboot sequences can sidestep transient environment issues, but at the cost of additional steps.
* Automating multi-stage installations requires careful planning of how and when environment variables are loaded and persisted.

### Conclusions and next steps

* **Conclusion**: Using a `systemd` oneshot service provides a clean, reliable way to run `installation-2.sh` after reboot, avoiding manual environment hacks. Nonetheless, I believe there's an alternative way that might avoid forcing the reboot on the user, it will be tried in the next objective.
* **Next steps**:

  1. Look for a different approach to implement the installation of rofi via nix that doesn't require rebooting the system and running a oneshort service. 
  2. Attempt to implement that method via a branch of the repository called alternative_installation.
  3. Test the alternative installation method in a VM, if succesful merge it back to the main branch.

## Final Objective

Attempt an alternative method of installation that avoids having to restart the computer, configuring the environment for immediate use, and installing `rofi` without doing manual sourcing. 

### Steps Taken

1. Discussed running scripts with `sudo` and the principle of least privilege. 
2. Refactored a monolithic root-run script into a user-level script with selective `sudo` calls and a `sudo -v` keep-alive loop.
3. Explored process substitution issues when running installers via `sudo sh <(...)` and switched to piping or temporary files.
4. Examined how the Nix installer internally calls `sudo` when running `sh <(curl ...) --daemon --yes`.
5. Verified multi-user install via checking `nix-daemon` systemd service, `/nix` directory ownership, `/etc/profile.d/nix.sh`, and `nixbld` group.
6. Investigated why `source /etc/profile.d/nix.sh` inside a script did not persist changes in the parent shell.
7. Established that sourcing requires `source` invocation of the installation script itself and its sub-scripts to affect the current shell. Discarded this approach. 
8. Discovered the use of subshells as installationg methods: sourcing `nix.sh` within a subshell allows immediate package installs that persist in the Nix profile.
9. Succesfully attempted installing `rofi` via `nix-env -iA nixpkgs.rofi` in a sourced subshell and confirmed persistence of installation.
10. Explored alternative Nix install commands: `nix profile install nixpkgs#rofi`, `nix-shell -p rofi`, and system-wide installations.

### Challenges and Errors

* Default `sudo`-invoked scripts run entirely as root, losing user environment and requiring explicit `sudo -u` to drop privileges.
* Resurrecting the original user environment within a root shell proved impossible without external delegation.
* `sudo sh <(curl ...)` failed due to process substitution permissions.
* `source /etc/profile.d/nix.sh` in non-login, non-interactive scripts affected only the subshell and did not persist.
* Sourcing chain complexity: ensuring both parent and sub-scripts propagate environment changes was proved very challenging and complicated to implement. 
* Understanding and orchestrating subshell behavior versus parent shell for persistent environment was a struggle, but once understood lead to the decision of installing rofi within the subshell. 

### Reflections

* Unix shell semantics around subshells and sourcing remain a subtle source of complexity, nonetheless the simpler solution always seems to be the most easily ignored. It's perfectly possible to do package installations within a subshell. I considered this option, but was resistant at first because I wanted to keep all the installation calls within the same script. 
* The principle of least privilege significantly improves script safety and debuggability, it's easier to increase privileges when necessary than properly decrease them when necessary. 
* Nix’s design of user profiles ensures persistence of installations, decoupled from session state.
* Realized that it wasn't necessary to add a snippet that sourced the code into bash everytime the computer turned on, nix installation itself handles this. 

### Conclusions and Next Steps

* **Conclusions:** A reliable installation workflow must combine user-level scripts with selective `sudo`, careful sourcing, and user education on environment setup.
* **Next Steps:**

  1. Document the package selection and installation scripting process.
  2. Move onto the next phase of the project. 

