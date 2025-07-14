# Devlog Entry 18 — Rofi Applet Scope Refinement, Powermenu Implementation, and Service Management Conceptualization for v.2.0 of the project. 

**Date**: 2025-07-10

**Author**: Emile Avoscan

**Target Version**: 0.6.0 / 2.0.0

## Main Objective

This development cycle was primarily focused on defining and implementing the Rofi applet strategy for SoulmateOS, ensuring alignment with the project's core tenets of minimalism, visual cohesion, and sane defaults. This involved a detailed evaluation of various Rofi applets, a decision on their inclusion, and the resolution of technical challenges related to font rendering. Concurrently, a conceptual framework for declarative service management within the future v2.0.0 Nix-based environment was established.

### Implementation

#### Rofi Applet Selection and Scope Adjustment

An initial assessment of Rofi applets from adi1090x's repository was conducted to identify suitable candidates for SoulmateOS 1.0.0. The MPD (Music Player Daemon) and Screenshot applets were initially considered for their potential to enhance user experience. However, a broader review led to the exclusion of several applets: "Apps as Root" was rejected due to security concerns and the availability of alternative methods for elevated privileges; "Apps" was deemed redundant with Rofi's default application search; and "Battery," "Brightness," and "Volume" applets were considered more appropriate for integration as Eww or Polybar widgets, or irrelevant for desktop systems. The scope for Rofi applets in 1.0.0 was ultimately narrowed to focus solely on the power menu applet, simplifying the initial release.

#### MPD Applet Implementation Postponement

The integration of the MPD applet, which relies on the `mpc` command-line client, presented significant complexities within the current hybrid Nix environment without Home Manager. While MPD and `mpc` were successfully installed via Nix, attempts to enable and start the `mpd.service` user service using standard `systemctl --user` commands failed. This was attributed to Nix's management of service unit files within its immutable store, requiring manual symbolic linking to `~/.config/systemd/user/`. This manual workaround was considered a temporary and "dirty fix" that contradicted the project's long-term goals for automation and reproducibility. Consequently, the implementation of the MPD applet was postponed entirely to the v2.0.0 development phase, where Home Manager's declarative service management capabilities will provide a robust and automated solution.

#### Rofi Screenshot Applet Implementation Postponement

Initially planned for inclusion to provide a visually cohesive screenshot workflow via Rofi, the screenshot applet's implementation was also postponed. This decision was made to further streamline the scope for SoulmateOS 1.0.0, allowing development efforts to be concentrated on the most essential Rofi utility (the power menu) and other critical components of the 1.0.0 release.

#### Rofi Theme Standardization for Cohesion

To ensure a highly cohesive and predictable user experience for SoulmateOS 1.0.0, a design decision was made to standardize all Rofi applets and the main launcher themes to a **vertical list layout with explicit text labels** for each action. This approach prioritizes clarity and a unified visual language across all Rofi interactions. To achieve this, any existing Rofi launcher themes that exhibited horizontal layouts or relied solely on icons were removed from the default selection.

#### Service Management Conceptualization for v2.0.0

A conceptual framework for managing services within the v2.0.0 Nix-based environment was developed, addressing the challenge of integrating imperative service actions with declarative conservation. It was determined that `soul install <package>` would handle Nix package installation but would not automatically enable associated services. Instead, a new set of `soul service` subcommands (e.g., `soul service enable`, `disable`, `start`, `stop`, `mask`) will be introduced. These commands will act as wrappers for `systemctl --user`, handling the location of Nix-managed `.service` unit files, creating necessary symbolic links, and interacting with `systemd`. The `soul save` command will then be responsible for detecting services explicitly enabled via `soul service enable` (by scanning `~/.config/systemd/user/` for Nix symlinks) and translating these into `services.<service-name>.enable = true;` declarations within the `home.nix` configuration. This approach provides explicit, user-driven control over service management while ensuring declarative conservation.

### Challenges & Resolutions

* **Challenge:** MPD and MPC packages were not available in AlmaLinux's default DNF repositories, necessitating installation via Nix.
    * **Resolution:** Installation through Nix was confirmed as a viable method for obtaining these packages.
* **Challenge:** `systemctl --user enable mpd.service` failed for Nix-installed MPD, as its unit file resided in the Nix store (`/nix/store/...`) and was not directly discoverable by `systemd` in standard user service paths.
    * **Resolution Attempt:** A manual symbolic link from the Nix-managed `.service` file to `~/.config/systemd/user/` was identified as a functional workaround.
    * **Resolution (Postponement):** This manual approach was deemed too complex and prone to breakage (e.g., on Nix package upgrades) for the current 1.0.0 development phase. Consequently, the MPD applet's implementation was postponed entirely to v2.0.0, where Home Manager's declarative service management will provide a robust and automated solution, eliminating the need for manual symlinking.
* **Challenge:** Specific Unicode icons within the Rofi applet's `mpd.sh` script were not rendering correctly in Kitty terminal or Rofi, appearing as empty boxes, despite other Rofi icons (e.g., the prompt colon) displaying as expected. This issue persisted even after ensuring the script was saved with UTF-8 encoding and the system locale was set to UTF-8.
    * **Resolution:** Extensive troubleshooting was performed using `printf` commands in Kitty to directly test Unicode glyph rendering. It was discovered that the installed `JetBrainsMono Nerd Font` and `Iosevka Nerd Font` files, despite being "Complete" versions, were missing the specific Unicode Private Use Area (PUA) glyphs used by the applet. A universal Nerd Font glyph (`\uf07b` - folder icon) was successfully rendered, confirming general font functionality. The `mpd.sh` script was subsequently modified to replace the problematic direct Unicode symbols with their corresponding Bash-compatible Unicode escape sequences (e.g., `\uE9AE`), ensuring consistent rendering.
* **Challenge:** Confusion arose regarding the resolution of relative paths (`.`, `..`) within Bash scripts compared to `@import` statements in Rofi's `.rasi` theme files.
    * **Resolution:** It was clarified that Bash resolves relative paths based on the script's current working directory (which can vary), while Rofi's `@import` directives resolve paths relative to the `.rasi` file itself. To ensure consistent theme loading for the Rofi applet, the absolute path to the chosen `.rasi` theme was explicitly defined within the `mpd.sh` script.

### Testing & Validation

Throughout this development cycle, testing and validation were performed iteratively. Direct execution of the `mpd.sh` script from the terminal was used to observe Rofi's visual output and behavior. `printf` commands with specific Unicode escape sequences were extensively employed within Kitty to verify the terminal's and underlying font's ability to render individual glyphs. `fc-list` was utilized to confirm installed font names and their recognition by the system's font configuration. Modifications to `kitty.conf` and Rofi theme files were followed by closing and reopening Kitty instances (using `pkill kitty` for thoroughness) to ensure changes were loaded. This rigorous testing approach was instrumental in diagnosing and resolving the complex font rendering issues.

### Outcomes

The scope for Rofi applet integration in SoulmateOS 1.0.0 was definitively narrowed to focus solely on the power menu applet, with media control and screenshot applets postponed to the v2.0.0 development cycle. This strategic decision streamlines the 1.0.0 release, prioritizing a stable and cohesive core. A clear strategy for Rofi theme standardization was established, enforcing a vertical list layout with text labels across all applets and launcher themes to ensure visual uniformity. Furthermore, a detailed conceptual framework for declarative service management within the v2.0.0 Nix-based environment was developed, outlining how the `soul` CLI will provide explicit, user-driven control over services while enabling their declarative conservation in `home.nix`.

## Final Objective

The final objective of this development cycle focused on the integration of a Rofi-based power management menu into SoulmateOS, aligning with Phase 5 of the roadmap: "Theming, Visual Cohesion, Widget Addition and Error Correction." The primary goal was to establish a functional, aesthetically cohesive power menu accessible via a Qtile keybinding, thereby enhancing the user experience and system usability beyond command-line interactions.

### Implementation

#### Rofi Power Menu Script Adaptation

The initial step involved adapting an existing Rofi power menu script sourced from adi1090x. This script required substantial modification to align with SoulmateOS's specific requirements and design philosophy. Key changes included the removal of the "lock" option, as account locking is not within the current project scope. The logout command was refined from an aggressive `kill -9 -1` to a cleaner `qtile cmd-obj -o cmd -f shutdown`, ensuring graceful session termination within the Qtile environment. The "hibernate" option was also removed to maintain a minimal and less complex system footprint, while "suspend," "reboot," and "shutdown" functionalities were retained, leveraging `systemctl` commands for standard system power management. Unicode escape sequences for icons were adopted to enhance visual appeal, with `echo -e` used during variable assignment to ensure proper interpretation by Rofi and consistent matching within the script's `case` statement.

#### Rofi Theming Configuration

A dedicated Rofi theme file (`theme.rasi`) was created for the power menu, located at `~/.config/rofi/applets/power/theme.rasi`. This file was configured to ensure a vertical layout for the power options, overriding previous horizontal display settings. The `listview` property `lines` was precisely set to `4` to match the number of displayed options, eliminating excess space below the last entry. Additionally, the main Rofi configuration was updated to enable the display of application icons by setting `show-icons: true;` within the `configuration` block, ensuring visual consistency across different Rofi modes.

#### Qtile Keybinding Implementation

A dedicated keybinding was established in `config/qtile/config.py` to trigger the Rofi power menu. The `Mod + p` combination was selected for its intuitive association with "power" and its minimal conflict with existing Qtile defaults. The `lazy.spawn()` function was utilized, with the script's absolute path dynamically constructed using `os.path.expanduser("~")` and `os.path.join()` to ensure correct path resolution by Qtile.

#### Picom Shadow Refinement

Initial attempts to apply global shadows via Picom resulted in visual artifacts around Polybar's rounded corners. This was identified as a conflict arising from the `dock` wintype rule in `picom.conf`, which explicitly disabled shadows for elements categorized as docks. A decision was made to maintain the `shadow = false;` setting for the `dock` wintype, thereby preventing shadows on Polybar and avoiding the aesthetic glitch, prioritizing visual consistency over universal shadow application. Global shadow settings for other windows were maintained.

#### Installer Integration

To ensure the Rofi power menu script is fully operational after a fresh installation, a `chmod +x` command was added to `install/modules/config.sh`. This step explicitly grants execute permissions to `power.sh` during the automated setup process, making it directly executable by Qtile via its shebang. This ensures a seamless out-of-the-box experience for the user.

### Challenges & Resolutions

* **Challenge**: Initial Rofi power menu script displayed options horizontally instead of vertically.
    * **Resolution**: The `rofi_cmd()` function in `power.sh` contained a `-theme-str "listview {columns: 4; lines: 1;}"` override. This was removed, allowing the `listview { columns: 1; layout: vertical; }` setting in `theme.rasi` to take effect.
* **Challenge**: Extra blank space appeared below the last option in the Rofi menu.
    * **Resolution**: The `listview { lines: 5; }` property in `theme.rasi` was adjusted to `lines: 4;` to precisely match the number of displayed options, eliminating the excess space.
* **Challenge**: Rofi power menu functionality broke, with no confirmation dialog or command execution.
    * **Resolution**: The `option_x` variables were defined using string literals (e.g., `"\uF705 Logout"`) which did not match the actual Unicode characters returned by Rofi. This was resolved by using `option_x=$(echo -e "\uF705 Logout")` to force interpretation of Unicode escape sequences during variable assignment, ensuring consistency for the `case` statement.
* **Challenge**: Rofi power menu prompted for confirmation even when the main menu was cancelled (ESC key).
    * **Resolution**: An `if [[ -z "$chosen" ]]; then exit 0; fi` block was added immediately after `chosen="$(run_rofi)"` to detect and silently exit the script if the main Rofi menu was cancelled, preventing the unnecessary confirmation dialog.
* **Challenge**: Shutdown option was not displaying in the Rofi menu.
    * **Resolution**: This was traced to a subtle syntax issue where a comment (`# Changed`) immediately followed the closing parenthesis of the `echo -e` command substitution for `option_4`. Adding a space between the `)` and `#` resolved the parsing error.
* **Challenge**: Shadows were not applying to Polybar despite global Picom shadow settings.
    * **Resolution**: The `dock = { shadow = false; ... };` rule within the `wintypes` section of `picom.conf` was identified as overriding the global shadow setting for Polybar (which is categorized as a `dock`). A decision was made to retain `shadow = false;` for `dock` wintypes to avoid visual glitches with rounded corners, effectively disabling shadows for Polybar.
* **Challenge**: Qtile keybinding for the Rofi power menu was not launching the script, despite the command working in a terminal.
    * **Resolution**: This was due to `lazy.spawn()` not performing tilde (`~`) expansion and not automatically invoking a shell for the script. The `config.py` was updated to use `os.path.expanduser("~")` and `os.path.join()` to construct the absolute path to the script. Additionally, it was confirmed that the script required executable permissions (`chmod +x`) for the shebang to function correctly.
* **Challenge**: The `power.sh` script was not executable after a fresh installation.
    * **Resolution**: A `chmod +x $HOME/.config/rofi/applets/power/power.sh` command was added to the end of `install/modules/config.sh` to ensure the script is executable automatically during the installation process.

### Testing & Validation

Throughout the development cycle, each change was immediately tested. Rofi menu display, option ordering, icon rendering, and command execution (including logout, suspend, reboot, and shutdown) were verified. Picom shadow behavior was observed on various windows, with particular attention paid to Polybar's corners. Qtile keybinding functionality was confirmed by triggering the power menu and observing its behavior. A full fresh installation of SoulmateOS was performed to validate the end-to-end setup, confirming the automated `chmod +x` and the out-of-the-box functionality of the Rofi power menu.

### Outcomes

A fully functional and aesthetically integrated Rofi power menu has been successfully implemented and integrated into SoulmateOS. This menu provides intuitive graphical access to critical power management functions (shutdown, reboot, suspend, logout) via a dedicated Qtile keybinding (`Mod + p`). The theming aligns with the overall system aesthetic, and the installation process now automatically configures the power menu for immediate use. This significantly enhances the user experience, moving beyond command-line interactions for system power control.

## Reflection

This development cycle, a detailed exploration into the implementation of **Rofi applets** and the intricacies of **Nix-based service management**, proved to be a pivotal learning experience for the SoulmateOS project. The initial ambitious scope for Rofi applets in version 1.0.0, particularly the inclusion of a media control applet, was prudently scaled back. This decision, driven by the practical challenges inherent in a hybrid system environment and the desire to avoid brittle workarounds, reinforced the foundational commitment to "**sane defaults**" and "**long-term cohabitation**." The strategic postponement of the MPD applet, rather than the implementation of a "dirty fix," exemplifies the "**trust through transparency**" pillar, ensuring that future features are built on a robust, declarative foundation provided by Home Manager in v2.0.

Meticulous troubleshooting of **font rendering issues**, though time-consuming, served as a powerful reminder of the importance of low-level technical precision in crafting a polished user experience. This deep dive into character encoding and font glyphs, from `printf` testing to `fc-list` verification, highlighted the often-unseen complexities in achieving visual cohesion. Similarly, the challenges encountered during the **Rofi power menu integration** – ranging from subtle whitespace characters in shell scripts to the precise interpretation of Rofi theming and Qtile's `lazy.spawn` behavior – underscored the absolute necessity of meticulous attention to detail and a profound understanding of each tool's specific parsing rules and environmental dependencies. The iterative debugging process, moving from high-level observation to low-level analysis, reinforced the value of transparency in problem-solving.

A significant outcome of this cycle is the refined conceptual framework for **declarative service management** within the v2.0.0 Nix-based environment. The design of the `soul service` commands, which will bridge imperative user actions with declarative system states, represents a crucial step towards realizing SoulmateOS's meta-distro vision. This approach provides users with comprehensive control over their environment while ensuring **declarative conservation**, a core tenet of reproducibility.

Ultimately, this development cycle, marked by both scope refinement and deep technical dives, directly contributes to SoulmateOS's foundational pillar of "**Learning-by-building**." Each resolved issue deepened the understanding of the system's underlying mechanisms, ensuring that the "long-term cohabitation" with the OS is built on a robust and transparent foundation. The successful automation of the Rofi power menu during a fresh install further solidifies the commitment to a truly cohesive and reproducible desktop habitat, moving SoulmateOS closer to its vision of a reliable, minimal, and user-empowering operating system.
