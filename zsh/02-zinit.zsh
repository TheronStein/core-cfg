# ~/.core/zsh/02-zinit.zsh
# Zinit plugin manager configuration – 2025 elite edition
#=============================================================================

# ~/.core/zsh/02-zinit.zsh — top of file

# =============================================================================
# ZINIT BOOTSTRAP + SSH CONFIG (MUST BE FIRST!)
# =============================================================================

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

# Force SSH for ALL GitHub clones — eliminates auth prompts forever
zstyle ':zinit:cloneopts' --git-protocol ssh
zstyle ':zinit:cloneopts' --all ssh

# Optional: fallback to HTTPS with token if you ever need it
# export GITHUB_TOKEN="ghp_…"

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
zinit ice depth=1
zinit light romkatv/powerlevel10k
[[ -f "${XDG_CONFIG_HOME}/p10k/p10k.zsh" ]] && source "${XDG_CONFIG_HOME}/p10k/p10k.zsh"

#=============================================================================
# ESSENTIAL PLUGINS (immediate)
#=============================================================================
zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline"


#=============================================================================
# COMPLETIONS + FZF-TAB (turbo + Nix-safe)
#=============================================================================
# Load fzf-tab preview functions first (must be available before fzf-tab uses them)                                                                     
source "$HOME/.core/.sys/cfg/zsh/functions/widgets/fzf-preview"                                                                                              
source "${CORE_CFG}/zsh/integrations/fzf.zsh"                                 
# Core zsh completions
zinit wait lucid for blockf zsh-users/zsh-completions
zinit ice wait lucid as"program"; zinit light marlonrichert/zsh-autocomplete
# zman — your beautiful man page browser (pure function)
# =============================================================================
# CONDITIONAL COMPLETION LOADER — only loads if binary exists (Nix-safe)
# =============================================================================
zinit_load_if_exists() {
  local cmd="$1" plugin="$2" ice_extra="${3:-}"
  command -v "$cmd" &>/dev/null && zinit ice wait"2" lucid blockf ${ice_extra} && zinit load "$plugin"
}

# =============================================================================
# PLUGIN LOADING (from 02-zinit.zsh)
# =============================================================================
zinit_load_if_exists fzf            junegunn/fzf
zinit_load_if_exists fzf-tab        Aloxaf/fzf-tab
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

# Use it to conditionally load Nix plugins
case "$(get_distro)" in
  nixos|arch|fedora|debian|ubuntu|void|alpine|wsl)
    # These are the distros where you might have Nix installed
    zinit_load_if_exists nix nix-community/nix-zsh-completions
    (( $+commands[nix] )) && zinit ice wait lucid; zinit light chisui/zsh-nix-shell
    ;;
  *)
    # Skip on macOS, Windows, or unknown
    ;;
esac

zinit ice wait lucid; zinit light jeffreytse/zsh-vi-mode
#=============================================================================
# HISTORY & DIRECTORY TOOLS
#=============================================================================

zinit ice wait lucid; zinit light joshskidmore/zsh-fzf-history-search

zinit ice wait lucid; zinit light zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

zinit ice wait"1" lucid; zinit light jimhester/per-directory-history

export AUTO_LS_COMMANDS=(ls)
zinit ice wait"2" lucid; zinit light desyncr/auto-ls
zinit ice wait lucid; zinit light hlissner/zsh-autopair
zinit ice wait lucid; zinit light ascii-soup/zsh-url-highlighter

#=============================================================================
# UTILITY PLUGINS
#=============================================================================
zinit ice wait"2" lucid; zinit light ael-code/zsh-colored-man-pages
zinit ice wait"2" lucid; zinit snippet OMZP::extract
zinit ice wait"2" lucid; zinit snippet OMZP::sudo
zinit ice wait"2" lucid; zinit snippet OMZP::git
zinit ice wait"2" lucid; zinit light oz/safe-paste
zinit ice wait"2" lucid; zinit light MichaelAquilina/zsh-you-should-use
zinit ice wait lucid; zinit light direnv/direnv
#=============================================================================
# BINARY INSTALLS (from GitHub releases)
#=============================================================================
# Universal binary installer + smart completion extractor
zbin() {
  local repo="$1" bin="${2:-${1##*/}}" ver="${3:-latest}"

  # Skip zoxide — it generates its own completion at runtime
  [[ "$repo" == "ajeetdsouza/zoxide" ]] && {
    zinit ice from"gh-r" as"program" \
        ver"$ver" mv"zoxide* -> zoxide" pick"zoxide" sbin"**/zoxide" \
        atclone"./zoxide init zsh > init.zsh" atpull"%atclone" src"init.zsh" \
        lucid wait"0"
    zinit light "$repo"
    return
  }

  # All other tools: Yazi-style + smart completion extraction
  zinit ice from"gh-r" as"program" \
      ver"$ver" \
      mv"$bin* -> $bin" pick"$bin" sbin"**/$bin" \
      atclone'cp **/(_|'${bin}')(.N) ~/.zsh/completions/_'$bin' 2>/dev/null || true' \
      atpull'%atclone' \
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

# # starship — special case (ships completions too)
# zinit ice from"gh-r" as"program" pick"starship" lucid wait"0" \
#     atclone"mkdir -p ~/.zsh/completions; starship completions zsh > ~/.zsh/completions/_starship" \
#     atpull"%atclone"
# zinit light starship/starship

# TMUX — latest master + Ctrl-I patch + TPM
zinit ice from"gh-r" as"program" \
    mv"tmux* -> tmux" pick"tmux" sbin"tmux" \
    atclone'curl -fsSL https://patch-diff.githubusercontent.com/raw/tmux/tmux/pull/3734.patch | patch -p1' \
    atpull'%atclone' lucid wait"0"
zinit light tmux/tmux

zinit ice lucid wait"0"
zinit light tmux-plugins/tpm

[[ ! -d "${SYS_TMUX}" ]] && \
  mkdir -p "${CORE_CFG}/tmux/plugins"

# Auto-install TPM on first use
[[ ! -d "${SYS_TMUX}/plugins/tpm" ]] && \
  git clone https://github.com/tmux-plugins/tpm ${SYS_TMUX}/plugins/tpm

# Optional extras (only if you want them)
 # zgh starship/starship      "starship"      "*x86_64-unknown-linux-gnu.tar.gz"
# zgh astral-sh/ruff         "ruff"          "*x86_64-unknown-linux-gnu.tar.gz"
#=============================================================================
# SYNTAX HIGHLIGHTING (load dead last)
#=============================================================================
_register_custom_widgets_for_highlighting() {
    local -a w=( widget::doc-generate doc-menu fzf-git-add _doc_quick_ref_widget _doc_search_widget _doc_help_widget )
    for w in $w; do (( ${+functions[$w]} )) && zle -N $w; done
}

zinit ice wait"3" lucid atinit"_register_custom_widgets_for_highlighting" atload'ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)'
zinit light zdharma-continuum/fast-syntax-highlighting
