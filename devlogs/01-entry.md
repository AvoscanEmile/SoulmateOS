# Devlog 01 — Vision, Philosophy & Foundations

**Date**: 2025-06-04  
**Author**: Emile Avoscan  
**Version**: 0.1.0  

## A System Worth Owning

What does it mean to truly *own* your computing environment? SoulmateOS begins with this question — not with a toolkit, or a desktop, or a feature list. It is a project rooted in the belief that an operating system can be a medium of expression, reflection, and deliberate design.

SoulmateOS is not a fork. Not a skin. It is a **minimalist, security-conscious, custom-built Linux OS**, assembled from the barest essentials of AlmaLinux 9.6 and shaped around the AwesomeWM window manager. Every component is selected with intent, every choice made with clarity.

This project does not seek to compete with mainstream Linux distributions. It exists to reject them — or more precisely, to reject the assumptions that underlie their bloat, their opacity, and their compromise. SoulmateOS is personal, artisanal, and transparent by design.

## Foundational Pillars

SoulmateOS is structured around five philosophical tenets that govern its architecture:

### 1. Minimalism with Power

* Start with as little as possible. Add only what is earned.
* No excess packages. No silent dependencies.
* Utility and clarity guide every installation decision.

### 2. Total User Control

* No automation without explanation.
* Everything built by hand, from display manager to window rules.
* The system should feel *crafted*, not conjured.

### 3. Security-Conscious by Default

* Hardened configurations from the install phase forward.
* Use secure defaults; reduce privilege surfaces.
* Security is not a plugin — it’s a design principle.

### 4. Cohesive Aesthetic

* Fonts, colors, spacing, and behavior all work in unison.
* No patchwork UI, no mismatched dialogs.
* Every element reflects a unified visual and functional identity.

### 5. Reproducibility

* Document every step. Version everything.
* A future install should behave *identically* to today’s.
* Forking SoulmateOS should be frictionless.

## Project Structure: Designing for Clarity

A philosophy of reproducibility demands a clear, logical structure. SoulmateOS's repository reflects that:

```
config/     → System-level and application configurations (WM, shell, terminal)
themes/     → UI themes, icon sets, wallpaper, font definitions
install/    → Bootstrapping scripts, package lists, system setup
docs/       → Philosophical notes, architecture diagrams, roadmap
devlog/     → Development journals (like this one), errors, lessons learned
```

Nothing hidden. Nothing magical. Every layer of the OS is transparent and explainable. The goal isn't just to have it work — it's to know *why* it works.

## Toward a Personal Computing Philosophy

SoulmateOS is a workstation OS for a single user, but not a closed world. It invites scrutiny, adaptation, and remixing. Its long-term vision includes:

* **ISO generation** for rapid reproducible deployment
* **Layered modules** (e.g., media stack, game tooling, research tools)
* **A curated ecosystem** that reflects the project's aesthetic and technical rigor
* **Essays and commentary** on broader OS design, philosophical and technical

But before any of that, the foundation must be solid. Build, refine, understand. Document.

Next: prepare the first AlmaLinux base install and define the WM stack.
