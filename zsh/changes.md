        * **Binaries analysis**: 05-aliases.zsh has 10 checks (bat,
     btm, duf, dust, eza, fd, paru, procs, rg, wl-copy). All
    retained—excellent modern CLI suite (replacements for
    cat/htop/df/du/ls/find/pacman/ps/grep/clipboard). No changes
    needed.
        * **fzf consolidation**: zsh/integrations/fzf.zsh is the
    central hub (dynamic theming, widgets/functions for
    git/docker/man/systemd/pacman/npm/etc., keybinds, completion).
    Minor fzf usages elsewhere can stay tool-specific or be
    refactored later.
        * **Modular previewer**: New `zsh/tools/fzf-preview.sh`
    (executable preview logic for dirs/eza-tree,
    files/bat-highlight, images/chafa/kitty,
    PDFs/archives/media/ffprobe). Handles edge cases gracefully.
        * **Integration**: Updated `zsh/integrations/fzf.zsh`:
            * Added `export FZF_PREVIEW=...`

            * Swapped inline `bat`/`eza` previews → `"bash
    \"$FZF_PREVIEW\" {} ..."` for DEFAULT_OPTS, CTRL_T, ALT_C,
    completions (cd/* cases).

            * All fzf invocations now leverage the previewer
    (toggle ?/ctrl-/), with specific previews preserved (git diffs,
     history syntax, etc.).
        * No hidden dirs touched (refs only).

    Test: source ~/.zshrc (or restart shell). Try ctrl-t (files),
    alt-c (dirs), fzf-git-add (fga), etc. Previews should be
    richer/unified.

    Mess cleaned—fzf is now one-file + previewer modular goodness.
    Ping for tweaks!
