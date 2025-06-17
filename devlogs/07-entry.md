# **Devlog Entry 07 — User-Level Application Selection**

**Date:** 2025-06-16  
**Author:** Emile Avoscan  
**Target Version:** 0.4.0  

## Objective

The goal of this development phase was to define a curated set of default applications for SoulmateOS. This selection prioritizes a lightweight, GTK-consistent environment tailored to the needs of system engineers, software developers, and cloud architects. Built upon AlmaLinux 9 and Qtile, the chosen applications were required to reflect the ethos of simplicity, privacy, and power-user focus.

## Application Selection Strategy

To achieve coherence and performance, applications were selected based on several key principles:

* Preference for GTK-based tools to enable uniform styling via `gtk.css`
* Avoidance of Electron, Snap, and Flatpak in favor of native or `dnf`-installable packages
* Emphasis on resource efficiency, fast startup times, and clean UIs
* Strong configurability, ideally through CSS or plain-text configuration files
* Active upstream maintenance

## Final Application Set

**Web Browser**: *Firefox* was chosen for its robust sync features, developer-oriented tooling, and adherence to open standards. Although LibreWolf was considered for its privacy enhancements, its lack of sync made it less suitable. GNOME Web was ruled out due to limited extensibility.

**Media Player**: *Celluloid*, a GTK frontend for mpv, offers a lightweight interface with keyboard support and native CSS theming. While VLC was powerful, its weight disqualified it. Haruna introduced Qt dependencies, and raw mpv lacked a GUI.

**Music Player**: *Lollypop* was selected for its GTK3 compliance, active development, and superior library handling. Rhythmbox appeared dated and heavy, while Amberol was too limited in scope.

**Markdown Editor**: *Geany* equipped with the Markdown preview plugin emerged as the optimal solution. Apostrophe was visually polished but over-featured. MarkText was disqualified due to its Electron base. Geany strikes a balance between markdown and code editing without excess overhead.

**Image Viewer**: *gThumb* was preferred for its GTK-CSS compatibility, basic editing functions, and full-screen support. Eye of GNOME lacked editing tools, while Viewnior and Ristretto were deemed too minimal.

**Archive Manager**: *Engrampa*, combined with the Thunar archive plugin, provided smooth integration and theming consistency. File Roller was GNOME-tied, and Xarchiver lacked visual coherence.

**Document Viewer**: A combination of *Evince* and *Foliate* was adopted to handle PDFs and EPUBs, respectively. Evince offered robust, lightweight PDF viewing, while Foliate added EPUB and DJVU support with strong theming. A single tool for both formats was unavailable, necessitating this split.

**Calendar and Personal Management**: *Calcurse*, a terminal-based planner, was selected for its rich functionality despite the lack of a GUI. GNOME Calendar and Orage were too desktop-specific or obsolete, while Gsimplecal lacked sufficient depth. Plans are in place to design a minimal themed GUI calendar to supplement Calcurse for basic visibility.

## Configuration & Theming Considerations

The applications selected above were further validated through a configuration lens:

* GTK-CSS theming has been implemented across all apps to enforce visual cohesion, affecting fonts, spacing, color palettes, and padding
* The Thunar file manager was extended with the archive plugin to enable seamless access to compressed files
* Office applications were intentionally excluded, consistent with the minimal, developer-oriented user model
* Markdown editing was integrated into the development workflow using Geany plugins

## Challenges and Design Tensions

Several constraints surfaced during the process:

* Avoiding Electron significantly reduced the available pool of modern applications
* Sticking to GTK3 ruled out Qt-heavy or GNOME-bound alternatives, but helped create a clean, themed UI
* Some apps, notably gThumb and Engrampa, looked outdated by default but proved highly stylable
* Geany's plugin-based Markdown preview required additional setup but achieved the desired balance of usability and speed
* Calendar theming in Gsimplecal was insufficient, reinforcing the decision to develop a custom widget or wrapper around Calcurse

## Reflections and Forward Direction

This milestone underscores the project’s guiding values:

* A consistent, minimal toolkit is preferable to bloated or heavily-integrated suites
* GTK-CSS theming offers remarkable leverage for modernizing older interfaces
* Qtile's lack of GUI is mitigated by its flexibility and integration potential

SoulmateOS continues to focus on delivering a desktop that is elegant, responsive, and adapted for engineering tasks. This curated application set will serve as the foundation for future UX and theming iterations.
