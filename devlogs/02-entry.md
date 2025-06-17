# Devlog 02 — Initial Repository Setup

**Date**: 2025-06-04  
**Author**: Emile Avoscan  
**Version**: 0.1.0  

## Laying the Foundation

The real work hasn't begun — but the scaffolding now exists. Today’s focus wasn’t code, configuration, or window managers. It was infrastructure: the repository, its structure, its licenses, and the tone it sets.

SoulmateOS will not evolve in chaos. It will grow in a space that is readable, maintainable, and governed by principles as clear as the system it seeks to build.

## Repository Structure: Clarity from the Start

The GitHub repository was initialized with a structure that reflects the long-term trajectory of the project:

```
config/     → Personalized configuration files (AwesomeWM, terminal, etc.)
themes/     → Theme elements: fonts, icons, wallpapers, color palettes
install/    → Installation scripts, bootstrapping automation, post-install routines
docs/       → Architecture diagrams, philosophical notes, changelogs, and roadmap
devlog/     → These narrative entries, documenting technical and design decisions
```

This isn't a dump of files — it's a *designed knowledge system*. Each directory serves a purpose, and each file within it will be tracked with intention.

## Seeding the Documentation

Under `docs/`, three foundational documents were created:

* **`architecture.md`** — A high-level overview of the intended system design, describing the philosophical and technical scaffolding.
* **`roadmap.md`** — A sequenced breakdown of project milestones, covering install phases, system polish, modularity, and reproducibility.
* **`changelog.md`** — Initial entry records repository setup and lays the ground for systematic change tracking. Redundant with this devlog, perhaps — but redundancy here serves accountability.

Additionally, a placeholder `README.md` introduces SoulmateOS and outlines its goals. The intention is for future readers to understand the project's nature in a glance — and contribute without friction.

## Licensing Philosophy

SoulmateOS is licensed under the **Apache License 2.0**, chosen for its clarity and balance:

* **Attribution is required** — derivatives must acknowledge the source.
* **Modifications must be marked** — clarity of authorship and responsibility.
* **No liability** — legal shielding for contributors.
* **Anti-appropriation** — protects against closed redistribution of the unmodified system.

Each file will include explicit copyright headers to reinforce these protections.

## Reflections on the Unseen Work

There’s a temptation to rush toward technical implementation — pushing configs, tweaking boot sequences, or scripting window manager rules. But clarity at the start prevents chaos later.

Today’s work was invisible to the machine, but essential to the human. I’m resisting the urge to track unnecessary files or “pre-optimize.” SoulmateOS will only record what matters: configuration, customization, reproducibility.

The repository now exists not as an empty shell, but as a statement of intent.

## What Comes Next

The next devlog will move into the tangible system: a minimal AlmaLinux install, and the first attempt to bring up a graphical layer via AwesomeWM.

The code will begin to speak — but only because the documentation already knows what it wants to say.
