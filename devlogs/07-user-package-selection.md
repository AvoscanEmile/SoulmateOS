# Devlog Entry 07 — User-Level App Selection

**Date**: 2025-June-16  
**Author**: Emile Avoscan  
**Entry ID**: #07  
**Target Version**: 0.4.0  

### Objective

Define the default user-facing applications for SoulmateOS, ensuring a lightweight, GTK-consistent, privacy-aware, and developer-oriented desktop environment built on AlmaLinux 9 with Qtile. This entry focuses on selecting minimal yet customizable tools that match the use case of system engineers, software developers, and cloud architects.

### 🔧 Selection Criteria

* GTK-based where possible (for consistent theming with `gtk.css`)
* Lightweight and performant
* High degree of customizability (especially through CSS or config files)
* Avoidance of Electron, Snap, and Flatpak packages unless strictly necessary
* Preference for apps actively maintained and installable via `dnf`

### ✔️ Selected Applications

1. **Web Browser: Firefox**

   * Alternatives considered: LibreWolf (lacks sync), GNOME Web (limited extensibility)
   * Final choice: Firefox due to sync, robustness, and developer tooling

2. **Media Player: Celluloid (GTK frontend for mpv)**

   * Alternatives: VLC (heavy but powerful), Haruna (Qt dependencies), MPV raw
   * Final choice: Celluloid for its GTK-CSS themability, keyboard-friendliness, and mpv backend

3. **Music Player: Lollypop**

   * Alternatives: Rhythmbox (older, heavier), Amberol (minimal but too limited)
   * Final choice: Lollypop for GTK3 styling, active maintenance, library management, and ease of use

4. **Markdown Editor: Geany + Plugins**

   * Alternatives: Apostrophe (nice UI, but overkill), MarkText (Electron)
   * Final choice: Geany with Markdown preview plugin — avoids Electron, adds flexibility as text/code editor

5. **Image Viewer: gThumb**

   * Alternatives: Eye of GNOME (limited), Viewnior (too minimal), Ristretto
   * Final choice: gThumb for full-screen support, basic editing, GTK-CSS theming

6. **Archive Manager: Engrampa + Thunar Plugin**

   * Alternatives: File Roller, Xarchiver
   * Final choice: Engrampa for GTK3 consistency + integration with Thunar via plugin

7. **Document Viewer: Evince + Foliate**

   * PDF: Evince (light, GTK-based, robust)
   * EPUB/DJVU: Foliate (GTK3, CSS-themable, no PDF support)
   * Combined tool wasn't available, so both are included

8. **Calendar and PM: Calcurse**

   * Alternatives: Orage (obsolete), GNOME Calendar (too tied to GNOME Shell), Gsimplecal (Too simple)
   * Final choice: Calcurse because it's very vast capabilities across many domains. Sadly its fully TUI, but it's worth the sacrifice of a GUI for functionality. Decided to add a note on the theming phase to have a small system themed calendar that goes well with this one. 
   * Integration with Qtile calendar/task widgets also explored

### 🔧 Configuration Considerations

* GTK-CSS theming applied for visual consistency (fonts, spacing, colors, paddings)
* Thunar extended with archive plugin (requires separate archive manager, e.g., Engrampa)
* Avoided office tools (LibreOffice, etc.) due to target user profile
* Markdown editing accomplished through plugin-based method in Geany

### 😟 Challenges & Observations

* **Electron avoidance** drastically reduced options (especially for markdown and music apps)
* **GTK3 dependency** helped eliminate Qt and GNOME-integrated apps, guiding consistent UI design
* **gThumb** and **Engrampa** look outdated by default but were deemed acceptable due to high stylability
* **Calendar grid spacing in gsimplecal** is not fully customizable, but inner padding and font size suffice
* **Geany markdown preview** requires plugin setup, but provides ideal balance of speed and function

### 💡 Reflections

* Consistency and lightness beat feature overload for a focused developer environment
* GTK-CSS proves critical for building a unified and modern look across otherwise plain apps
* Qtile's lack of GUI is compensated by rich theming, configuration, and widget flexibility
* SoulmateOS remains committed to its core: elegant, modular, engineer-first tooling with no cruft
