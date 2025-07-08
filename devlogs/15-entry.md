# Devlog Entry 15 — Refining Window Management and Visual Aesthetics in a Tiling Environment. Creating a theming pipeline for the project with a centralized script.

**Date**: 2025-07-02

**Author**: Emile Avoscan

**Target Version**: 0.6.0

## First Objective

The primary goal of this development cycle was to transform a standard Qtile configuration into a highly personalized and aesthetically cohesive desktop environment. This involved a deep dive into window management behaviors, visual effects orchestration via the Picom compositor, and the seamless integration of external UI components like Polybar and Eww. The focus was on achieving a professional look and feel while ensuring the system's functionality was precisely tailored to a specific, desired workflow.

### Implementation

#### Window Layout and Spacing
A consistent 7-pixel gap between windows was desired. The initial implementation using the `margin` parameter in `layout.Columns` was found to be unsuitable due to cumulative margins creating a double-width gap between adjacent windows. The `layout.Bsp` was tested as an alternative but exhibited similar behavior. The final, successful implementation was achieved by switching to `layout.MonadTall`. This layout's margin handling proved to be non-cumulative, applying a single, consistent 7-pixel gap between its window panes, which resolved the issue without requiring complex screen-level gap configurations.

#### Focus Behavior Modification
The default hover-to-focus behavior was altered to a more traditional click-to-focus model. This was implemented by modifying two boolean flags in `qtile/config.py`: `follow_mouse_focus` was set to `False`, and `bring_front_click` was set to `True`. This change successfully decoupled window focus from mouse movement, requiring an explicit click to activate a window.

#### Visual Effects and Compositing
A sophisticated visual hierarchy was established using the Picom compositor. To visually de-emphasize non-active windows, a rule for semi-transparency was implemented. The `inactive-opacity` was set to `0.85`, and crucially, `inactive-opacity-override` was set to `false` to ensure the rule was respected. Specific `opacity-rule` entries were added to the `picom.conf` file to assign fixed opacities to applications like Rofi (`97%`) and Polybar (`93%`), preventing them from being affected by the inactive-opacity rule. Fade animation speeds were also increased for a more responsive feel by adjusting `fade-in-step` and `fade-out-step` values.

#### Fullscreen Mode Enhancement
A distraction-free fullscreen mode was implemented to address two issues: Polybar remaining on top of fullscreen windows and inactive opacity rules still applying. This was solved with a dual-pronged approach. First, a custom Python function, `toggle_fullscreen_and_polybar`, was written and bound to the `mod + f` keybinding in `qtile/config.py`. This function checks the window's fullscreen state and accordingly executes shell commands to either kill the Polybar processes (on entering fullscreen) or restart them via the `autostart.sh` script (on exiting). Second, a rule `"100:fullscreen"` was added to `picom.conf` to ensure any fullscreen window is rendered as fully opaque.

### Challenges & Resolutions

* **Challenge**: The `margin` parameter in initial layout choices (`Columns`, `Bsp`) resulted in a 14px gap between windows instead of the desired 7px.
    * **Resolution**: The issue was resolved by adopting the `layout.MonadTall`, whose margin implementation is non-cumulative and applies only to the space between its managed panes.

* **Challenge**: An Eww widget used as a clickable overlay to close other widgets remained opaque, inheriting the default GTK theme background.
    * **Solution**: Initial attempts to fix this with CSS and Eww's `:opaque` property failed. The issue was definitively resolved by using `xprop` to find the widget's unique `WM_NAME` ("Eww - menu-closer") and adding a rule `"0:name = 'Eww - menu-closer'"` to `picom.conf` to force its opacity to 0.

* **Challenge**: With `override-redirect = true` set on Polybar to allow for precise gap control, the bar would render on top of fullscreen applications.
    * **Solution**: A "smart toggle" function was implemented in Qtile's configuration. This function, triggered by the fullscreen key, programmatically kills the Polybar processes when entering fullscreen and restarts them when exiting, effectively hiding and showing the bar in sync with the fullscreen state.

### Testing & Validation
All changes were validated through direct visual inspection and functional testing after each configuration modification.
* **Gap Consistency**: Multiple terminal windows were opened and resized to confirm that all inner and outer gaps were a consistent 7 pixels with the final `MonadTall` layout.
* **Fullscreen Behavior**: The `mod + f` keybinding was repeatedly tested on various applications. It was confirmed that Polybar was successfully killed upon entering fullscreen and restarted upon exiting. It was also verified that the fullscreen window became fully opaque, as per the Picom rule.
* **Widget Transparency**: The Eww closer widget was tested and confirmed to be fully transparent and functional after the `picom` rule was applied.

### Outcomes
The development cycle resulted in a highly refined and personalized desktop environment that successfully meets all specified aesthetic and functional requirements. A consistent visual language was established across all system components. The final configuration is robust, with programmatic workarounds implemented to overcome the inherent limitations of interactions between independent system components.

## Reflection
This iterative process highlights a core principle of modular desktop environments: immense power and customizability are derived from the interplay of specialized, independent tools. However, this same modularity creates complex interdependencies where the behavior of one component (e.g., a Qtile layout) is implicitly affected by another (e.g., Polybar's EWMH hints).

The most significant lesson learned was the importance of identifying the "single source of truth" for a given behavior. The persistent issue with window gaps was only resolved when it was understood which component—the layout or the screen—should be responsible for which type of gap. Similarly, forcing transparency on the Eww widget via the compositor (`picom`) proved more effective than application-level (`eww`) styling when the latter failed.

Ultimately, the journey from a default configuration to this polished result was a lesson in systematic debugging and creative problem-solving. The refusal to accept a functional compromise (like the fullscreen issue) led to a deeper understanding of the system's architecture and resulted in a more elegant and powerful solution. The final desktop is not just a collection of configured tools, but a single, cohesive system built with intention.

## Final Objective

The primary goal of this development cycle was to advance beyond static configurations and implement a dynamic, system-wide theming pipeline. The objective was to create a mechanism whereby core visual components—for the moment only Rofi and Polybar—could automatically derive their color schemes from the active GTK theme. This work is central to achieving the "Unified Theming" and "aesthetically harmonized" environment specified as foundational goals for the SoulmateOS project, ensuring a truly cohesive user experience.

### Implementation

The implementation was approached in a modular, sequential manner, beginning with component-level configuration and culminating in an integrated, automated system.

#### Rofi Theme Curation and Configuration

Initial work began with the Rofi launcher. A decision was made to curate a small, representative selection of theme structures (layouts) rather than installing a large, un-curated collection. This aligns with the project's minimalist philosophy. The selected `.rasi` theme files were placed in the `~/.local/share/rofi/themes/` directory, the standard location searched by the `rofi-theme-selector` utility. This step ensures that a manageable set of high-quality theme layouts are available to the user without unnecessary bloat.

#### Picom Compositor Tuning for Visual Effects

Significant effort was invested in configuring the Picom compositor to achieve a modern "frosted glass" effect, which relies on a combination of transparency and background blur. The `picom.conf` file was modified to enable a `dual_kawase` blur method and to activate the `blur-background` setting. Crucially, Rofi's `opacity-rule` within Picom was explicitly set to `100` (`"100:class_g = 'Rofi'"`). This forces Picom to cede control of transparency to the Rofi application itself, allowing Rofi's internal semi-transparent colors to render correctly over a blurred background, rather than having the entire window's opacity manipulated by the compositor.

#### Architectural Design of the Theming Pipeline

A key architectural decision was made to favor a modular, multi-script approach over a single monolithic script. This enhances maintainability and aligns with the project's existing modular structure. The pipeline was designed with two core components:
1.  A script (`change-themes.sh`) responsible for parsing the active GTK theme and updating centralized color variable files.
2.  A script (`change-config.sh`) that consumes these variables to generate the final `polybar/config.ini`.

#### Color Extraction Script Implementation

A robust shell script was developed to extract color definitions from the active GTK theme's `gtk.css` file. The core of this script is an `extract_color` function that utilizes `awk` for reliable parsing of the `@define-color name value;` format. To enhance resilience against variations in theme authorship, this function was designed to accept three arguments: a primary variable name and two fallbacks. It iterates through these options and returns the first valid color it finds, ensuring the script can gracefully handle themes with slightly different naming conventions. If these fallbacks prove to not be enough, it's been considered to extend the fallbacks to three variables, but since the naming conventions in gtk themes is so prevalent, this is highly unlikely. 

#### Polybar and Rofi Theme Integration

The pipeline was configured to update two separate variable files: `colors.rasi` for Rofi and `polybar-theme.ini` for Polybar. For Polybar, the `sed` command was employed to perform an in-place replacement of color values within `polybar-theme.ini`, a more efficient and less redundant solution than using a heredoc block for simple value changes. Rofi's integration is simpler, using a direct `@import "colors.rasi"` statement within its main theme file.

#### Automation via `autostart.sh`

The final step was the integration of this pipeline into the system's startup sequence. The `change-themes.sh` and `change-config.sh` scripts are called sequentially within `~/.config/qtile/autostart.sh`. This ensures that every time a user logs in, the color schemes for all components are automatically synchronized with the current GTK theme, creating a fully automated and cohesive visual experience.

### Challenges & Resolutions

* **Challenge:** Custom Rofi themes were not appearing in `rofi-theme-selector`.
    * **Solution:** The issue was traced to an incorrect file location. The `.rasi` files had been placed in `~/.config/rofi/`, whereas `rofi-theme-selector` searches `~/.local/share/rofi/themes/`. The files were moved to the correct directory, resolving the issue.

* **Challenge:** Fullscreen Rofi themes were forced to 100% opacity, ignoring other rules.
    * **Solution:** Picom's rule processing order was identified as the cause. The general `"100:fullscreen"` rule was taking precedence. A more specific rule, `"100:class_g = 'Rofi' && fullscreen"`, was added *before* the general fullscreen rule to ensure fullscreen Rofi windows were handled by the correct, intended rule.

* **Challenge:** The initial color extraction script failed to parse any colors.
    * **Solution:** The script's `sed` command was using an incorrect pattern (expecting a colon after the variable name). The function was rewritten using `awk` to correctly parse the column-based `@define-color` format, which proved more robust.

* **Challenge:** The script failed when a GTK theme did not contain an expected variable name (e.g., `@view_bg_color`).
    * **Solution:** The `extract_color` function was refactored to accept multiple arguments, creating a fallback system. If the primary variable name is not found, the script automatically attempts to find secondary and tertiary alternatives, making it resilient to variations in theme conventions.

* **Challenge:** The script was not successfully updating the `polybar-theme.ini` file.
    * **Solution:** The `sed` command was found to be looking for a pattern with spaces around the equals sign (`BACKGROUND = ...`), while the target file had no spaces (`BACKGROUND=...`). The `sed` pattern was corrected to `^BACKGROUND=.*` to match the file's format precisely.

### Testing & Validation

The implemented system was validated through a series of tests. First, `rofi-theme-selector` was run to confirm that the curated themes were correctly detected. Second, after executing the full script pipeline, Rofi and Polybar were launched to visually confirm that their colors matched the active GTK theme. Finally, the active GTK theme was changed in `settings.ini`, and the scripts were re-run. A subsequent visual inspection confirmed that both Rofi and Polybar had automatically adopted the new color scheme, validating the end-to-end functionality of the dynamic pipeline.

### Outcomes

* A robust, modular, and fully automated theming pipeline was successfully implemented, achieving a primary goal of the `v0.6.0` milestone.
* A high degree of visual cohesion between GTK applications, Rofi, and Polybar is now a core feature of the system.
* The system's configuration scripts were made more resilient and adaptable through the implementation of fallback logic.

## Reflection

This development cycle was a profound exercise in systems architecture, moving beyond static configuration to create a truly dynamic and integrated environment. The process of engineering this pipeline was a direct application of the project's core philosophies: "learning-by-building" and achieving "Trust through transparency." By deconstructing how each component handles theming and scripting the connections between them, a deep understanding of the system's inner workings was achieved.

The outcome demonstrates that the polish and cohesion of a full-blown desktop environment can be realized through the intelligent orchestration of lightweight, independent components. This reinforces the minimalist-but-powerful ethos of SoulmateOS.

On a personal level, this period of intense, systems-level thinking has highlighted a fascinating cognitive phenomenon: the principles of a project can begin to shape the thought patterns of its creator. The drive for efficiency, logical consistency, and transparency required by the work began to manifest in communication and perception, revealing how deeply one can internalize the philosophy of a system they are building. The final, elegant pipeline is so well-integrated that its complexity becomes invisible—a testament to the idea that the best design is the one that feels effortless.
