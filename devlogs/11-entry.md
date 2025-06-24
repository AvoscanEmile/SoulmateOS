# Devlog 11 — Modular Installer Refactor

**Date**: 2025-06-24  
**Author**: Emile Avoscan  
**Target Version**: 0.6.0  

## Main Objective

The goal of this series of improvements was to refactor the monolithic `installation.sh` script of the soulmateOS project into a modular, maintainable installer. Key objectives included centralizing flag logic, separating concern across specialized executor scripts, and ensuring a clear, professional-grade orchestrator capable of handling deployment, cleanup, and user customization flags.

### Background

The existing installer had grown beyond a simple bootstrapper, accumulating steps for enabling repositories, installing system packages, configuring window managers, and deploying configuration files. This complexity led to difficulties in maintenance, debugging, and extension—especially as additional phases (graphics, Qtile, user apps, configuration) were layered in. It became clear that a scalable, modular approach was needed to support power users and developers without sacrificing clarity.

### Implementation

#### Architecture Decisions

* **Thin Orchestrator**: `installation.sh` serves solely to parse flags, maintain sudo sessions, sequence phases, and perform cleanup.
* **Fat Executors**: Four module scripts—`graphics.sh`, `qtile.sh`, `user.sh`, and `config.sh`—each handle a specific installation phase.

#### Flag Handling

All CLI flags (`--keep-repo`, `--keep-docs`, `--keep-devlogs`) are parsed in `installation.sh`. Post-parsing, no further flag logic appears in module scripts; cleanup actions are driven by boolean variables set at the top level.

```bash
# Example flag parsing in installation.sh
KEEP_REPO=false; KEEP_DOCS=false; KEEP_DEVLOGS=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep-repo) KEEP_REPO=true; shift;;
    --keep-docs) KEEP_DOCS=true; shift;;
    --keep-devlogs) KEEP_DEVLOGS=true; shift;;
    -h|--help) usage;;
  esac
done
```

#### Module Verification

Before running any phase, the orchestrator verifies that each module script exists and is executable, failing early with a clear error if any are missing.

```bash
for phase in graphics qtile user config; do
  script="$MODULES_DIR/${phase}.sh"
  [[ -x "$script" ]] || { echo "Missing module: $script"; exit 1; }
done
```

#### Configuration Module Refactor

The `config.sh` module was refactored to:

* Accept `REPO_DIR` and `CONFIG_DIR` via environment or defaults
* Validate `config/` and `themes/` source trees
* Deploy both directories via `rsync --delete` (prunes only the destination)
* Make Qtile’s autostart executable
* Create explicit, safe symlinks for live configuration

```bash
: "${REPO_DIR:=$HOME/soulmateos}"
: "${CONFIG_DIR:=$HOME/.config/soulmateos}"

rsync -av --delete "$REPO_DIR/config/" "$CONFIG_DIR/"
rsync -av --delete "$REPO_DIR/themes/" "$CONFIG_DIR/themes/"

ln -sfn "$CONFIG_DIR/qtile" "$HOME/.config/qtile"
```

#### Professional Polishing

* Added a version stamp and timestamp echo at startup
* Unified error and exit traps to report failing commands and clean up background processes
* Quoted all variable expansions for path safety

### Challenges & Resolutions

* **Complexity of Monolith**: Initial script was nearly 200 lines and difficult to grok. *Resolution*: Modularization into four phases reduced cognitive load.
* **Flag Inheritance**: Early designs exported flags into modules, but this diluted separation of concerns. *Resolution*: Centralize flag logic in the orchestrator only.
* **Rsync `--delete` Confusion**: Concern that source trees might be pruned inadvertently. *Resolution*: Clarified that `--delete` only affects the destination, and moved any repo cleanup exclusively into `installation.sh`.

### Testing & Validation

* **Module Script Checks**: Ran each module standalone to confirm idempotent behavior.
* **Flag Combinations**: Tested all permutations of `--keep-repo`, `--keep-docs`, and `--keep-devlogs` to ensure correct files are retained or removed.
* **Edge Cases**: Simulated missing `themes/` and `config/` directories to verify clean failure messages.

### Outcomes

* A clearly structured installer with an orchestrator and four executor modules.
* Professional-grade error handling, logging, and versioning.
* Users can customize cleanup behavior without digging into module internals.
* The `config.sh` module correctly stages and links configuration assets without unintended side-effects.

## Reflection

This refactoring reinforced the importance of **separation of concerns** in shell scripting—what begins as a simple installer can quickly evolve into a brittle monolith. By adopting a **thin orchestrator, fat executor** pattern, we gained clarity, debuggability, and extensibility. Future phases or collaborators can now slot into this framework with minimal friction, ensuring that soulmateOS remains both powerful for developers and approachable for end users.

## Second Objective

The primary goal of this step was to refine and robustly orchestrate the `soulmateOS` installation process. Key focuses included improving error trapping, environment detection, module validation, configuration deployment, and symlink management to ensure a repeatable, idempotent installer for version 0.6.0.

### Background

The project comprises a multi-stage Bash installer (`installation.sh`) which pulls from a local repository, installs packages, deploys user configurations, and sets up services and symlinks. Early iterations suffered from unbound-variable errors, path-mismatches, and fragile permission checks. As development progressed, the need arose to make the script resilient across run contexts (`sudo` vs. user), handle non-executable module scripts, and correctly place configuration links.

### Implementation

We applied the following refinements:

* **Error Trapping Sequence**: Removed the initial `trap ... kill $SUDO_KEEPALIVE` before the keepalive process existed, relocating the `EXIT` trap immediately after `SUDO_KEEPALIVE=$!`. Error-reporting (`ERR` trap) was separated from cleanup (`EXIT` trap) for clarity.

* **Module-Existence Check**: Replaced `[[ -x ... ]]` with `[[ -f ... ]]` to validate the presence of `.sh` files, since modules are invoked via `bash module.sh` and need not be marked executable.

* **Home Directory Resolution**: Introduced logic to detect the real user’s \$HOME when run under `sudo`, using `SUDO_USER` and `getent passwd`, preventing inadvertent lookups in `/root`.

* **Symlink Mapping Correction**: Updated the associative `LINKS` array to include the `services/` subdirectory in keys, ensuring notifications service files at `$CONFIG_DIR/services/org.freedesktop.Notifications.service` are correctly linked.

* **Manual Symlink Best Practices**: Documented use of `ln -sfn` with `-f` and `-n` flags to force overwrite existing targets safely, and introduced pre-check guards in scripts to avoid clobbering real files.

* **Usage of Arrays for Batch Deletions**: Suggested array-based patterns for scalable `rm -rf` calls when cleaning up installation artifacts.

Relevant snippet for module validation:

```bash
for script in graphics qtile user config; do
  module="$MODULES_DIR/${script}.sh"
  if [[ ! -f "$module" ]]; then
    echo "Error: Missing module file: $module" >&2
    exit 1
  fi
done
```

And for symlinks:

```bash
declare -A LINKS=(
  [qtile]="$HOME/.config/qtile"
  [services/org.freedesktop.Notifications.service]="$HOME/.local/share/dbus-1/services/org.freedesktop.Notifications.service"
)
for src_rel in "${!LINKS[@]}"; do
  SRC="$CONFIG_DIR/$src_rel"
  DST="${LINKS[$src_rel]}"
  [[ -e "$SRC" ]] || { echo "Missing: $SRC" >&2; exit 1; }
  ln -sfn "$SRC" "$DST"
done
```

### Challenges & Resolutions

* **Unbound `SUDO_KEEPALIVE`**: Moved the cleanup trap to after keepalive process creation, or used `${SUDO_KEEPALIVE:-}` expansion when early trapping was unavoidable.
* **Non-executable Modules**: Changed executable-check to existence-check (`-f`), aligning with how modules are invoked.
* **Incorrect Path for Notifications Service**: Updated mapping key to include `services/`, correcting the source path for symlinking.
* **`sudo` vs. User Context**: Introduced logic to resolve `$HOME` according to `$SUDO_USER` when the script runs under `sudo`.

### Testing & Validation

Testing was iterative:

* **Local runs without `sudo`** verified correct module detection and symlinks.
* **Runs under `sudo`** confirmed real-user home resolution prevented missing-path errors.
* **Manual invocation** of module scripts ensured no execution-permission side-effects.
* **Symlink edge cases** tested with existing files, directories, and broken links, using `ln -sfn` and pre-check guards.

### Outcomes

* A robust installer script that cleanly handles errors, preserves user configurations, and reliably deploys modules.
* Reduced user friction: custom `qtile` configs were automatically retained without special flags.
* Clear patterns documented for batch removals and symlink management.

## Reflection

This exercise highlighted how small-order details—like the timing of trap setup or the choice of file-test flags—can significantly impact script reliability. By methodically isolating each concern and testing under varied contexts, we achieved a repeatable, idempotent installer. Future growth should balance maintainability with the complexity of real-world environment variability.

## General Conclusion

The refactor of the `installation.sh` script into a modular installer for soulmateOS (version 0.6.0) demonstrates the power of **separation of concerns** and disciplined scripting practices. By adopting a **thin orchestrator, fat executor** pattern, we achieved:

* **Maintainability**: Centralized flag handling and module validation simplify future extensions and reduce cognitive overhead.
* **Robustness**: Improved error trapping, environment detection, and idempotent operations ensure reliable, repeatable installations across diverse contexts.
* **User Control**: Fine-grained `--keep-*` flags and clear cleanup semantics empower users to tailor the installer without delving into scripts.
* **Professionalism**: Version stamping, unified logging, and consistent quoting elevate the installer to production-grade quality.

Going forward, this architecture provides a solid foundation for integrating additional installation phases—such as service orchestration or advanced configuration hooks—without sacrificing clarity. Contributors can slot in new modules by simply following the established framework, and users benefit from transparent, predictable behavior. Ultimately, this refactor not only addresses the immediate complexity of the monolith but also sets a scalable roadmap for the continued evolution of soulmateOS.
