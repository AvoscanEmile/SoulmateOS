# Devlog Entry 11 — Implementing Interactive Volume Popup and GTK Theming Workflow

**Date:** 2025-06-26  
**Author:** Emile Avoscan  
**Target Version:** 0.6.0  

## First Objective
Implement an interactive horizontal volume popup widget in Eww and establish a streamlined GTK theming workflow that supports global and per-app customizations.

### Implementation

#### Popup Initialization

1. Defined `hello-world` widget and `hello-win` window in `eww.yuck` using `defwidget` and `defwindow`.
2. Ensured correct geometry syntax:

   ```lisp
   (defwidget hello-world []
     (label :text "Hello, Eww!"))
   (defwindow hello-win
     :geometry (geometry :width "800px" :height "50px" :anchor "top center")
     (hello-world))
   ```
3. Launched via `eww daemon` and `eww open hello-win` to validate environment.

#### Volume Slider Widget

1. Introduced `volume` variable and `volume-show` flag.
2. Created `volume-slider` widget with a horizontal `scale`:

   ```lisp
   (defvar volume 50)
   (defwidget volume-slider []
     (box :class "volume-container"
       (scale
         :min 0 :max 100
         :value volume
         :orientation "h"
         :onchange "wpctl set-volume @DEFAULT_SINK@ {}%")))
   (defwindow volume
     :visible volume-show
     :geometry (geometry :width "200px" :height "45px" :anchor "top right")
     (volume-slider))
   ```
3. Configured Polybar `click-left = eww open --toggle volume` to trigger popup.

#### GTK Theming Workflow

1. Identified that Adwaita CSS is embedded as a GResource, with `/usr/share/themes/Adwaita/gtk-3.0/gtk.css` acting as a stub.
2. Established user override file at `~/.config/gtk-3.0/gtk.css` containing:

   ```css
   button { border-radius: 4px; }
   .scale highlight { background: #88c0d0; }
   .scale trough     { background: #4c566a; }
   .scale handle     { border: 2px solid #5e81ac; border-radius: 50%; }
   ```
3. Defined theme cascade: built-in GResource → system theme stub → user CSS → per-app CSS or `GTK_THEME` environment.
Here is the revised version of the **Challenges & Resolutions** section with a more detailed and thorough breakdown of the issues encountered and how they were resolved:

### Challenges & Resolutions

- **Challenge**: Syntax errors in Yuck configuration. The initial Eww widget definition failed to launch due to malformed Yuck syntax, particularly involving unbalanced parentheses and incorrect placement of attributes such as `:onchange`.
  - **Resolution:** The structure of the `scale` widget was reformatted with proper indentation and parenthesis alignment. Parameters were explicitly declared in the expected order, and stray closing parentheses were removed. The `geometry` block was also corrected to follow proper key-value syntax using colons.

- **Challenge**: Invisible or non-rendering slider component. Even with a valid volume value, the `scale` widget rendered as blank or invisible. This gave the false impression that the widget was non-functional.
  - **Resolution**: Eww widgets inherit GTK theming rules, and without a corresponding CSS override, the default Adwaita theme renders sliders in a way that may be visually imperceptible, especially with dark backgrounds. CSS rules were added under the user’s `~/.config/gtk-3.0/gtk.css` targeting `.scale highlight`, `.scale trough`, and `.scale handle`. Instead of nesting these rules under `.volume-container`, flat selectors were used to ensure maximum GTK specificity and override priority.

- **Challenge**: Confusion caused by empty `gtk.css` in system theme directory. Investigation into `/usr/share/themes/Adwaita/gtk-3.0/gtk.css` revealed an almost-empty file with a comment indicating that the real styling logic is compiled into a binary GResource.
  - **Resolution:** It was understood that modifying this file is not useful for customization. Instead, user-level GTK CSS was employed to override the visual styles at runtime. This approach avoids the risk of breaking upstream themes while still allowing full control over widget appearance.

- **Challenge**: Unclear GTK theme loading order and override mechanism. There was initial ambiguity regarding where the most effective override point was—system theme, user theme, or app-specific theme.
  - **Resolution:** The GTK theming order was clarified to follow:
    1. Built-in theme via GResource (e.g., Adwaita)
    2. System theme CSS (stub or fallback)
    3. User-level GTK CSS at `~/.config/gtk-3.0/gtk.css`
    4. Per-app CSS or GTK\_THEME environment variable overrides
       Based on this, a workflow was adopted that prioritized the user CSS for system-wide consistency and reserved per-app overrides only for cases where inheritance failed or special styling was required.

### Testing & Validation

* Eww was run with `--no-daemonize` and `eww logs` to catch syntax issues.
* GTK Inspector (`GTK_DEBUG=interactive`) verified CSS selectors on a sample GTK3 application.
* Manual interaction confirmed slider movement updated system volume and UI highlighting.

### Outcomes

* A working horizontal volume popup widget in Eww was delivered.
* A maintainable theming workflow leveraging user CSS for global tweaks and per-app exceptions was defined.

## Reflection

The passive focus-loss mechanism proved far more reliable than CSS-based click tracking, underscoring the value of leveraging built-in event hooks over styling hacks. The extra complexity initially introduced by a backdrop was removed, reducing the configuration surface and improving maintainability. The hybrid AI approach—employing Perplexity Pro for niche research and ChatGPT for synthesis—was recognized as a scalable pattern for future deep-dive tasks, balancing context capacity, citation fidelity, and cost efficiency.

## Second Objective
To implement a responsive and minimal volume control interface using Eww and Polybar, enabling toggled visibility from Polybar, seamless real-time audio adjustment through `wpctl`, and automatic closure via event-driven detection without reliance on additional CSS backdrops or scripts.

### Implementation

#### Eww Configuration

1. A `volume-show` boolean variable was declared to control window visibility.
2. The existing `volume` window was modified to include an `:onblur` handler:

   ```clojure
   :onblur "eww update volume-show=false; eww close volume"
   ```
3. Any additional backdrop window was removed to simplify CSS interactions and avoid specificity conflicts.

#### Polybar Integration

1. The Polybar `volume` module’s `click-left` action was set to:

   ```dosini
   click-left = eww open volume
   ```
2. No intermediary scripts were required, reducing maintenance overhead.

#### Volume Slider Mechanics

1. The slider widget was retained with `:min 0`, `:max 101`, and `:onchange` invoking:

   ```clojure
   "wpctl set-volume @DEFAULT_SINK@ {}%; eww update volume={}"
   ```
2. The integer ceiling issue was addressed by adding one extra step (101) and clamping logic.

### Challenges & Resolutions

- **Challenge***: GTK CSS specificity caused the backdrop window to inherit unwanted styling from the .horizontal class used by the volume slider. This resulted in a visible, unintended background color despite explicit rules attempting to override it.

  - **Resolution**: Multiple GTK CSS selectors were trialed to isolate the backdrop, including .backdrop.background and backdrop.horizontal. These failed due to lower specificity and the absence of !important support in GTK theming. Ultimately, the backdrop mechanism was abandoned. Instead, the :onblur event built into Eww was used to dismiss the volume slider on focus loss, completely eliminating the need for a conflicting backdrop window.

- **Challenge**: The volume slider was capping out at 99% due to wpctl parsing behavior, which interprets values strictly between 0 and 1 when given as percentages. This resulted in failure to consistently reach or represent full system volume.

  - Resolution: The slider's :max value was increased from 100 to 101 to compensate for rounding discrepancies. In parallel, the :onchange handler was modified to clamp the upper bound at 100% explicitly within the eww update and wpctl commands. This dual-level safeguard ensured precise volume control and eliminated user confusion.

- **Challenge**: Selection between AI tools for research presented a tradeoff between deep citation-rich exploration (Perplexity AI) and broader creative/contextual synthesis (ChatGPT). Additionally, price point differentials introduced budget constraints.

  - **Resolution**: A strategic dual-tool workflow was formalized. Perplexity Pro was chosen for its robust search aggregation and citation fidelity, justified by an analysis showing its 300 daily pro searches vastly exceeded practical daily consumption. ChatGPT Plus was retained for large-context, creative, and synthesis-heavy tasks. This division maximized return on investment across both tools, with export-import flows enabling handoff between systems when necessary.

### Testing & Validation

1. The Eww daemon was restarted, and `eww open volume` was issued to confirm window appearance.
2. Clicking outside the window triggered the `:onblur` handler, successfully hiding the slider.
3. Volume adjustments were validated via `wpctl get-volume` and `pactl list sinks`, confirming accurate system-level control.
4. Polybar clicks were exercised to ensure idempotent open/close behavior without script errors.

### Outcomes

* A minimal, robust volume control widget was delivered with no backdrop, preventing CSS inheritance issues.
* User interactions were simplified: a single Polybar click opens the slider; any external click closes it.
* System volume control was verified to operate over the full 0–100% range.
* A documented hybrid AI-research workflow was provided, improving deep-documentation retrieval and synthesis.

## Reflection

Mastering GTK's CSS cascade proved essential for consistent runtime theming. By centralizing overrides at the user level and isolating exceptions per-app, a balance between cohesion and flexibility was achieved. This approach aligns with the project’s goals of modularity, automation, and aesthetic consistency.

## Conclusion

The end-to-end integration of Eww and Polybar has resulted in a streamlined, maintainable volume control mechanism that relies solely on native event-driven hooks rather than fragile CSS workarounds. Focus-loss detection was leveraged to dismiss the slider automatically, eliminating the need for auxiliary backdrop windows and complex theming overrides. The final widget achieved full 0–100% volume control, idempotent Polybar interactions, and minimal configuration overhead.
