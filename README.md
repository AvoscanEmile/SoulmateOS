# SoulmateOS

SoulmateOS is a minimalist, highly customizable Linux environment meticulously crafted from a minimal AlmaLinux base. It integrates the powerful Qtile Window Manager with a carefully curated selection of lightweight, robust packages, aiming to deliver an elegant, efficient, and deeply personalized desktop experience.

## Philosophy

At its core, SoulmateOS is designed to be more than just an operating system; it's a long-term companion for users who desire total control and transparency over their computing environment. It fosters a philosophy of:

  * **Learning-by-building**: Encouraging users to grow alongside the system by manually configuring each layer.

  * **Long-term Cohabitation**: Built to minimize churn and avoid frequent overhauls, promoting stability.

  * **Trust through Transparency**: All components are scriptable, versioned, and intentionally selected, ensuring users understand system behavior.

  * **Sane Defaults**: While fully customizable, it comes with an aesthetically harmonized and carefully chosen collection of packages.

This vision transforms SoulmateOS into a trusted and extensible digital habitat. For a deeper dive into the architectural decisions, component selection, and security considerations that underpin this philosophy, please refer to the comprehensive [`architecture.md`](./docs/architecture.md) document.

## Quick Installation

For a rapid setup of SoulmateOS on a fresh AlmaLinux 9.6 minimal installation, execute the following commands:

```bash
sudo dnf install -y git
git clone https://github.com/avoscanemile/soulmateos
bash soulmateos/install/installation.sh
```

**Note:** This is a quick guide. For detailed installation instructions, system requirements, and customization options, please refer to the comprehensive [`install/README.md`](./install/README.md).

## Key Objectives & Features

SoulmateOS is built upon several key objectives, focusing on performance, security, and user empowerment:

  * **Minimalist Base**: Starting from a minimal AlmaLinux 9.6 installation ensures enterprise-grade stability, predictable lifecycles, and compatibility with robust RPM ecosystem tools.

  * **Qtile Window Manager**: Leveraging Qtile as the primary window manager provides a flexible, keyboard-driven workflow that is fully customizable with Python, offering high performance and extensibility.

  * **Curated Application Stack**: Instead of monolithic desktop environments, SoulmateOS integrates essential desktop components (terminal emulators, file managers, network tools, multimedia utilities) chosen for their minimal resource usage, functional completeness, and visual coherence.

      * **Core Apps**: Kitty (terminal), Rofi (app launcher), Thunar (file manager), Geany (text editor), btop (system monitor), GNOME Disk Utility.

      * **User Apps**: Firefox (web browser), Celluloid (media player), Lollypop (music player), gThumb (image viewer), Engrampa (archive manager), Evince/Foliate (document viewers), Calcurse (calendar/PIM).

      * **UX Enhancers**: `xfce4-clipman` (clipboard manager), `xfce4-notifyd` (notification daemon), `xfce4-screenshooter` (screenshot tool), and custom Eww widgets for volume control.

  * **Robust Security Configurations**: Implementation of a lightweight yet strong security baseline, including SELinux in enforcing mode, `firewalld` configuration, and other hardening measures.

  * **Reproducibility & Automation**: Designed for easy reinstallation and deployment through automated Bash/Ansible scripts and Git-versioned dotfiles, ensuring quick setup and version control.

  * **Unified Theming**: A consistent visual aesthetic across all GTK-based applications, Polybar, and Eww widgets, controlled centrally via CSS.

## Project Structure Overview

The SoulmateOS repository is organized to facilitate clarity, modularity, and ease of management:

  * **`install/`**: Contains the main `installation.sh` script and modular scripts for setting up the base system, graphics, Qtile, user applications, and configuration deployment.

  * **`config/`**: Houses all the configuration files for Qtile, Picom, GTK, Polybar, and Eww. These are the dotfiles that define the system's behavior and appearance.

  * **`themes/`**: Stores theme-related variables and assets, particularly for Polybar, ensuring a centralized approach to visual consistency.

  * **`docs/`**: This directory contains comprehensive documentation for the project, including:

      * **`architecture.md`**: A detailed outline of the project's design philosophy, component selection rationale, security goals, and file intercorrelations.
      * **`roadmap.md`**: A structured, modular plan outlining the project's development phases, from initial setup to future meta-distro capabilities and "rice" management.
      * **`README.md` (this file)**: Provides a high-level overview of the entire project.

  * **`devlogs/`**: Contains development logs documenting the project's progress and decisions throughout the development process.

## Roadmap & Future Vision

SoulmateOS follows a structured roadmap, evolving from a robust AlmaLinux-based environment towards a cross-distribution meta-distro platform with advanced "rice" (configuration) management capabilities. Key phases include:

  * **Current State (v1.0.0)**: A stable, AlmaLinux-based environment with a polished Qtile desktop, curated applications, and initial security hardening.

  * **Meta-Distro Development (v1.1.0 - v1.3.0)**: Research and implementation of cross-distribution compatibility, enabling SoulmateOS to be installed and run on other major Linux distributions (e.g., Debian/Ubuntu, Fedora, Arch).

  * **"Rice" Management System (v1.4.0 - v1.5.0)**: Development of `install-rice` and `create-rice` commands to standardize the packaging, sharing, and installation of user-contributed configuration "rices."

  * **Robustness & Usability Refinement (v1.6.0)**: Enhancing error handling, idempotency, and user interaction for both the installer and "rice" management system.

  * **Community & Ecosystem Foundation (v1.7.0)**: Fostering a community around SoulmateOS "rices" and comprehensive documentation for the meta-distro capabilities.

  * **SoulmateOS 2.0.0 Final Release**: The culmination of the meta-distro and "rice" management efforts, marking a significant milestone in the project's evolution.

For a detailed breakdown of each phase, please refer to the [`roadmap.md`](./docs/roadmap.md) file.

## Contributing & Customization

SoulmateOS is designed for those who love to tinker and customize. Contributions are highly welcome, whether through bug reports, feature suggestions, or direct code contributions. Please refer to the project's documentation for guidelines on how to contribute and how to further customize your SoulmateOS environment.

## License

© 2025 Emile Avoscan
This project is licensed under GPL-3.0. See the [LICENSE](./LICENSE) file for details.
