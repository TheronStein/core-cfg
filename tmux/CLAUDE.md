
# CLAUDE.md

This file provides general guidance to Claude Code (claude.ai/code) when
working with code across all projects.

This is an early stage of a comprehensive tmux configuration with multi-host support:

### TMUX

- **Prioritize Core Improvements**
  - Start by optimizing global options (prefix key, history limit, mouse support).
  - Ensure these foundational settings are tuned before tweaking plugin behavior.
- **Consolidate & Simplify**
  - Merge overlapping binds or redundant options into single, clear definitions.
  - Remove or comment out legacy entries that no longer apply.
- **Default-Shell**:
 	- Specify your preferred shell (`set -g default-shell /bin/zsh`).
- **Renaming**:
 	- Enable/disable auto-rename or define manual renaming binds.
- **Synchronization**:
 	- If you use synchronized panes, group that bind clearly.
- **Custom Scripts & Hooks**
 	- Group any `set-hook` calls (e.g., `client-session-changed`).
 	- If you call shell scripts, note their paths and expected parameters.

### Multi-Host TMUX Configuration: Guideline Specifications

1. **Unified Version Control**
    - Store `~/.tmux.conf` (and related scripts/plugins) in a Git repository.
    - Tag releases or use branches to denote stable vs. experimental configs.
    - Clone/pull updates on every host to keep in sync.
2. **Host-Specific Overrides**
    - Within your main config, source a `tmux.local.conf` if present:
        `if-shell "[ -f ~/.tmux.local.conf ]" "source-file ~/.tmux.local.conf"`
    - Use `tmux.local.conf` for per-machine tweaks (e.g., different terminal widths, host-specific keybinds).
3. **Environment Detection*
    - Detect host or environment via hostname or environment variables:
        `set -g @host_name "#(hostname)" if-shell '[ "#{@host_name}" = "server1" ]' 'source-file ~/tmux.server1.conf'
    - Automate conditional loading of plugins or options based on detected host.
4. **Plugin Management Across Hosts**
    - In CI or on first `git clone`, run a bootstrap script to install TPM and plugins:
        `git clone … ~/.tmux ~/.tmux/plugins/tpm/bin/install_plugins`
    - Ensure plugin directory lives within your dot-files repo.
5. **Idempotent Setup Script**
    - Provide a single `bootstrap.sh` that:
        1. Installs or updates TPM.
        2. Symlinks `~/.tmux.conf` to the repo’s copy.
        3. Installs plugins
        4. Validates tmux version ≥ required minimum
    - Make the script safe to re-run on any host without side-effects.
6. **Configuration Validation**
    - Add a quick self‐check at the end of your config to catch syntax errors:
        `run-shell "tmux source-file ~/.tmux.conf >/dev/null 2>&1 || echo 'TMUX config error!'"`
    - Optionally integrate a CI job that lints or sources the config on each push.
7. **Consistent Prefix & Core Options**
    - Centralize global options (prefix, history-limit, mouse) in the main config.
    - Avoid per-host redefinitions unless absolutely necessary.
    - separate prefix or separating primary host prefix when connecting to another host
8. **Portable Keybindings**
    - Use tmux’s built-in key names (e.g. `C-h`, `M-Left`) rather than terminal-specific codes.
    - Where terminals differ, wrap binds in host checks.
9. **Shared Status Bar Theme
    - Define status-bar layout, colors, and segments in a single file.
    - If some hosts lack certain info (battery, network), conditionally hide those segments.
    - separate status theme for nested sessions inside external hosts.
10. **Backup & Rollback**
    - Before applying updates, `cp ~/.tmux.conf ~/.tmux.conf.bak.$(date +%F_%T)` in your bootstrap.
    - Provide a rollback command (`git checkout HEAD@{1}`) documented in the README.
11. **Automated Syncing (Optional)**
  - `cron`/`systemd` timer to `git pull` periodically.
    - Notify you (email or desktop alert) if updates include breaking changes.

### TMUX Statusbar

- **Left vs. Right**:
 	- Separate `status-left` and `status-right` configurations.
- **Components**:
 	- Define each status element (session name, time, battery, etc.) in its own line or variable.
 	- **Refresh Interval**: Set `status-interval` with an explanatory comment.

### TMUX Plugins

- **Plugin Manager**: If using TPM, dedicate a block for plugin initialization.
- **Plugin List**: List `set -g @plugin` lines alphabetically or by category.
- **Post-Install Hooks**: Include `run '~/.tmux/plugins/tpm/tpm'` at bottom.
- **Review Plugin Blocks**
  - Locate each `@plugin` declaration (e.g. TPM lines) and confirm whether its config stanza is present.
  - Flag any plugins without accompanying settings or binds.
- **Missing Plugin Specifications**
 	- For each unconfigured plugin, provide a detailed explanation:
   - explanation of what the plugin does and how it fits into the workflow
   - suggestions on integration or alternatives
   - Incorporate any additional preferences or edge-case requirements.

### Versioning & Maintenance

- **Version Banner**: Embed a comment with your config’s version or git tag.
- **Changelog Section**: At the very end, keep a short changelog of key edits.
- **Source Control**: Note in a comment where the repo lives (e.g. GitHub URL).

### Code Review Guidelines

- Review for correctness, readability, and maintainability
- Check for security vulnerabilities
- Ensure proper error handling
- Verify test coverageff
- Look for performance issues
- Confirm documentation is updated

### Documentation Standards

- **Entry Point**: Provide a top-level `README.md` (or equivalent) that gives an at-a-glance project overview, key features, and links to deeper sections.
- **Consistent Structure**: Organize all docs under a single `docs/` directory (or `doc/`, `documentation/`), with one file per topic.
- **Overview Page**: Include a contents section (table of contents) at the top of each major doc, linking to its subsections.
- **Naming Conventions**: Use clear, descriptive file names (e.g. `getting_started.md`, `api_reference.md`) and consistent casing (snake_case or kebab-case).
- **Versioning**: Tag documentation updates in sync with release versions (e.g., include version banners or changelogs).
- **Docstrings & Comments**: Embed concise docstrings in code for public functions/classes; avoid duplicating in external docs.
- **Templates/Boilerplate**: Provide templates for new docs (e.g., architecture decision records, design docs) to ensure uniformity.
- **Code Samples**: Include minimal, runnable code snippets in language-appropriate formatting blocks; annotate expected outputs.
- **Diagrams & Visuals**: When helpful, embed architecture diagrams, data flow charts, or UML; store source files (e.g., `.drawio`) alongside exported images.
- **Auto-Generated API Reference**: Use tools (Sphinx, Javadoc, Doxygen, MkDocs) to generate and publish up-to-date API docs.
- **Changelog**: Maintain a `CHANGELOG.md` following “Keep a Changelog” conventions, documenting features, fixes, and breaking changes.
- **Accessibility**: Write in clear, neutral English; use headings, lists, and alt text for images to aid readability and accessibility.
- **Up-to-Date**: Review and update documentation with every pull request that changes functionality; include doc-linting in CI.
- **Cross-Linking**: Link between related sections (e.g., from tutorials to API reference) so readers can easily navigate.
- **Troubleshooting & FAQs**: Reserve a dedicated file (`troubleshooting.md` or `FAQ.md`) for common errors and their resolutions.
- **Contribution Guidelines**: In `CONTRIBUTING.md`, specify documentation style (e.g., markdown rules, link checks) and PR review expectations for docs.
- **Localization (Optional)**: If supporting multiple languages, namespace docs (e.g., `docs/en/`, `docs/es/`) and indicate translation status.
- **License & Attribution**: Include any third-party content licenses or attributions at the bottom of relevant documentation files.
