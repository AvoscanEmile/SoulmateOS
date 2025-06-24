# Devlog 10 — Polybar Installation and Configuration

**Date**: 2025-06-24  
**Author**: Emile Avoscan  
**Target Version**: 0.6.0

## First Objective

The aim of this phase was to install and configure Polybar as a suite of independent, floating widgets within the Qtile session. Each widget needed to present a polished visual style—rounded corners, adjustable transparency, coherent typography—and support direct user interaction to launch Eww popups.

### Modular Architecture

Instead of a single, contiguous bar, the configuration was partitioned into discrete bar definitions. Within one consolidated `config.ini`, each `[bar/<name>]` section encapsulates exactly one module (e.g., datetime, volume, workspaces). This segmentation allows per-widget customization of dimensions, positioning, and behavior without side effects on unrelated elements.

### Interactivity

Mouse-driven actions were enabled globally (`enable-click = true`) and selectively (`enable-scroll` where needed). For instance, the datetime widget now interprets a left-click event to invoke its Eww popup. This direct mapping replaces generic scripts and embeds contextual functionality into each widget’s configuration.

### Typography and Alignment

Custom font selection and pixel-perfect alignment were addressed by installing Google Fonts into the user font cache and declaring them in Polybar with explicit style, size, and vertical offset. A declaration such as:

```ini
font-0 = JetBrainsMono Nerd Font:style=Bold:size=11;3
```

ensures bold weight and a precise downward shift. Iterative testing across bar heights produced consistent vertical centering of glyphs within their widget boundaries.

### Compositor Integration and Visual Effects

Picom was chosen as the compositor with the GLX backend, rounded-corner support, and selective blur rules. Polybar bars specify:

```ini
background = #00000000
radius     = 8.0
override-redirect = true
```

Launching Picom before Polybar guarantees that ARGB transparency and curved edges render correctly, eliminating previous artifacts (e.g., black box remnants). Although the implementation of picom is not a concern of this phase of the project, this phase is made with picom in mind already. 

### Layout and Centering

True centering from screen midpoints is not natively supported, so each widget’s horizontal position is calculated either by percentage offsets:

```ini
width    = 30%
offset-x = 35%
```

or by a wrapper script that computes pixel-based offsets via `xrandr`. Vertical placement uses `offset-y` to introduce consistent margins from the screen edge.

### Color Strategy

A semi-transparent dark grey background (`#1e1e1ecc`) paired with white text (`#ffffff`) achieves maximum legibility under blur and across diverse wallpapers. This palette balances subdued aesthetics with clear visual hierarchy, preventing glare while maintaining readability.

## Reflection

This initiative underscores Polybar’s adaptability when orchestrated through external tools. By decomposing the traditional panel into autonomous widgets, we will achieve a high degree of visual coherence and interactivity while preserving system simplicity. The success of this approach will reinforce the SoulmateOS principle: modular, user-driven design through minimal internal complexity.

## Second Objective

Unify and streamline the system-wide theming for Polybar and Qtile by centralizing theme variables, dynamically generating configuration, implementing a custom weather module without API keys, and resolving multi-bar layout issues.

### Background

Thematic consistency across all desktop components—bars, widgets, and applications—was required to reduce duplication and simplify maintenance. Polybar does not natively support variable imports or multi-instance strut management, and a reliable weather display without forcing users to manage API keys was needed.

### Implementation

#### Centralized Theme Variables

A declarative `system-theme.ini` file was introduced to hold colors, fonts, dimensions, and other variables:

```ini
BACKGROUND=#212121
FOREGROUND=#ffffff
FONT=Roboto:style=bold:size=11;4
BAR_WIDTH=9%
...etc...
```

A `theming.sh` script defines an `import_theme()` function, sources the INI, exports all key–value pairs, and writes the `~/.config/polybar/config.ini` via a heredoc:

```bash
import_theme() { ... }
import_theme ~/.config/qtile/system-theme.ini || exit 1
cat > ~/.config/polybar/config.ini << EOF
[bar/datetime]
background = $BACKGROUND
font-0 = "$FONT"
...EOF
killall -q polybar
polybar datetime &
```

`autostart.sh` was simplified to a single call to `theming.sh`, ensuring fresh config generation on each session start.

#### Weather Module via `wttr.in`

To avoid API key management, the weather module uses `curl wttr.in` with format placeholders:

```bash
weather=$(curl -s 'wttr.in/?format=%c%20%t' | sed -E 's/ ([+])?([0-9])/\2/')
echo "$weather"
```

This reliably outputs `☀️28°C` (icon + temperature) by stripping the leading plus and the space via `sed`.

#### Multi-Bar Strut Management

Multiple Polybar instances (e.g., `datetime`, `weather`) initially caused Qtile to reserve cumulative strut space. The solution was to set `override-redirect = true` on all bars except the primary one. This allowed floating bars to render without additional reserved padding.

### Challenges & Resolutions

* **Variable Importing**: Polybar lacks include support. Solved by sourcing theme variables in a shell script and templating via heredoc.
* **Weather Icons Without API Keys**: Avoided user burden by leveraging `wttr.in`. Handled unexpected `+` signs via inline `sed`.
* **Stacked Strut Reservations**: Qtile misinterpreted multiple bars. Mitigated by using `override-redirect` selectively.

### Testing & Validation

* **Theme Generation**: Edited `system-theme.ini`, restarted Qtile session, verified Polybar colors, fonts, and dimensions updated immediately.
* **Weather Output**: Ran the script in terminal (`bash weather.sh`), confirmed output variations for positive and negative temperatures matched expectations.
* **Strut Behavior**: Launched 3 bars, inspected `_NET_WORKAREA` via `xprop -root`, confirmed only one bar’s height was reserved.

### Outcomes

* A single point of truth (`system-theme.ini`) for all theming variables.
* Automated Polybar config generation and launch via `theming.sh`.
* API‐free, icon‑rich weather module integrated into Polybar.
* Multiple Polybar instances coexisting without unusable screen gaps.

## Reflection

Centralizing theming logic in a shell‐driven templating approach provided clarity and scalability, avoiding manual duplication across configs. Leveraging `wttr.in` simplified weather integration but introduced reliance on network service availability. Future work will balance ease of use with offline capabilities and deeper integration across system components.

## Third Objective

We set out to build and refine a suite of minimal, theme‑driven Polybar modules tightly integrated with Qtile, focusing on a groups indicator, weather display, and volume status, all centered and dynamically updated.

### Background

Our configuration aims for a clean, modular status bar ecosystem on Qtile that leverages a centralized theming system. Prior work established a `system-theme.ini` and a `change-config.sh` generator, and we already had a Polybar weather module. We needed to add a workspace (group) indicator and a volume module, plus solve precise centering and icon rendering.

### Implementation

#### Groups Indicator

   * Designed a Polybar custom script module called `groups` that displays seven circles (`○`) and fills the active one (`●`).
   * Queried Qtile via its IPC: `qtile cmd-obj -o root -f get_groups` and used `jq` to select the group with `"screen": 0`.
   * Replaced Bash array loops (not POSIX in `/bin/sh`) with a C‑style `for (( i=1; i<=7; i++ ))` loop for bulletproof iteration under Polybar’s shell wrapper.
   * Tuned visual alignment with `label-margin-left` to nudge the entire row by a few pixels.

#### Bar Centering

   * Reviewed Polybar’s lack of CSS‐style centering; opted for fixed bar width and runtime offset calculation.
   * Provided a one‑liner using `xrandr` and arithmetic:

     ```bash
     offset_x=$(( $(xrandr | grep ' connected' | head -n1 | grep -oP '\d+x\d+' | cut -d'x' -f1) / 2 - BAR_WIDTH / 2 ))
     ```
   * Offered manual README instructions for users to compute and set `offset-x` by formula for simplicity and reliability.

#### Volume Module

   * Detected available audio CLI (`wpctl` on AlmaLinux).
   * Wrote `volume.sh` that uses `wpctl get-volume` and `get-mute`, computes percentage and chooses the correct Font Awesome codepoint via `$'\uf026'`, `$'\uf027'`, `$'\uf028'`.
   * Diagnosed missing icons in Polybar by confirming terminal rendering, then fixed Polybar font fallback: added `font-1 = "Font Awesome 6 Free:style=Solid"` and wrapped icons in `%%{T1}%s%%{T-}` markup.
   * Addressed the absence of a two‐wave icon by mapping mid‐range volumes to the `volume-down` glyph.

#### Weather Module Simplification

   * Inlined the `curl | sed` pipeline directly in the Polybar `exec` field to remove an external script.

### Challenges & Resolutions

* **Qtile IPC command syntax changes**: Navigated version differences, discovered the correct `cmd-obj -o root -f get_groups` interface in Qtile 0.32.0.
* **POSIX shell in Polybar**: Arrays not supported, switched to C‑style loops.
* **Font glyph availability**: Installed Font Awesome 6 Solid manually via GitHub API script in `~/.local/share/fonts`, refreshed `fc-cache`, then validated with `printf` and `fc-list`.
* **Optical centering**: Solved label misalignment with Polybar `label-margin-left` and monospaced/fallback font strategies.

### Testing & Validation

* **Groups script**: Verified all seven circles printed for each group state; switched Qtile workspaces and observed immediate updates.
* **Offset calculations**: Tested one‑liners in terminal; confirmed via `xwininfo` that Polybar window X‑position matched computed `offset-x`.
* **Volume icons**: Ran `printf '\uf026 \uf027 \uf028'` in Kitty; confirmed correct glyphs; then relaunch Polybar and ensured icons rendered.
* **Weather**: Observed correct temperature output every 10 min by adjusting `interval` and checking `wttr.in` output consistency.

### Outcomes

* **`groups` bar**: A dedicated Polybar instance showing dynamically updated workspace circles, perfectly centered with scripted offset.
* **Volume module**: Compact icon+percentage element, responsive to actual volume state, with correct icon font rendering.
* **Simplified weather**: Clean inlined script command, no extraneous files.
* **Central theming**: All visual parameters continue to stem from the central `variables.ini` and `change-config.sh` (previously `theming.sh`) pipeline.

## Reflection

This session reinforced that **simplicity and explicitness** often trump overcomplicated automation, especially in shell‑based setups where environment variability is high. By centralizing theme variables and using small, well‑tested script snippets, we achieved both reliability and clarity. Future automation should carefully balance elegance with maintainability to avoid brittle configurations.

## Fourth Objective

In this phase, the goal was to finalize the Polybar network module by converting its throughput display from kilobytes per second to megabits per second (Mbps) for consistency with external speed tests, and to refine the installation process including font and service deployment.

### Background

SoulmateOS’s primary bar modules (groups, weather, volume, network) were architected with modular shell scripts and centralized theming. The network module initially reported speeds in KB/s using the binary (MiB) convention. However, when compared to Speedtest by Ookla (which reports in decimal megabits per second), the values diverged by an order of magnitude, prompting a unit reconciliation and script update. Additionally, bundling and symlinking Font Awesome icons and custom notification services into the installation script was required to ensure a seamless, one‑step setup on fresh clones.

### Implementation

The implementation unfolded in two main threads:

#### A. Throughput Unit Conversion

* **Design Decision**: Align the network module’s output with industry standard **megabits per second**, using decimal scaling (1 Mbps = 10⁶ bits/sec) instead of binary megabytes.
* **Script Changes**:

  * Replaced the KB-based calculations:

    ```bash
    rx_speed=$(awk "BEGIN {printf \"%.1f\", ($rx_diff / 0.3) / 1024 }")
    ```

  with a bits-based formula:

  ```bash
  rx_mbps=$(awk "BEGIN {printf \"%.1f\", ($rx_diff / 0.3) * 8 / 1000000 }")
  ```

  * Updated the `echo` statement to:

    ```bash
    echo "$ethernet_icon $up_icon ${tx_mbps}Mb/s | $down_icon ${rx_mbps}Mb/s"
    ```
* **Rationale**: Multiplying by 8 converts bytes to bits; dividing by 1,000,000 converts bits/sec to Mbps, matching Ookla’s units.

#### B. Installation Script Enhancements

* **Font Bundling**: Added `Font Awesome 6 Free‑Solid‑900.otf` under `fonts/` with its **SIL Open Font License**.
* **Symlink Deployment**:

  ```bash
  ln -sf "$SRC_DIR/fonts/Font Awesome 6 Free-Solid-900.otf" "$HOME/.local/share/fonts/"
  fc-cache -f "$HOME/.local/share/fonts/"
  ```
* **Notification Services**: Deployed custom systemd‑user units (`notify-daemon.service`) via symlinks in `~/.config/systemd/user`, reloaded user daemons, and enabled them immediately:

  ```bash
  ln -sf "$REPO_DIR/systemd/user/notify-daemon.service" "$HOME/.config/systemd/user/"
  systemctl --user daemon-reload
  systemctl --user enable --now notify-daemon.service
  ```

### Challenges & Resolutions

During speed alignment, initial confusion arose from binary vs decimal prefixes and bits vs bytes. Confirming that `/sys/class/net/.../statistics` reports raw bytes and reconciling to bits with a precise formula resolved the discrepancy. For font and service provisioning, ensuring **idempotent symlink logic** and **absolute paths** prevented errors on repeated installs.

### Testing & Validation

* **Manual Validation**: Ran the updated network script in isolation, verifying output like ` ▲ 250.3Mb/s | ▼ 248.7Mb/s` aligned with concurrent Ookla tests.
* **Font Rendering**: After symlink and `fc-cache`, confirmed `echo -e "\uf6ff"` rendered the Ethernet icon in terminal and Polybar.
* **Notification Daemon**: Tested `notify-send 'Test' 'Notifications working'` to validate `notify-daemon.service` deployment.

### Outcomes

* The network module now reports speeds in **Megabytes/s**, directly comparable to external benchmarks.
* The installation script bundles and symlinks required fonts and services automatically, ensuring a **zero‑effort setup** on fresh clones.

## Reflection

Standardizing units to industry conventions not only improves user comprehension but also underscores the project’s commitment to accuracy. Embedding fonts and services into the installer enhances reproducibility and user experience. This phase exemplifies the balance between technical precision and seamless UX that SoulmateOS strives to achieve.

## Final Objective

To improve the rendering of weather icons in Polybar using emoji fonts while preserving typographic integrity and visual consistency. The broader goal was to resolve rendering quirks in mixed-font environments, ensure cross-distro compatibility of the UI setup, and deepen the underlying infrastructure supporting responsive and aesthetic desktop environments under the SoulmateOS project.

### Background

Polybar, used in SoulmateOS as a workspace and status bar, was failing to render weather icons consistently. The root issue was traced to emoji fonts conflicting with text fonts that also included overlapping glyphs. This resulted in inconsistent spacing, fallback behavior, and visual clutter. The project is being developed from a minimal AlmaLinux base, gradually layering Nix and DNF in tandem to produce a highly customized, responsive, and reproducible desktop experience. As such, even seemingly minor UI inconsistencies were considered significant due to the system's design philosophy: deliberate, aesthetic, and modular.

### Implementation

The session began with identifying that the weather icons were inconsistently rendered due to fallback mechanics in font handling. The initial script was:

```bash
printf '%%{T0}%s %%{T1}%s\n' "$icon" "$temp"
```

But this defaulted to using the base font (e.g., Roboto), which included some weather-like glyphs that prevented the emoji font (e.g., Noto Color Emoji) from being used as a fallback. The solution included the following decisions:

* **Font Replacement**: Roboto was replaced with Inconsolata, which does *not* include emoji or weather-like glyphs.
* **Font Load Order**: Emoji font (Noto Color Emoji) was loaded first using `T0`, then text font (Inconsolata) with `T1`, forcing Polybar to defer to the emoji font where applicable.
* **Verification**: A test suite of cities was temporarily used to cycle through a range of weather glyphs and verify rendering behavior.
* **Emoji Width Issue**: A known issue was discovered where emoji spacing was not uniform. This was noted but deferred for later refinement.

Font installation was simplified by extracting only the variable TTF file from the Inconsolata package:

```bash
cp Inconsolata-VF.ttf ~/.local/share/fonts/
fc-cache -fv
```

### Challenges & Resolutions

* **Fallback Conflicts**: Roboto had partial emoji glyphs, causing fallback logic to misfire. Replacing it resolved the conflict.
* **Emoji Width Inconsistency**: Some weather icons used different horizontal spaces. The idea of implementing conditional spacing logic in the script was explored, but deferred.
* **Polybar Rendering Quirks**: Polybar's font fallback and glyph spacing system lacks granularity. Partial control was achieved, but deeper fixes may require upstream changes or an emoji-aware monospaced font, which are rare.

### Testing & Validation

* Used `polybar --reload weather -l trace` to trace rendering behavior and verify font loading sequence.
* Verified emoji rendering consistency by simulating various cities with different weather conditions.
* Cross-checked emoji spacing visually in multiple weather states.
* Validated success by visual uniformity, correct glyphs, and absence of glyph overlap or misalignment.

### Outcomes

* Weather icons render properly using Noto Color Emoji.
* Typographic consistency preserved with Inconsolata as primary text font.
* Polybar outputs dynamically updated and clean in all test states.
* User interface confirmed as responsive and aesthetically balanced at widths as narrow as 800px.

## Reflection

What started as a minor visual fix cascaded into a realization about how fragile and opinionated font rendering remains in modern Linux UIs. The difficulty of managing consistent fallback chains, combined with the lack of proper monospace emoji fonts, revealed an often-overlooked gap in graphical fidelity for Linux power users. However, these constraints also highlighted the uniqueness of the SoulmateOS project: a highly modular, deeply aesthetic Linux interface that blends the flexibility of a window manager with the usability of a desktop environment. This devlog marks the point where SoulmateOS crossed a subtle but powerful milestone—delivering not just a working UI, but a *designed* one.

The broader architectural direction is maturing into what could be called a "metadistro": a modular overlay that turns *any* base distribution into a personalized, highly-controlled desktop environment. With the groundwork laid for responsive design, font clarity, and script orchestration, the system is now poised for broader deployment and community testing.

## Conclusion
Over the course of this devlog, we’ve systematically transformed Polybar from a monolithic status line into a suite of modular, theme-driven widgets tightly integrated with Qtile. Through iterative objectives—installation & basic styling, centralized theming, new modules (groups, weather, volume), network throughput standardization, and emoji-font refinements—we have realized SoulmateOS’s commitment to modularity, aesthetic consistency, and user-centric simplicity. Each phase built upon the last, reinforcing a workflow where shell-driven templating, minimal external dependencies, and clear design principles coalesce into a reproducible, maintainable desktop experience.
