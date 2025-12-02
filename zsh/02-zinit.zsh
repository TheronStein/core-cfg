# ~/.core/zsh/02-zinit.zsh
# Zinit plugin manager configuration - efficient plugin loading with turbo mode
#
# ### ZINIT — ELITE EDITION #####################################################
#
# ZINIT[HOME_DIR]="${XDG_DATA_HOME}/zinit/zinit.git"
# ZINIT[BIN_DIR]="${ZINIT[HOME_DIR]}/bin"
#
# # Install zinit if missing
# [[ ! -d "$ZINIT[BIN_DIR]" ]] && {
#   print -P "%F{33}Installing zinit…%f"
#   command mkdir -p "$ZINIT[HOME_DIR]" && command chmod g-rwX "$ZINIT[HOME_DIR]"
#   git clone --depth 1 https://github.com/zdharma-continues/zinit.git "$ZINIT[BIN_DIR]"
# }
#
# source "${ZINIT[BIN_DIR]}/zinit.zsh"
# autoload -Uz _zinit
# (( ${+_comps} )) && _comps[zinit]=_zinit

#=============================================================================
# ZINIT BOOTSTRAP
#=============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

# Auto-install Zinit if not present (suppress output during instant prompt)
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    if (( ${+__p9k_instant_prompt_active} )); then
        # Defer installation until after instant prompt
        {
            print -P "%F{33}Installing Zinit...%f"
            command mkdir -p "${ZINIT_HOME:h}"
            command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
                print -P "%F{34}Zinit installed successfully%f" || \
                print -P "%F{160}Zinit installation failed%f"
        } &!
    else
        print -P "%F{33}Installing Zinit...%f"
        command mkdir -p "${ZINIT_HOME:h}"
        command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
            print -P "%F{34}Zinit installed successfully%f" || \
            print -P "%F{160}Zinit installation failed%f"
    fi
fi

# Load Zinit
[[ -f "${ZINIT_HOME}/zinit.zsh" ]] && source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

#=============================================================================
# ZINIT ANNEXES (extend functionality)
#=============================================================================
# These must be loaded before plugins
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

#=============================================================================
# PROMPT (loaded first for instant prompt)
#=============================================================================
# Option 1: Powerlevel10k (feature-rich, customizable)
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Load p10k configuration
[[ -f "${XDG_CONFIG_HOME}/p10k/p10k.zsh" ]] && source "${XDG_CONFIG_HOME}/p10k/p10k.zsh"

# Option 2: Starship (uncomment to use instead)
# zinit ice as"command" from"gh-r" \
#     atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
#     atpull"%atclone" src"init.zsh"
# zinit light starship/starship

#=============================================================================
# ESSENTIAL PLUGINS (loaded immediately)
#=============================================================================
# Autosuggestions
zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# Configure autosuggestions
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline"

#=============================================================================
# COMPLETIONS (turbo loaded)
#=============================================================================
# Load fzf-tab preview functions first (must be available before fzf-tab uses them)
source "$HOME/.core/.sys/cfg/zsh/functions/fzf-preview.sh"

# Get dynamic theme colors from wezterm
_fzf_tab_colors=$("$HOME/.core/.sys/cfg/wezterm/scripts/theme-browser/get-current-fzf-colors.zsh" 2>/dev/null || echo "bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,border:#89b4fa,label:#89b4fa,query:#cdd6f4")

# Configure fzf-tab behavior (before loading plugin)
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags --height=80% --reverse --border=rounded --border-label-pos=3 --prompt="❯ " --pointer="▶" --marker="✓" --color="$_fzf_tab_colors" --bind="ctrl-/:toggle-preview"
zstyle ':fzf-tab:*' fzf-preview-window 'right:60%:wrap:rounded'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' continuous-trigger '/'

# fzf-tab: Replace zsh's default completion menu with fzf
zinit ice wait lucid
zinit light Aloxaf/fzf-tab

# Note: compinit is called in 00-options.zsh, so we don't need zicompinit here
zinit wait lucid for \
    blockf \
        zsh-users/zsh-completions

# Additional completions (with longer wait to avoid instant prompt issues)
zinit ice wait"2" lucid as"completion"
zinit snippet https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker

zinit ice wait"2" lucid as"completion"
zinit snippet https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose

#=============================================================================
# HISTORY TOOLS
#=============================================================================
# History substring search
zinit ice wait lucid
zinit light zsh-users/zsh-history-substring-search

# Bind up/down arrows
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Per-directory history
zinit ice wait"1" lucid
zinit light jimhester/per-directory-history
# Toggle with Ctrl-G

#=============================================================================
# DIRECTORY TOOLS
#=============================================================================
# Auto-ls on cd (using eza)
# Configure to only run ls, NOT git-status (too spammy)
export AUTO_LS_COMMANDS=(ls)
zinit ice wait"2" lucid
zinit light desyncr/auto-ls

# Zsh autopair (auto-close brackets, quotes)
zinit ice wait lucid
zinit light hlissner/zsh-autopair

# URL highlighter
zinit ice wait lucid
zinit light ascii-soup/zsh-url-highlighter

#=============================================================================
# UTILITY PLUGINS
#=============================================================================
# You-should-use (remind about aliases) - DISABLED: too spammy
# zinit ice wait"2" lucid
# zinit light MichaelAquilina/zsh-you-should-use
# export YSU_MESSAGE_POSITION="after"
# export YSU_MODE=ALL

# Colored man pages
zinit ice wait"2" lucid
zinit light ael-code/zsh-colored-man-pages

# Extract (universal archive extractor)
zinit ice wait"2" lucid
zinit snippet OMZP::extract

# Sudo (double-esc to add sudo)
zinit ice wait"2" lucid
zinit snippet OMZP::sudo

# Git utilities
zinit ice wait"2" lucid
zinit snippet OMZP::git

# Safe paste (prevent execution on paste)
zinit ice wait"2" lucid
zinit light oz/safe-paste

#=============================================================================
# BINARY INSTALLS (from GitHub releases)
#=============================================================================


# Zoxide
zinit ice from"gh-r" as"program" \
    mv"zoxide* -> zoxide" \
    atclone"./zoxide init zsh > init.zsh" \
    atpull"%atclone" src"init.zsh" nocompile'!'
zinit light ajeetdsouza/zoxide

# Eza (modern ls)
zinit ice from"gh-r" as"program" mv"eza* -> eza"
zinit light eza-community/eza

# Bat (cat replacement)
zinit ice from"gh-r" as"program" mv"bat*/bat -> bat" \
    atclone"bat cache --build" atpull"%atclone"
zinit light sharkdp/bat

# Fd (find replacement)
zinit ice from"gh-r" as"program" mv"fd*/fd -> fd"
zinit light sharkdp/fd

# Ripgrep
zinit ice from"gh-r" as"program" mv"ripgrep*/rg -> rg"
zinit light BurntSushi/ripgrep

# Delta (git diff viewer)
zinit ice from"gh-r" as"program" mv"delta*/delta -> delta"
zinit light dandavison/delta

# Dust (disk usage)
zinit ice from"gh-r" as"program" mv"dust*/dust -> dust"
zinit light bootandy/dust

# Procs (ps replacement)
zinit ice from"gh-r" as"program"
zinit light dalance/procs

# Bottom (htop replacement)
zinit ice from"gh-r" as"program"
zinit light ClementTsang/bottom

# Yazi (file manager)
zinit ice from"gh-r" as"program" bpick"*x86_64-unknown-linux-gnu.zip" ver"nightly" mv"yazi* -> yazi" pick"yazi" lucid wait"0" sbin"**/yazi"
zinit light sxyazi/yazi

#=============================================================================





#=============================================================================
# LAZY-LOADED COMPLETIONS
#=============================================================================
# These are loaded on first use to speed up shell startup

# kubectl completion (loaded when first used)
function kubectl() {
    unfunction kubectl
    if command -v kubectl &>/dev/null; then
        source <(command kubectl completion zsh)
    fi
    command kubectl "$@"
}

# helm completion
function helm() {
    unfunction helm
    if command -v helm &>/dev/null; then
        source <(command helm completion zsh)
    fi
    command helm "$@"
}

# gh (GitHub CLI) completion
function gh() {
    unfunction gh
    if command -v gh &>/dev/null; then
        source <(command gh completion -s zsh)
    fi
    command gh "$@"
}

#=============================================================================
# SYNTAX HIGHLIGHTING (load LAST after all widgets are defined)
#=============================================================================
# This must be loaded after all custom widgets to avoid "unhandled ZLE widget" warnings

# Pre-register all custom widgets before loading syntax highlighting
_register_custom_widgets_for_highlighting() {
    # Register all custom widget patterns
    local -a custom_widgets=(
        widget::doc-generate
        doc-menu
        fzf-git-add
        _doc_quick_ref_widget
        _doc_search_widget
        _doc_help_widget
    )

    for widget in $custom_widgets; do
        if (( ${+functions[$widget]} )) && ! zle -l | grep -q "^${widget}$"; then
            zle -N $widget
        fi
    done

    # Export for zsh-syntax-highlighting
    export ZSH_HIGHLIGHT_WIDGETS=($custom_widgets)
}

# Configure and load syntax highlighting with widget awareness
zinit ice wait"3" lucid \
    atinit"_register_custom_widgets_for_highlighting; ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)" \
    atload"[[ -n \${ZSH_HIGHLIGHT_WIDGETS} ]] && typeset -ga ZSH_HIGHLIGHT_WIDGETS"
zinit light zdharma-continuum/fast-syntax-highlighting
