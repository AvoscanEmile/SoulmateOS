# Devlog Entry 02 — Initial Repository Setup

**Date**: 2025-06-04  
**Author**: Emile Avoscan  
**Entry ID**: #02
**Current Version**: 0.0.1

---

## What’s Been Done

The groundwork is in place.

Today I created the GitHub repository that will house SoulmateOS. The focus wasn’t on code yet — it was on structure, clarity, and setting the tone for how this project will evolve. My goal is for this repo to grow into a well-organized, readable, and legally sound open-source base for a Linux environment built with intention.

### Repository Structure

The initial folders reflect the long-term goals of the project:
- `config/` → All personalized configuration files (AwesomeWM, terminal, etc.)
- `themes/` → All theme elements, colors, icons, wallpapers
- `install/` → Installation scripts and post-install automation
- `docs/` → Planning, philosophy, changelog, roadmap, and architecture
- `devlog/` → These journal entries, documenting development decisions and progress

Within `docs/`, I’ve seeded the following files:

- `architecture.md` — A high-level overview of the vision and current system design goals.
- `roadmap.md` — Planned phases of the project, broken down into sequential milestones.
- `changelog.md` — Currently only has a quick description of the current github setup and the plan for the project. Redundant, but better redundant than missing. 

I’ve also added a placeholder `README.md` with a short project description and copyright/license information.

### Licensing Choices

I chose the **Apache License 2.0** for this project. It’s open source, but offers strong protections:
- Attribution is required.
- Modifications must be marked clearly.
- No liability is transferred.
- I retain legal grounds if someone tries to claim or sell the unaltered system as their own.

Each file will include a copyright header for reinforcement.

## Reflections

This stage wasn’t flashy, but it mattered. Documentation is a core part of engineering, not an afterthought. I don’t just want to *build* SoulmateOS — I want to make it transparent, reproducible, and readable.

I also resisted the temptation to start pushing configs into the repo right away. I’ll only track what actually needs tracking, based on changes I make to packages, configs, or scripts. No bloat, no unnecessary files.

For now, the structure is here. It’s clean. It’s ready.

## What’s Next?

Next up: installing AlmaLinux Minimal and beginning the initial graphical layer setup with AwesomeWM.

The system begins to breathe in the next log.

