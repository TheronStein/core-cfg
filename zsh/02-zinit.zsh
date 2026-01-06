# ~/.core/zsh/02-zinit.zsh
# Zinit plugin manager configuration – 2025 elite edition
#=============================================================================
#
# =============================================================================
# ZINIT BOOTSTRAP + SSH CONFIG (MUST BE FIRST!)
# =============================================================================

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

# Force SSH for ALL GitHub clones — eliminates auth prompts forever
zstyle ':zinit:cloneopts' --git-protocol ssh
zstyle ':zinit:cloneopts' --all ssh

# Auto-install Zinit if missing
[[ ! -f "$ZINIT_HOME/zinit.zsh" ]] && {
    print -P "%F{33}Installing Zinit…%f"
    command mkdir -p "$ZINIT_HOME:h"
    git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
}

# NOW source zinit (SSH is already configured)
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

#=============================================================================
# ZINIT ANNEXES
#=============================================================================
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

#=============================================================================
# PROMPT (instant prompt compatible)
#=============================================================================
if [[ -o interactive ]]; then
    zinit ice depth=1
    zinit light romkatv/powerlevel10k
    [[ -f "${XDG_CONFIG_HOME}/p10k/p10k.zsh" ]] && source "${XDG_CONFIG_HOME}/p10k/p10k.zsh"
fi

#=============================================================================
# COMPLETIONS + FZF-TAB (turbo + Nix-safe)
#=============================================================================
# Load fzf-tab preview functions first (must be available before fzf-tab uses them)
source "$HOME/.core/.sys/cfg/zsh/functions/widgets/fzf-preview"
source "${CORE_CFG}/zsh/integrations/fzf.zsh"

# Core zsh completions
zinit wait lucid for blockf zsh-users/zsh-completions
# NOTE: zsh-autocomplete disabled due to fundamental conflicts with our setup:
# 1. It requires being loaded BEFORE compinit (we call compinit in 00-options.zsh)
# 2. It requires NO other compinit calls (conflicts with our completion config)
# 3. It conflicts with fzf-tab (both try to handle completion display)
# The built-in completion system + fzf-tab provides excellent functionality.
# zinit ice wait lucid; zinit light marlonrichert/zsh-autocomplete
# zman — your beautiful man page browser (pure function)

# Universal binary installer + smart completion extractor
# Binaries → ~/.local/bin (via ZPFX symlinks)
# Completions → ~/.core/.sys/cfg/zsh/completions
zbin() {
  local repo="$1" bin="${2:-${1##*/}}" ver="${3:-latest}"

  # Skip zoxide — it generates its own completion at runtime
  [[ "$repo" == "ajeetdsouza/zoxide" ]] && {
    zinit ice from"gh-r" as"null" \
        ver"$ver" mv"zoxide* -> zoxide" sbin"**/zoxide" \
        atclone"./zoxide init zsh > init.zsh" atpull"%atclone" src"init.zsh" \
        lucid wait"0"
    zinit light "$repo"
    return
  }

  # All other tools: extract binary to $ZPFX/bin, extract completions to ZSH_CORE
  local comp_dest="${ZSH_CORE}/completions"
  zinit ice from"gh-r" as"null" \
      ver"$ver" \
      mv"$bin* -> $bin" sbin"**//$bin -> ${HOME}/.local/bin/$bin" \
      atclone"
        mkdir -p ${comp_dest};
        [[ -f completions/_${bin} ]] && cp completions/_${bin} ${comp_dest}/ ||
        [[ -f **/_${bin}(|.zsh)(.N) ]] && cp **/_${bin}(|.zsh)(.N) ${comp_dest}/_${bin} ||
        [[ -f ${bin}.zsh ]] && cp ${bin}.zsh ${comp_dest}/_${bin} || true
      " \
      atpull"%atclone" \
      lucid wait"0"
  zinit light "$repo"
}

zbin junegunn/fzf
zbin ajeetdsouza/zoxide
zbin eza-community/eza
zbin sharkdp/bat
zbin sharkdp/fd
zbin BurntSushi/ripgrep
zbin dandavison/delta
zbin bootandy/dust
zbin dalance/procs
zbin ClementTsang/bottom
zbin sxyazi/yazi yazi nightly

# gh (GitHub CLI) — special case
zinit ice from"gh-r" as"program" pick"gh" mv"gh_* -> gh" sbin"gh" lucid wait"0"
zinit light cli/cli

# onefetch — special case
zinit ice from"gh-r" as"program" pick"onefetch-*" mv"onefetch-* -> onefetch" lucid wait"0"
zinit light o2sh/onefetch

# TMUX — compile from source with Ctrl-I patch
zinit ice as"null" \
    atclone'./autogen.sh && 
            curl -fsSL https://patch-diff.githubusercontent.com/raw/tmux/tmux/pull/3734.patch | patch -p1 && 
            ./configure --prefix="$ZPFX" && 
            make && make install' \
    atpull'%atclone' \
    sbin"$ZPFX/bin/tmux" \
    lucid wait"0"
zinit light tmux/tmux

zinit ice lucid wait"0"
zinit light tmux-plugins/tpm

[[ ! -d "${SYS_TMUX}" ]] && \
  mkdir -p "${CORE_CFG}/tmux/plugins"

#=============================================================================
# ESSENTIAL PLUGINS
#=============================================================================

zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline"

# CONDITIONAL COMPLETION LOADER — only loads if binary exists (Nix-safe)
# =============================================================================
zinit_load_if_exists() {
  local cmd="$1" plugin="$2" ice_extra="${3:-}"
  command -v "$cmd" &>/dev/null && zinit ice wait"2" lucid blockf ${ice_extra} && zinit load "$plugin"
}

# =============================================================================
# COMPINIT - Initialize completion system AFTER plugins add their completions
# =============================================================================
autoload -Uz compinit
# Use -C (skip security check) if cache is less than 24 hours old
if [[ -n "${ZSH_CACHE_DIR}/.zcompdump"(#qN.mh-24) ]]; then
    compinit -C -d "${ZSH_CACHE_DIR}/.zcompdump"
else
    compinit -d "${ZSH_CACHE_DIR}/.zcompdump"
fi

# =============================================================================
# FZF-TAB LOADING (CRITICAL: Must load directly, not through zinit_load_if_exists)
# fzf-tab is a plugin, not a binary command - the command check would always fail
# =============================================================================
# Load fzf-tab without 'wait' so completions are available immediately
# The atload ice configures zstyles after the plugin initializes
zinit ice lucid atload'
    # fzf-tab core settings
    zstyle ":fzf-tab:*" fzf-preview-window "right:50%:wrap"
    zstyle ":fzf-tab:*" switch-group "," "."
    zstyle ":fzf-tab:*" continuous-trigger "/"

    # Apply theme colors and use plain fzf (not tmux popup - causes shell spawn delay)
    zstyle ":fzf-tab:*" fzf-command fzf
    if [[ -n "${_FZF_THEME_COLORS:-}" ]]; then
        zstyle ":fzf-tab:*" fzf-flags --height=80% --color="${_FZF_THEME_COLORS}"
    else
        zstyle ":fzf-tab:*" fzf-flags --height=80%
    fi
'
zinit light Aloxaf/fzf-tab

# =============================================================================
# PLUGIN LOADING (from 02-zinit.zsh)
# =============================================================================
zinit_load_if_exists fzf            junegunn/fzf
zinit_load_if_exists kubectl        kubectl/kubectl
zinit_load_if_exists helm           helm/helm
zinit_load_if_exists gh             github/cli
zinit_load_if_exists docker         docker/cli
zinit_load_if_exists docker-compose docker/compose
zinit_load_if_exists terraform      hashicorp/terraform
zinit_load_if_exists bat            sharkdp/bat
zinit_load_if_exists fd             sharkdp/fd
zinit_load_if_exists rg             BurntSushi/ripgrep       "as'completion'"
zinit_load_if_exists eza            eza-community/eza        "as'completion'"
zinit_load_if_exists zoxide         ajeetdsouza/zoxide
# zinit_load_if_exists atuin          atuinsh/atuin
zinit_load_if_exists starship       starship/starship        "as'completion'"
zinit_load_if_exists fzf            junegunn/fzf
zinit_load_if_exists yazi           sxyazi/yazi              "as'completion'"
zinit_load_if_exists lazygit        jesseduffield/lazygit
zinit_load_if_exists k9s            derailed/k9s
zinit_load_if_exists btop           aristocratos/btop
zinit_load_if_exists dust           bootandy/dust
zinit_load_if_exists duf            muesli/duf
zinit_load_if_exists bottom         ClementTsang/bottom      "as'completion'"

#=============================================================================
# CONDITIONAL PLUGIN LOADING (only actual plugins, not binaries)
#=============================================================================

# Nix completions (only if nix is installed)
case "$(get_distro)" in
  nixos|arch|fedora|debian|ubuntu|void|alpine|wsl)
    (( $+commands[nix] )) && {
      zinit ice wait lucid blockf
      zinit light nix-community/nix-zsh-completions
      zinit ice wait lucid
      zinit light chisui/zsh-nix-shell
    }
    ;;
esac

# Vi mode with keybinding initialization hook
# CRITICAL: zsh-vi-mode overwrites ALL keybindings on init
# Solution: Define zvm_after_init() BEFORE loading the plugin
# The plugin will call this function after initialization

# This function MUST be defined before zsh-vi-mode loads
function zvm_after_init() {
    # Re-bind our custom widgets that vi-mode overwrote
    # These must be set AFTER vi-mode initializes to prevent conflicts

    # Main menu system - multiple triggers for reliability
    # Note: Ctrl+Space reserved for tmux prefix

    # Alt+Space (primary)
    bindkey -M viins '\e ' widget::universal-overlay
    bindkey -M vicmd '\e ' _core_menu_widget

    # Alt+/ (alternate)
    bindkey -M viins '\e/' widget::universal-overlay
    bindkey -M vicmd '\e/' _core_menu_widget

    # Alt+M as another alternate
    bindkey -M viins '\em' _core_menu_widget
    bindkey -M vicmd '\em' _core_menu_widget

    # Re-bind FZF widgets (these get overwritten by vi-mode)
    bindkey -M viins '^R' widget::fzf-history-search  # Ctrl+R: Unified history browser
    bindkey -M viins '^F' widget::fzf-file-selector
    bindkey -M viins '^[f' widget::fzf-directory-selector
    bindkey -M viins '^K' widget::fzf-kill-process
    bindkey -M viins '^P' widget::command-palette

    # Git widgets
    bindkey -M viins '^G' widget::fzf-git-status
    bindkey -M viins '^[g' widget::fzf-git-branch
    bindkey -M viins '^[c' widget::fzf-git-commits

    # Tmux widgets
    bindkey -M viins '^T' widget::tmux-session-manager    # Ctrl+T: Full session manager
    bindkey -M viins '^[^t' widget::fzf-tmux-session      # Ctrl+Alt+T: Quick session switch
    bindkey -M viins '^[t' widget::fzf-tmux-window        # Alt+T: Window selector

    # Yazi widgets
    bindkey -M viins '^[y' widget::yazi-picker
    bindkey -M viins '^Y' widget::yazi-cd

    # Utility widgets
    bindkey -M viins '^[s' widget::fzf-ssh
    bindkey -M viins '^[e' widget::fzf-env
    bindkey -M viins '^X^E' widget::edit-command
    bindkey -M viins '^L' widget::clear-scrollback

    # Clipboard
    bindkey -M viins '^[w' widget::copy-buffer
    bindkey -M viins '^[v' widget::paste-clipboard

    # Bitwarden & Notes
    bindkey -M viins '^[b' widget::bitwarden
    bindkey -M viins '^[j' widget::jump-bookmark
    bindkey -M viins '^[n' widget::quick-note

    # Text manipulation
    bindkey -M viins '^[=' widget::calculator
    bindkey -M viins '^[d' widget::insert-date
    bindkey -M viins '^[T' widget::insert-timestamp

    # History substring search (from plugin)
    bindkey -M viins '^[[A' history-substring-search-up
    bindkey -M viins '^[[B' history-substring-search-down
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down

    # Documentation widgets
    bindkey -M viins '\eh' _doc_help_widget
    # Note: Alt+/ is reserved for main menu, use Alt+? for doc search
    bindkey -M viins '\e?' _doc_search_widget
    bindkey -M viins '\er' _doc_quick_ref_widget
    bindkey -M viins '^X?' doc-menu
    bindkey -M viins '^XH' widget::doc-generate

    # Sudo toggle (double escape)
    bindkey -M viins '\e\e' widget::toggle-sudo
    bindkey -M vicmd '\e\e' widget::toggle-sudo
}

# IMPORTANT: Load vi-mode immediately (not deferred) so zvm_after_init hook works
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode

# Backup approach: Also bind directly after plugin loads
# This ensures bindings work even if hook mechanism fails
bindkey -M viins '\e ' widget::universal-overlay 2>/dev/null
bindkey -M vicmd '\e ' _core_menu_widget 2>/dev/null
bindkey -M viins '\e/' widget::universal-overlay 2>/dev/null
bindkey -M vicmd '\e/' _core_menu_widget 2>/dev/null
bindkey -M viins '\em' _core_menu_widget 2>/dev/null
bindkey -M vicmd '\em' _core_menu_widget 2>/dev/null

#=============================================================================
# HISTORY & DIRECTORY TOOLS
#=============================================================================

# Disabled - using custom widget::fzf-history-search in 03-widgets.zsh instead
# zinit ice wait lucid
# zinit light joshskidmore/zsh-fzf-history-search

zinit ice wait lucid
zinit light zsh-users/zsh-history-substring-search

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

zinit ice wait"1" lucid
zinit light jimhester/per-directory-history

# export AUTO_LS_COMMANDS=(eza)
# zinit ice wait"2" lucid
# zinit light desyncr/auto-ls

zinit ice wait lucid
zinit light hlissner/zsh-autopair

zinit ice wait lucid
zinit light ascii-soup/zsh-url-highlighter

#=============================================================================
# UTILITY PLUGINS
#=============================================================================

zinit ice wait"2" lucid
zinit light ael-code/zsh-colored-man-pages

zinit ice wait"2" lucid
zinit snippet OMZP::extract

zinit ice wait"2" lucid
zinit snippet OMZP::sudo

zinit ice wait"2" lucid
zinit snippet OMZP::git

zinit ice wait"2" lucid
zinit light oz/safe-paste

zinit ice wait"2" lucid
zinit light MichaelAquilina/zsh-you-should-use

zinit ice wait lucid
zinit light direnv/direnv

## TODO: finish integrating these later
#
# zt 0a light-mode for \
#   trigger-load'!ga;!gi;!grh;!grb;!glo;!gd;!gcf;!gco;!gclean;!gss;!gcp;!gcb' \
#   lbin'git-forgit'                   desc'many git commands with fzf' \
#     wfxr/forgit \
#    trigger-load'!ugit' lbin'git-undo' desc'undo various git commands' \
#     Bhupesh-V/ugit \
#   trigger-load'!zhooks'              desc'show code of all zshhooks' \
#     agkozak/zhooks \
#=============================================================================
# BINARY INSTALLS (from GitHub releases)
#=============================================================================

# # starship — special case (ships completions too)
# zinit ice from"gh-r" as"program" pick"starship" lucid wait"0" \
#     atclone"mkdir -p ~/.zsh/completions; starship completions zsh > ~/.zsh/completions/_starship" \
#     atpull"%atclone"
# zinit light starship/starship


# Optional extras (only if you want them)
 # zgh starship/starship      "starship"      "*x86_64-unknown-linux-gnu.tar.gz"
# zgh astral-sh/ruff         "ruff"          "*x86_64-unknown-linux-gnu.tar.gz"
#=============================================================================
# SYNTAX HIGHLIGHTING (load dead last)
#=============================================================================

# Create stub widgets for lazy-loaded modules
# These stubs load the real module on first invocation, then call the real widget
_create_lazy_widget_stubs() {
    local ZSH_CORE="${ZDOTDIR:-$HOME/.core/.sys/cfg/zsh}"

    # Documentation widgets → modules/documentation.zsh
    local -a doc_widgets=(_doc_help_widget _doc_search_widget _doc_quick_ref_widget doc-menu widget::doc-generate)
    for w in "${doc_widgets[@]}"; do
        if ! (( ${+functions[$w]} )); then
            eval "function $w() {
                unfunction $w 2>/dev/null
                source \"$ZSH_CORE/modules/documentation.zsh\"
                if (( \${+functions[$w]} )); then
                    $w \"\$@\"
                fi
            }"
            zle -N $w
        else
            zle -N $w
        fi
    done

    # Main menu widgets → modules/main-menu.zsh
    local -a menu_widgets=(_core_menu_widget _core_menu_fzf_widget _core_menu_git_widget _core_menu_system_widget)
    for w in "${menu_widgets[@]}"; do
        if ! (( ${+functions[$w]} )); then
            eval "function $w() {
                unfunction $w 2>/dev/null
                source \"$ZSH_CORE/modules/main-menu.zsh\"
                if (( \${+functions[$w]} )); then
                    $w \"\$@\"
                fi
            }"
            zle -N $w
        else
            zle -N $w
        fi
    done

    # Widgets-advanced → modules/widgets-advanced.zsh (docker widgets)
    local -a adv_widgets=(widget::docker-container-manager widget::docker-image-manager widget::docker-compose-manager)
    for w in "${adv_widgets[@]}"; do
        if ! (( ${+functions[$w]} )); then
            eval "function $w() {
                unfunction $w 2>/dev/null
                source \"$ZSH_CORE/modules/widgets-advanced.zsh\"
                if (( \${+functions[$w]} )); then
                    $w \"\$@\"
                fi
            }"
            zle -N $w
        else
            zle -N $w
        fi
    done

    # FZF git widgets (if fzf-git-add doesn't exist yet)
    if ! (( ${+functions[fzf-git-add]} )); then
        function fzf-git-add() {
            unfunction fzf-git-add 2>/dev/null
            # This should exist in integrations/git.zsh or similar
            zle reset-prompt
        }
        zle -N fzf-git-add
    else
        zle -N fzf-git-add
    fi
}

_register_custom_widgets_for_highlighting() {
    _create_lazy_widget_stubs
}

zinit ice wait"3" lucid atinit"_register_custom_widgets_for_highlighting" atload'ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)'
zinit light zdharma-continuum/fast-syntax-highlighting
