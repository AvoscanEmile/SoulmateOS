# Devlog Entry 08 — User Package Installation process. 

**Date**: 2025-June-16  
**Author**: Emile Avoscan  
**Entry ID**: #08  
**Target Version**: 0.4.0

## First Objective

Do a first manual attempt at installing the selected software in the previous devlog. Solve any problems that appear along the way. 

### 🛠 Steps Taken

1. **Software discovery**

   * Verified availability of `celluloid` and `lollypop` through both Flatpak and Nix:

     * Celluloid: Available via `nixpkgs.celluloid`, also on Flatpak.
     * Lollypop: Available via Flatpak (and also in `nixpkgs` if needed).
   * Chose Nix as the preferred installation method for both.

2. **Installation**

   * Installed `celluloid` and `mpv` using:

     ```bash
     nix-env -iA nixpkgs.celluloid nixpkgs.mpv
     ```

3. **Initial test and error**

   * Ran `celluloid` to play an `.mp4` file.
   * Audio played, but video output failed with:

     ```
     failed to create EGL display
     ```

4. **Diagnosing EGL error**

   * Identified the error as a graphics driver mismatch: Nix binaries not accessing system OpenGL stack.
   * Attempted to resolve via `nixGL`, but package not found in default `nixpkgs`.

5. **Package removal**

   * Removed Nix-installed `mpv` to avoid runtime conflicts with system libraries:

     ```bash
     nix-env -e mpv
     ```
   * Cleaned Nix store of unused items:

     ```bash
     nix-collect-garbage -d
     ```

6. **Daemon-related issue**

   * While installing via `nix-env`, encountered:

     ```
     cannot connect to the socket at daemon-socket/socket
     ```
   * Diagnosed the issue as an attempt to run a multi-user `nix-env` operation without the `nix-daemon`.
   * Verified that this was due to a misconfiguration or improper install mode.
   * Reaffirmed that **single-user installs** don’t require the daemon and resolved the issue by going into a fresh nix single-user install.

7. **Shell environment fix**

   * Avoided reboot by sourcing Nix profile directly:

     ```bash
     source "$HOME/.nix-profile/etc/profile.d/nix.sh"
     ```
   * Confirmed this works as long as `nix.sh` is sourced in the user shell and no root context is involved.
  
8. **Succesfuly installed celluloid and lollypop. Validating proper functioning of the single-user nix environment**

    * Decided to postpone any app-internal fixes for posterior phases. Specially thinking about the related to optimization and customization. For the moment the fact that celluloid runs and it's simple to install is enough of a victory. 

### 🐞 Challenges & Errors

* **OpenGL context error**: `EGL display` failure caused by mismatched OpenGL environment in Nix-installed apps; solved by avoiding `mpv` in Nix.
* **nixGL not found**: Unable to use `nixGL` workaround due to it not being present in default channel.
* **Socket connection issue**: `nix-env` attempted to contact a nonexistent `nix-daemon`; clarified install mode distinction.
* **Conflicting installs**: Running both Nix and system versions of `mpv` led to confusion about runtime behavior; fixed by uninstalling the Nix version.
* **Shell environment not applied**: Lack of `$PATH` updates until `nix.sh` was sourced manually.

### 💡 Reflections

* **Nix tooling** is powerful but requires precise environment control—especially on non-NixOS systems. Avoid mixing system and Nix-installed libraries when dealing with hardware-accelerated components (like OpenGL).
* **Graphics-heavy applications in Nix** often require `nixGL` or alternatives to inject host OpenGL bindings; this is a known limitation outside NixOS.
* **Installing via `nix-env` in multi-user mode** without `nix-daemon` can silently fail—knowing the difference between install modes is essential.
* **Flatpak** is often more robust for GUI applications on traditional distros when Nix environment variables are fragile or incomplete.
* **Shell hygiene** (e.g., `source "$HOME/.nix-profile/etc/profile.d/nix.sh"`) is a lightweight substitute for rebooting when setting up Nix.

## Second Objective

Perform the installation of the remaining selected packages.
### 🛠 Steps Taken

1. **Markdown support in Geany**

   * Installed `geany-plugins-markdown` through dnf. This plugin ensures that there's a live markdown support inside geany. 
2. **Archive integration in Thunar**

   * Installed `engrampa` and `thunar-archive-plugin` through dnf.
3. **Reader tool comparison**

   * Confirmed Foliate lacks PDF support and plugin architecture.
   * Surveyed multi-format GTK3 readers: Evince (PDF only) vs. Foliate (EPUB/MOBI only).
   * Concluded they complement each other rather than overlap and installed both of them. Foliate through nix, evince through dnf. 
4. **GTK3 calendar alternatives**

   * Reviewed gsimplecal, Orage, Osmo, Focal, GNOME Calendar.
   * Identified Focal and GNOME Calendar for CalDAV; Orage/Osmo for minimal local use.
   * Decided none of them actually fit the philosophy or needs of the project.
5. **Productivity stacks**

   * Evaluated Focalboard, calcurse, gsimplecal: only calcurse offers aggressive notifications and task management.
   * Confirmed Focalboard Desktop lacks native reminders.
   * Decided to go for calcurse through nix, as it provides the best PM managemente experience. 
6. **Custom widget approach**
   * Decided to implement on later phases a designed GTK3 (`Gtk.Calendar`) and Qtile (`KhalCalendar`/`qtile_extras`) month‑view widgets.
   * Which will have integrated calcurse backend:
     * Hooked `notify-send` via `~/.calcurse/hooks/notify`.
     * Optional ICS export cron job for external widget marking.
   * Sample GTK3 Python script and Qtile config provided.
7. **Installed Gthumb and Firefox**
   * These two were merely installed via dnf. 
8. **Added all the selected and succesfully manually installed packages to the installation script**
   * Via Nix: celluloid, lollypop, foliate, calcurse
   * Via dnf: firefox, gthumb, geany-plugins-markdown, engrampa, evince, thunar-archive-plugin

