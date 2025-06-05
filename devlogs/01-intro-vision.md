# Devlog Entry 01 — Vision, Philosophy & Foundations

**Date**: June 4th 2025
**Author**: Emile Avoscan  
**Entry ID**: #01
**Current Version**: 0.0.1

---

## ✨ Project Name: SoulmateOS

SoulmateOS is a custom, security-conscious, minimalist Linux operating system designed from the ground up as a deeply personal computing environment. It is not a distro fork, nor a reskin — it is a careful recomposition of an operating system using a minimal AlmaLinux base, the AwesomeWM window manager, and a tightly curated set of components chosen to reflect a cohesive philosophy.

This is not an experiment. It is an assertion: that one can own their computing experience entirely, from the architecture up through the aesthetic. SoulmateOS is a direct rejection of bloated environments, dependency spaghetti, and desktop paradigms that confuse polish with productivity.

---

## 🔧 Project Scope & Approach

SoulmateOS is structured around the following key principles:

### 1. **Minimalism with Power**
- Start from a clean, minimal AlmaLinux base.
- Avoid package clutter and feature creep.
- Every added package must justify its inclusion by utility or cohesion.

### 2. **User Control & Transparency**
- Build everything manually and explicitly.
- No magic scripts that abstract critical setup steps.
- Everything version-controlled from day one with Git.

### 3. **Security-aware Architecture**
- Integrate robust security practices from the early install stage.
- Favor hardened defaults, restricted privilege surfaces, and secure-by-design packages.
- Emphasis on staying lightweight while secure.

### 4. **Cohesive Aesthetic**
- A complete visual and functional unification.
- Window manager, terminal, system UI, fonts, and icons must all reflect a shared design language.

### 5. **Reproducibility**
- Final goal is to make SoulmateOS easy to reinstall and replicate via install scripts and modular documentation.
- Anyone should be able to reproduce your exact environment, or fork it for their own needs.

---

## 📂 Repository Structure Philosophy

To support these principles, the repository is structured into logical, clean directories:
- `config/` → All personalized configuration files (AwesomeWM, terminal, etc.)
- `themes/` → All theme elements, colors, icons, wallpapers
- `install/` → Installation scripts and post-install automation
- `docs/` → Planning, philosophy, changelog, roadmap, and architecture
- `devlog/` → These journal entries, documenting development decisions and progress

Each decision made in SoulmateOS will be **explained**, not just executed. This isn't just about building an OS — it's about understanding, refining, and mastering the construction of a usable, beautiful system.

---

## 🧱 Long-Term Vision

SoulmateOS is not a general-purpose distribution. It’s a **bespoke workstation OS** built by one user for one user — but documented with such clarity that it becomes reproducible and forkable. The future may include:
- ISO generation for faster deployment
- Optional modular installs (e.g., gaming layer, creative suite layer)
- A community fork under a different branding
- A philosophical essay series on the state of desktop environments

But first — build, refine, and document.
