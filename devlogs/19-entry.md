# Devlog Entry 19 — Theming geany, adding gtk-based apps to the theming pipeline, and solving compatibility problems at the app level.

**Date**: 2025-07-15

**Author**: Emile Avoscan

**Target Version**: 0.6.0

## Primary Objective

This development cycle focused on achieving comprehensive visual cohesion for GTK-based applications within SoulmateOS. The primary goal was to implement a unified theming strategy for consistent appearance across all application components. This involved creating a modular GTK-CSS pipeline, developing a robust and reproducible configuration method for complex applications like Geany, and integrating a suitable icon theme. A critical secondary goal was to diagnose and resolve a library compatibility crash that occurred when launching DNF-installed applications from a Nix-based launcher.

### Implementation

#### GTK CSS Structure and Dynamic Theming

The foundation of the theming pipeline is a modular GTK CSS structure. The main entry point, `~/.config/gtk-3.0/gtk.css`, was configured to import two separate stylesheets: `colors.css` for color definitions and `fonts.css` for typography. To ensure system-wide consistency, the `change-themes.sh` script was enhanced to extract color variables from the active GTK theme and dynamically generate the `~/.config/gtk-3.0/colors.css` file. This provides `@define-color` variables that our custom CSS can use, ensuring our application chrome styling always matches the user's chosen theme.

#### A Reproducible Configuration Strategy for Geany

A significant part of this cycle was devoted to properly theming Geany, which uses GTK for its window chrome but its own configuration system for the core editor. Initial analysis confirmed that Geany reads `~/.config/geany/geany.conf` on startup and overwrites it on exit, invalidating any naive script that edits the file directly.

A fully declarative model—where a central script would rewrite both `gtk.css` and `geany.conf`—was considered and rejected. While it would enforce perfect consistency, it would break Geany’s own preferences dialog, creating a confusing user experience.

The adopted solution is a **"Coordinated Template"** model. This strategy focuses on providing a perfect out-of-the-box experience without interfering with later user customizations.
1.  A "Golden Master" `geany.conf` template was created by configuring Geany through its GUI. Critically, settings like `editor_font` and `color_scheme` were explicitly set to values that complement the SoulmateOS GTK theme (e.g., "Inconsolata" font and a Nord color scheme file). This ensures the editor's appearance matches the themed application chrome.
2.  A deployment script will be integrated into the user's session startup.
3.  On login, the script checks for the existence of `~/.config/geany/geany.conf`. If the file does not exist, the master template is copied into place. If it exists, the script does nothing, preserving all user modifications.

This approach successfully provides a consistent initial state while respecting user agency.

#### Icon Theme Integration

To complete the aesthetic, the Nordzy icon theme was selected. The setting `icon-theme-name=nordzy` was corrected in `~/.config/gtk-3.0/settings.ini`. After observing poor contrast on the dark background, the `Nordzy-Dark` variant, which provides lighter icons, was installed and set as the default, resolving the issue.

### Challenges & Resolutions

* **Challenge**: Initial `gtk.css` rules for font styling were not being applied to any GTK applications.
    * **Resolution**: The cause was a simple syntax error: a missing semicolon at the end of the `@import` statement in `gtk.css`. Correcting this allowed the stylesheets to be parsed correctly. The font name "Inconsolata" was also verified with `fc-list`.

* **Challenge**: Geany's dropdown menu text was black (invisible on a dark background) at launch, but turned white after a dialog box was opened.
    * **Resolution**: This appeared to be a GTK CSS specificity or application timing issue. A general `*` selector rule in `fonts.css` to set a global foreground color proved to be a reliable workaround, ensuring menu text was visible from the start.

* **Challenge**: Icons in Geany's toolbar appeared as black silhouettes, lacking contrast against the dark UI.
    * **Resolution**: Using the GTK Inspector, it was determined these were full-color SVG/PNG icons from the theme, not symbolic icons that obey the CSS `color` property. Switching to the `Nordzy-Dark` icon theme variant, which is specifically designed for dark UIs, provided properly contrasted icons.

* **Challenge**: Geany (a DNF-installed package) crashed instantly when launched via Rofi (a Nix-installed package) but ran fine from a standard terminal. The error indicated a `GLIBC_2.38` version mismatch required by a `librsvg` library.
    * **Resolution**: This was a classic library conflict in the hybrid Nix/DNF environment. Rofi, running from the Nix environment, was causing the system to load a Nix-provided `librsvg` (for rendering the Nordzy SVG icons) that was linked against a newer `glibc` than was available on the base AlmaLinux system. The robust solution was to fully embrace Nix for user-space applications: Geany was re-installed as a **Nix package** (`pkgs.geany` via Home Manager). This ensures that Geany, Rofi, and all their shared dependencies exist within a single, self-consistent Nix environment, completely eliminating the `glibc` conflict.

### Testing & Validation

* **Visual Inspection:** Geany and Thunar were launched repeatedly to confirm fonts, colors, and icons appeared as expected.
* **GTK Inspector (`GTK_DEBUG=interactive`):** Used extensively to diagnose CSS rule application on specific widgets, which was crucial for fixing the menu text and understanding the icon issue.
* **Terminal Output:** Launching Rofi and Geany from a terminal was essential for capturing the `GLIBC` error message.
* **Reproducibility Test:** The "Coordinated Template" logic was validated with simulated "New User" (no config exists) and "Existing User" (config exists) scenarios to ensure the script behaved correctly.

### Outcomes

This cycle was a major success. A robust and dynamic GTK theming pipeline is now in place. The critical `GLIBC` crash has been resolved, reinforcing the strategy of using Nix to manage user applications for stability. Most importantly, a clear and philosophically sound model (the "Coordinated Template") for configuring hybrid applications like Geany has been established and documented, ensuring a professional and predictable out-of-the-box experience for users.

## Secondary Objective

The final goal was to investigate enforcing a reproducible minimum width for the sidebar pane in Geany, to maintain the predictable dimensions that are a core principle of the SoulmateOS aesthetic.

### Implementation

The investigation was methodical, starting with high-level configuration and moving to low-level environmental factors.
1.  **Configuration Analysis**: Initial attempts focused on `geany.conf`. Research confirmed the modern key is `pane_positions`, not the deprecated `treeview_pos`. The value was manually set (e.g., `pane_positions=250:753`) to establish a baseline.
2.  **State Management**: Geany's state-saving flags (`pref_main_save_wingeom`, `pref_main_load_session`) were toggled to see if they interfered with the `pane_positions` value being read or saved.
3.  **Environmental Isolation**: To rule out interference, Geany was launched in sanitized environments: with plugins disabled (`--no-plugins`), with the default theme (`GTK_THEME=Adwaita`), and without the `nixGL` wrapper.

### Challenges & Resolutions

* **Challenge**: Despite correctly identifying and setting the `pane_positions` key in `geany.conf`, the sidebar width consistently reverted to a default size on every application launch.
    * **Resolution**: None. Exhaustive testing showed that the `pane_positions` value was never updated in the config file on exit, nor was it respected on startup. This behavior persisted across all test cases, including in the sanitized environments. It was concluded that this is not a configuration error but a fundamental behavior of the application. The final pane position appears to be determined at runtime by complex calculations within the GTK3 layout engine, likely influenced by the parent window geometry provided by the Qtile window manager. This runtime calculation takes precedence over any static value in the configuration file.

### Testing & Validation

Validation was simple: after each attempted change, Geany was closed and `geany.conf` was inspected. The `pane_positions` value was never observed to have been written by the application. Relaunching the application always resulted in the same default, non-configurable sidebar width.

### Outcomes

A definitive conclusion was reached: programmatically enforcing a persistent sidebar width in Geany 2.1 via external configuration is not achievable. This investigation, while not yielding the desired feature, is valuable. It defines the practical limits of external theming on third-party GTK3 applications and prevents future wasted effort. It demonstrates that without source code modification, some aspects of application layout are beyond our control. This knowledge allows the project to focus on what can be controlled, contributing to the highly polished and consistent UI that was successfully achieved.

## Reflection

This development cycle was a powerful lesson in the philosophy of system integration, forcing a confrontation with the practical realities of our hybrid Nix/DNF architecture. The `GLIBC` crash was not merely a bug; it was a foundational challenge that validated our core principle of using Nix to ensure a reproducible and stable user space. The resolution—migrating Geany fully into the Nix environment—cements our strategy: the stability gained from a self-consistent dependency graph is paramount, even if it requires a more opinionated approach to application management. This same philosophy of "principled control" is reflected in the "Coordinated Template" model. We are not hijacking the application's configuration, but rather establishing a thoughtful, consistent initial state that respects both the aesthetic integrity of SoulmateOS and the user's ultimate freedom to customize their own tools.

Furthermore, the failed attempt to enforce the sidebar width was just as valuable as the successes. It served as a crucial reminder of the limits of external control and the importance of knowing when to stop fighting an application's intended behavior. True system cohesion isn't about brute-forcing every pixel into compliance; it's about achieving harmony where possible and gracefully accepting the native quirks of individual components. This pragmatic approach prevents us from creating brittle, over-engineered solutions and ensures that SoulmateOS remains robust and maintainable. We are building a curated experience, not a gilded cage, and understanding that distinction is key to the project's long-term success.
