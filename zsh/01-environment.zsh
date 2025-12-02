# ~/.core/zsh/01-environment.zsh
# Environment variables and PATH configuration - centralizes all exports

# declare -gx ABSD=${${(M)OSTYPE:#*(darwin|bsd)*}:+1}
# declare -gx GENCOMP_DIR="$Zdirs[COMPL]"
# declare -gx GENCOMPL_FPATH="$GENCOMP_DIR"
# declare -gx ZLOGF="${Zdirs[CACHE]}/my-zsh.log"
# declare -gx LFLOGF="${Zdirs[CACHE]}/lf-zsh.log"
#
# typeset -g SAVEHIST=$(( 10 ** 7 ))  # 10_000_000
# typeset -g HISTSIZE=$(( 1.2 * SAVEHIST ))
# typeset -g HISTFILE="${Zdirs[CACHE]}/history"
# typeset -g HIST_STAMPS="yyyy-mm-dd"
# typeset -g HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1 # all search results returned will be unique NOTE: for what
#
# typeset -g DIRSTACKSIZE=20
# typeset -g LISTMAX=50                               # Size of asking history
# typeset -g ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;)'       # Don't eat space with | with tabs
# typeset -g ZLE_SPACE_SUFFIX_CHARS=$'&|'
# typeset -g MAILCHECK=0                 # Don't check for mail
# typeset -g KEYTIMEOUT=25               # Key action time
# typeset -g FCEDIT=$EDITOR              # History editor
# typeset -g READNULLCMD=$PAGER          # Read contents of file with <file
# typeset -g TMPPREFIX="${TMPDIR%/}/zsh" # Temporary file prefix for zsh
# typeset -g PROMPT_EOL_MARK="%F{14}⏎%f" # Show non-newline ending # no_prompt_cr
# # typeset -g REPORTTIME=5 # report about cpu/system/user-time of command if running longer than 5 seconds
# # typeset -g LOGCHECK=0   # interval in between checks for login/logout activity
# typeset -g PERIOD=3600                    # how often to execute $periodic
# function periodic() { builtin rehash; }   # this overrides the $periodic_functions hooks
# watch=(notme)

# ls lse ls@ ls. lsl lsS lsX lsr
# ll lla lls llb llr llsr lle ll.
# lj lp lpo
# lsm lsmr lsmo lsmn
# lsc lscr lsco lscn
# lsb lsbr lsbo lsbn
# lsat lsbt lsa2 lsb2
# lsa lsao lsan
# lst lsts lstx lstl lstr
# lsd lsdl lsdo lsdn lsde lsdf lsd2
# lsz lszr lszb lszs lsz0 lsze
# lss lssa
#

#=============================================================================
# PATH MANAGEMENT (using typeset -U to remove duplicates)
#=============================================================================
typeset -U path PATH
typeset -U fpath FPATH
typeset -U manpath MANPATH

# Add custom function paths
fpath=(
  "$ZSH_CORE/functions"
  "$ZSH_CORE/completions"
  "${XDG_DATA_HOME}/zinit/completions"
  "${XDG_DATA_HOME}/zsh/site-functions"
  $fpath
)

#=============================================================================
# DEFAULT APPLICATIONS
#=============================================================================

export SHELL="/usr/bin/zsh"
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"
export BROWSER="${ROFI_CONFIG}/menus/applets/browser-selector.sh"
export TERMINAL="${TERMINAL:-wezterm}"

# File manager
export FILE_MANAGER="yazi"

export MANOPT=--no-hyphenation
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="nvim -c 'set ft=man' -"
# export MANPAGER="sh -c 'sed -e s/.\\\\x08//g | bat -l man -p'"
export PAGER="less"
export DELTA_PAGER="less $LESS"
export BAT_PAGER="less $LESS"
export LF_PAGER="less ${LESS}"
export AUR_PAGER='lf'
export PERLDOC_PAGER="sh -c 'col -bx | bat -l man -p'"
export PERLDOC_SRC_PAGER="sh -c 'col -bx | bat -l man -p'"
export PERLTIDY="${XDG_CONFIG_HOME}/perltidy/perltidyrc"

# export RTV_EDITOR="${EDITOR}"
export SVN_EDITOR="${EDITOR}"
export SUDO_EDITOR="${EDITOR}"
# export RGV_EDITOR="$EDITOR $file +$line"

export SYSTEMD_EDITOR=${EDITOR}
export SYSTEMD_LESS=${LESS}
if builtin command -v lesspipe.sh >/dev/null 2>&1; then
  export LESSOPEN="|lesspipe.sh %s"
fi

if [[ -n "$NVIM_LISTEN_ADDRESS" ]]; then
  export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
  export VISUAL="nvim"
  export EDITOR="nvim"
fi

# export RTV_EDITOR="${EDITOR}"
export SVN_EDITOR="${EDITOR}"
export SUDO_EDITOR="${EDITOR}"
# export RGV_EDITOR="$EDITOR $file +$line"
export SYSTEMD_EDITOR="${EDITOR}"
export SYSTEMD_COLORS=1
export SYSTEMD_LOG_COLOR=1
export SYSTEMD_LESS=${LESS}
if builtin command -v lesspipe.sh >/dev/null 2>&1; then
  export LESSOPEN="|lesspipe.sh %s"
fi

#=============================================================================
# LANGUAGE AND LOCALE
#=============================================================================
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"

#=============================================================================
# LESS CONFIGURATION
#=============================================================================
export LESS="-R -F -X -i -M -W -x4"
export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
export LESSKEY="${XDG_CONFIG_HOME}/less/lesskey"

# Less colors (for man pages)
export LESS_TERMCAP_mb=$'\e[1;31m'     # Begin blink
export LESS_TERMCAP_md=$'\e[1;36m'     # Begin bold
export LESS_TERMCAP_me=$'\e[0m'        # End mode
export LESS_TERMCAP_se=$'\e[0m'        # End standout
export LESS_TERMCAP_so=$'\e[01;44;33m' # Begin standout
export LESS_TERMCAP_ue=$'\e[0m'        # End underline
export LESS_TERMCAP_us=$'\e[1;32m'     # Begin underline

# [[[ ======= [TOOL CONFIGURATIONS ] ===========================================

# [[[ FZF (basic - extended config in integrations)

# # export FZF_DEFAULT_OPTS="--height 40% --reverse --border"
# export FZF_DEFAULT_OPTS="
#     --height=80%
#     --layout=reverse
#     --border=rounded
#     --info=inline
#     --margin=1
#     --padding=1
#     --prompt='❯ '
#     --pointer='▶'
#     --marker='✓'
#     --header-first
#     --ansi
# "
# # ]]]



# [[[ Ripgrep

export RIPGREP_CONFIG_PATH="${CORE_CFG}/tools/ripgrep/ripgreprc"
export RIPGREP_CACHE_DIR="${XDG_CACHE_HOME}/ripgrep"
export RIPGREP_LOG_FILE="${CORE_LOGS}/core/ripgrep.log"

# ]]]

# [[[ Bat

export BAT_CONFIG_PATH="${CORE_CFG}/tools/bat/config"
export BAT_THEME="${BAT_THEME:-Catppuccin Mocha}"
export BAT_STYLE="${BAT_STYLE:-numbers,changes,header}"

# ]]]

# [[[ Eza

export EZA_COLORS="da=1;34:di=1;34:ex=1;32"
export EZA_ICONS_AUTO=1
export EZA_CONFIG_DIR="${CORE_CFG}/tools/eza"

# ]]]

# [[[ Zoxide

# export _ZO_DATA_DIR="${CORE_CFG}/zoxide"
# export _ZO_ECHO=0
# export _ZO_MAXAGE_DAYS=30
# export _ZO_MAXAGE_HOURS=0
# export _ZO_MAXAGE_MINUTES=0
# export _ZO_MAXAGE_SECONDS=0
# export _ZO_FUZZY=1
# export _ZO_CASE_SENSITIVE=0
# export _ZO_MATCH_MODE="fuzzy"
# export _ZO_LIST_STYLE="full"
# export _ZO_PROMPT_STYLE="full"
# export _ZO_COMPLETION_STYLE="full"
# export _ZO_ALIASES=1
# ]]]

# [[[ Yazi (Yet Another Zsh Interface) - File Manager

export YAZI_CONFIG_HOME="${CORE_CFG}/yazi"
export YAZI_DATA_HOME="${XDG_DATA_HOME}/yazi"
export YAZI_CACHE_HOME="${XDG_CACHE_HOME}/yazi"

# ]]]

# Starship (if used)
export STARSHIP_CONFIG="${CORE_CFG}/starship/starship.toml"
export STARSHIP_CACHE="${XDG_CACHE_HOME}/starship"

# ]]] =========================================================================

# [[[ ================== [TMUX] ENVIRONMENT VARIABLES=======================

# [[[ TMUX GENERAL PATHS
export TMUX_CONF="${CORE_CFG}/tmux/tmux.conf"
export TMUX_CACHE_DIR="${XDG_CACHE_HOME}/tmux"
export TMUX_LOGS="${CORE_LOGS}/core/tmux"
export TMUX_TMPDIR="${XDG_RUNTIME_DIR:-/tmp}"
# ]]]

# [[[ TMUX PLUGIN PATHS
export TMUX_PLUGIN_MANAGER_PATH="${TMUX_CONF}/plugins"
export TMUX_TPM="${TMUX_CONF}/plugins"
export TMUX_RESURRECT="${TMUX_CONF}/resurrect"
# ]]]

# [[[ TMUX CORE CFG PATHS

export TMUX_CONF_FILES="${TMUX_CONF}/conf"
export TMUX_BINDS="${TMUX_CONF}/keymaps"
export TMUX_WORKSPACES="${TMUX_CONF}/workspaces"

# ]]]

# [[[ TMUX MODULES ==================================================

export TMUX_MODULES="${TMUX_CONF}/modules"
export TMUX_MENUS="${TMUX_MODULES}/menus"

# ]]]

# [[[ TMUXINATOR CONFIGURATION

export TMUXINATOR_CONFIG_DIR="${TMUX_CONF}/tools/tmuxinator"
export TMUXINATOR_PROJECTS_DIR="${TMUXINATOR_CONFIG_DIR}/projects"

# ]]]

# ]]] =========================================================================

# [[[ ================= [NVIM] ENVIRONMENT VARIABLES=======================

export NVIM_APPNAME="${NVIM_APPNAME:-nvim}"
export NVIM_LOG_FILE="${CORE_LOGS}/core/nvim.log"
export NVIM_CONFIG_DIR="${CORE_CFG}/nvim"
export NVIM_DATA_DIR="${XDG_DATA_HOME}/nvim"
export NVIM_CACHE_DIR="${XDG_CACHE_HOME}/nvim"
export NVIM_STATE_DIR="${XDG_STATE_HOME}/nvim"
# export NVIM_PLUGINS_DIR="${NVIM_DATA_DIR}/site/pack/packer/start"

# ]]] =========================================================================

# [[[ ================= [WEZTERM] ENVIRONMENT VARIABLES=======================

export WEZTERM_CONFIG_FILE="${CORE_CFG}/wezterm/wezterm.lua"
export WEZTERM_CONFIG_DIR="${CORE_CFG}/wezterm"
export WEZTERM_CONFIG_FILE="${WEZTERM_CONFIG_DIR}/wezterm.lua"
export WEZTERM_SESSIONS_DIR="${WEZTERM_CONFIG_DIR}/sessions"
export WEZTERM_UTILS="${WEZTERM_CONFIG_DIR}/utils"
export WEZTERM_PLUGIN_DIR="${WEZTERM_CONFIG_DIR}/plugins"
export WEZTERM_THEMES="${WEZTERM_CONFIG_DIR}/themes"
export WEZTERM_SESSION_THEMES="${WEZTERM_THEMES}/sessions"
export WEZTERM_LOCAL_SESSIONS="${WEZTERM_SESSIONS_DIR}/local"
export WEZTERM_SSH_SESSIONS="${WEZTERM_SESSIONS_DIR}/ssh"
export WEZTERM_DOCKER_SESSIONS="${WEZTERM_SESSIONS_DIR}/docker"
export WEZTERM_LOG_FILE="${CORE_LOGS}/wezterm.log"
export WEZTERM_DATA="${WEZTERM_DATA:-$CORE_CFG/wezterm/data}"

# ]]] =========================================================================

# [[[ ================= [ANSIBLE] ENVIRONMENT VARIABLES=======================

export ANSIBLE_HOME="${CORE_CFG}/ansible"
export ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg"
export ANSIBLE_GALAXY_CACHE_DIR="${XDG_CACHE_HOME}/ansible/galaxy_cache"
export ANSIBLE_LOCAL_TEMP="${XDG_CACHE_HOME}/ansible/tmp"
export ANSIBLE_PERSISTENT_CONTROL_PATH_DIR="${XDG_CACHE_HOME}/ansible/pc"

# ]]] =========================================================================

# [[[ ================= [SECURITY TOOLS] ENVIRONMENT VARIABLES================

# [[[ ================= [PASSWORD MANAGERS] ENVIRONMENT VARIABLES================

# [[[ PASS CLI ENVIRONMENT VARIABLES

# ]]] =========================================================================

# [[[ ================ [BITWARDEN CLI] ENVIRONMENT VARIABLES================

export BITWARDENCLI_APPDATA_DIR="${XDG_DATA_HOME}/bitwarden-cli"
# export BW_SESSION="" # Populated by unlock function

# ]]] =========================================================================

export TUI_1PASSWORD_HOME="${CORE_CFG}/1password-tui"
#=============================================================================
# DEVELOPMENT FLAGS
#=============================================================================
# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Docker
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export DOCKER_BUILDKIT=1

# Kubernetes
# export KUBECONFIG="${XDG_CONFIG_HOME}/kube/config"

#=============================================================================
# WAYLAND SPECIFIC (for Hyprland)
#=============================================================================
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
  export MOZ_ENABLE_WAYLAND=1
  export QT_QPA_PLATFORM="wayland;xcb"
  export SDL_VIDEODRIVER="wayland"
  export _JAVA_AWT_WM_NONREPARENTING=1
  export CLUTTER_BACKEND="wayland"
  export GDK_BACKEND="wayland,x11"
fi

#=============================================================================
# TOOL-SPECIFIC CONFIGURATION PATHS
#=============================================================================
# Zinit
export ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"

# [[[ CORE Tools ENVIRONMENT VARIABLES CONFIGURATION

export CORE_TOOLS="${CORE_SYS}/tools"
validate_dir "$CORE_TOOLS"

# export POETRY_VENV_IN_PROJECT=1
# export POETRY_VIRTUALENVS_CREATE=1
# export POETRY_VIRTUALENVS_IN_PROJECT=1
# export POETRY_INSTALL_DEPENDENCIES=1

export BUN_INSTALL="${CORE_TOOLS}/bun"
export BUN_BIN="$BUN_INSTALL/bin"

validate_dir "$BUN_INSTALL/bin"

export DENO_INSTALL="${CORE_TOOLS}/deno"
export DENO_BIN="$DENO_INSTALL/bin"

validate_dir "$DENO_INSTALL/bin"

# ]]]

# ──────────────────────────────────────────────────────────────
# Perl – fully relocated
# ──────────────────────────────────────────────────────────────
export PERL_HOME="${CORE_TOOLS}/perl"
export PERL_LOCAL_LIB_ROOT="${PERL_HOME}/local"
export PERL_MB_OPT="--install_base ${PERL_HOME}/local"
export PERL_MM_OPT="INSTALL_BASE=${PERL_HOME}/local"

# cpanm settings (cpanminus)
export PERL_CPANM_HOME="${PERL_HOME}/cpanm"
export PERL_CPANM_OPT="--local-lib=${PERL_HOME}/local"

validate_dir "$PERL_HOME/local/bin"
validate_dir "$PERL_CPANM_HOME"

# [[[  NVM ──────────────────────────────────────────────────────────────
# ──────────────────────────────────────────────────────────────
# NVM – Node Version Manager
# ──────────────────────────────────────────────────────────────
export NVM_DIR="${CORE_TOOLS}/nvm"
validate_dir "$NVM_DIR/nodes"
validate_dir "$NVM_DIR/versions"
ln -sfn "$NVM_DIR/nodes" "$NVM_DIR/versions/node" 2>/dev/null || true

[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"                   # loads nvm + PATH
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion" # works in zsh too

# ]]] ──────────────────────────────────────────────────────────────

# [[[ RUST  ──────────────────────────────────────────────────────────────

export RUSTUP_HOME="${CORE_TOOLS}/rust/rustup"
export CARGO_HOME="${CORE_TOOLS}/rust/cargo"
validate_dir "$RUSTUP_HOME" "$CARGO_HOME/bin"
export PATH="${CARGO_HOME}/bin:${PATH}"

# ]]] ──────────────────────────────────────────────────────────────

# [[[ GO  ──────────────────────────────────────────────────────────────

export GOPATH="${CORE_TOOLS}/go"
export GOBIN="${GOPATH}/bin"
validate_dir "$GOBIN"
export PATH="${GOBIN}:${PATH}"

# ]]] ──────────────────────────────────────────────────────────────

# [[[ BUN  ──────────────────────────────────────────────────────────────
export BUN_INSTALL="${CORE_TOOLS}/bun"
validate_dir "$BUN_INSTALL/bin"
export PATH="${BUN_INSTALL}/bin:${PATH}"

# ]]] ──────────────────────────────────────────────────────────────

# [[[ DENO  ──────────────────────────────────────────────────────────────

export DENO_INSTALL="${CORE_TOOLS}/deno"
validate_dir "$DENO_INSTALL/bin"
export PATH="${DENO_INSTALL}/bin:${PATH}"

# ]]] ──────────────────────────────────────────────────────────────

# [[[ PNPM ──────────────────────────────────────────────────────────────

export PNPM_HOME="${CORE_TOOLS}/pnpm"
validate_dir "$PNPM_HOME"
export PATH="${PNPM_HOME}/bin:${PATH}"

# ]]] ──────────────────────────────────────────────────────────────

# [[[ YARN ──────────────────────────────────────────────────────────────

yarn_global="${CORE_TOOLS}/yarn/global"
yarn_cache="${XDG_CACHE_HOME:-${HOME}/.cache}/yarn"
validate_dir "$yarn_global/.bin" "$yarn_cache"
yarn config set globalFolder "$yarn_global" --home >/dev/null 2>&1
yarn config set cacheFolder "$yarn_cache" --home >/dev/null 2>&1
export PATH="${yarn_global}/.bin:${PATH}"

# ]]] ──────────────────────────────────────────────────────────────

# [[[ NPM global prefix─────────────────────────────────────────────────────────────

export NPM_PREFIX="${CORE_TOOLS}/npm"
validate_dir "$NPM_PREFIX/bin"
npm config set prefix "$NPM_PREFIX" >/dev/null 2>&1
export PATH="${NPM_PREFIX}/bin:${PATH}"

# ]]] ─────────────────────────────────────────────────────────────

# [[[ Python ──────────────────────────────────────────────────────────────
#
# export CORE_PYTHON="${CORE_TOOLS}/python"

# export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}/jupyter"
export PYTHON_HOME="${CORE_TOOLS}/python"
# export VIRTUAL_ENV_DISABLE_PROMPT=1
# export PYENV_ROOT="${PYTHON_HOME}/pyenv"
#
# export PIPX_HOME="${PYTHON_HOME}/python/pipx"
# export PIPX_BIN_DIR="${PYTHON_HOME}/bin"
# export IPYTHONDIR="${XDG_CACHE_HOME}/ipython"
# export MYPY_CACHE_DIR="${XDG_CACHE_HOME}/mypy"
validate_dir "$PIPX_HOME" "$PIPX_BIN_DIR" "$PYENV_ROOT"

export PYTHON_HOME="${CORE_TOOLS}/python"
# pipx
export PIPX_HOME="${PYTHON_HOME}/pipx/venvs"
export PIPX_BIN_DIR="${PYTHON_HOME}/pipx/bin"

# pyenv
export PYENV_ROOT="${PYTHON_HOME}/pyenv"
validate_dir "$PYENV_ROOT"
command -v pyenv >/dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)" 2>/dev/null || true

# Poetry (optional but clean)
export POETRY_HOME="${PYTHON_HOME}/poetry"
export POETRY_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/pypoetry"
export POETRY_VIRTUALENVS_PATH="${PYTHON_HOME}/poetry/venvs"
validate_dir "$POETRY_HOME/bin" "$POETRY_VIRTUALENVS_PATH" "$POETRY_CACHE_DIR"

# Standard Python cleanliness
export PYTHONPYCACHEPREFIX="${XDG_CACHE_HOME:-${HOME}/.cache}/python"
export PYTHON_HISTORY="${XDG_STATE_HOME:-${HOME}/.local/state}/python/history"
export VIRTUAL_ENV_DISABLE_PROMPT=1

validate_dir "$PIPX_HOME" "$PIPX_BIN_DIR" "$PYENV_ROOT" "$POETRY_HOME/bin"

# ]]] ──────────────────────────────────────────────────────────────

# [[[ ZIG ────────────────────────────────────────────────────────────
# Zig
export ZIG_HOME="${CORE_TOOLS}/zig"
export ZIG_BIN="${ZIG_HOME}/bin"

validate_dir "$ZIG_HOME/bin"
export PATH="${ZIG_BIN}:${PATH}"
# ]]] ─────────────────────────────────────────────────────────────

# [[[ Ruby – rbenv────────────────────────────────────────────────────────────

export RBENV_ROOT="${CORE_TOOLS}/ruby/rbenv"
validate_dir "$RBENV_ROOT"
export PATH="${RBENV_ROOT}/bin:${PATH}"
command -v rbenv >/dev/null && eval "$(rbenv init - zsh)"

# ]]] ──────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────
# Lua + LuaRocks
# ──────────────────────────────────────────────────────────────
export LUA_HOME="${CORE_TOOLS}/lua"
export LUAROCKS_HOME="${LUA_HOME}/luarocks"

# LuaRocks 3.x+ respects these variables
export LUAROCKS_CONFIG="${XDG_CONFIG_HOME}/luarocks/config.lua" # optional config
validate_dir "$LUAROCKS_HOME/bin" "$LUAROCKS_HOME/lib/luarocks/rocks"

# Tell luarocks where to install everything
export LUAROCKS_PREFIX="$LUAROCKS_HOME"
export LUAROCKS_TREE="$LUAROCKS_HOME"

# [[[ PATH────────────────────────────────────────────────────────────
typeset -U path cdpath fpath manpath # remove duplicates globally

path=(
  "$HOME/.local/bin"
  "${CORE_TOOLS}/bin"
  "${CARGO_HOME}/bin"
  "${GOBIN}"
  "${BUN_INSTALL}/bin"
  "${DENO_INSTALL}/bin"
  "${PNPM_HOME}"
  "${yarn_global}/.bin"
  "${NPM_PREFIX}/bin"
  "${PIPX_BIN_DIR}"
  "${POETRY_HOME}/bin"
  "${CORE_TOOLS}/zig"
  "${PYENV_ROOT}/bin"
  "${RBENV_ROOT}/bin"
  "${LUAROCKS_HOME}/bin"
  "${PERL_HOME}/local/bin"
  $path
)

# ]]] PATH END ────────────────────────────────────────────────────────

# Cargo sometimes ships its own env file
[[ -f "${CARGO_HOME}/env" ]] && source "${CARGO_HOME}/env"

# [[[ Default TOOL CONFIGURATION FILES CREATION - silent, safe, idempotent
#
# # export CARGO_HOME="${XDG_DATA_HOME}/cargo"
# # export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
# export LUAROCKS_CONFIG="${XDG_CONFIG_HOME}/luarocks/config.lua"
# export GOPATH="${HOME}/go"
# export GOROOT="/usr/lib/go" # Standard location on Arch/CachyOS
# export GOPROXY="https://proxy.golang.org,direct"
# export GOSUMDB="sum.golang.org"
# # export GOENV_ROOT="${XDG_DATA_HOME}/goenv"
# #export GEM_PATH="${XDG_DATA_HOME}/ruby/gems"
#
# if command -v ruby &>/dev/null; then
#   export GEM_PATH="$(ruby -e 'puts Gem.user_dir')"
#   export GEM_HOME="$GEM_PATH"
#   export GEM_SPEC_CACHE="${XDG_DATA_HOME}/ruby/specs"
# fi
#
# export RBENV_ROOT="${XDG_DATA_HOME}/rbenv"
# export SOLARGRAPH_CACHE="${XDG_CACHE_HOME}/solargraph"
#
# export BUN_INSTALL="${XDG_CONFIG_HOME}/bun"
# export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"
# export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
# export NPM_PACKAGES="${XDG_DATA_HOME}/npm-packages"
# export NPM_DIR="${HOME}/.npm-global"
# export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"
# export PNPM_DIR="${HOME}/.pnpm-global"
# export NVM_DIR="${HOME}/.nvm"
# export YARNBIN="${XDG_DATA_HOME}/yarn/install/bin"
# export YARNGLOBAL="${HOME}/.config/yarn/global/node_modules/.bin"
# ]]]

# vim: ft=zsh:et:sw=0:ts=2:sts=2:fdm=marker:fmr=[[[,]]]



# Various highlights for CLI
typeset -ga zle_highlight=(
  # region:fg="#a89983",bg="#4c96a8"
  # paste:standout
  region:standout
  special:standout
  suffix:bold
  isearch:underline
  paste:none
)

() {
  # local i; i=${(@j::):-%\({1..36}"e,$( echoti cuf 2 ),)"}
  # typeset -g PS4=$'%(?,,\t\t-> %F{9}%?%f\n)'
  # PS4+=$'%2<< %{\e[2m%}%e%22<<             %F{10}%N%<<%f %3<<  %I%<<%b %(1_,%F{11}%_%f ,)'

  declare -g SPROMPT="Correct '%F{17}%B%R%f%b' to '%F{20}%B%r%f%b'? [%F{18}%Bnyae%f%b] : "  # Spelling correction prompt
  declare -g PS2="%F{1}%B>%f%b "  # Secondary prompt
  declare -g RPS2="%F{14}%i:%_%f" # Right-hand side of secondary prompt

  autoload -Uz colors; colors
  local red=$fg_bold[red] blue=$fg[blue] rst=$reset_color
  declare -g TIMEFMT=(
    "$red%J$rst"$'\n'
    "User: $blue%U$rst"$'\t'"System: $blue%S$rst  Total: $blue%*Es$rst"$'\n'
    "CPU:  $blue%P$rst"$'\t'"Mem:    $blue%M MB$rst"
  )
}

# === Custom zsh variables =============================================== [[[
# TODO: use these arrays
declare -gxA Plugs

declare -gAH Zkeymaps_n=()
declare -gAH Zkeymaps_v=()
declare -gAH Zkeymaps_o=()
declare -gAH Zkeymaps_i=()
declare -gAH Zkeymaps_nvo=()

# === Non-zsh variables that are used later ============================== [[[
typeset -gx RUST_SYSROOT=$(rustc --print sysroot)
typeset -gx RUST_SRC_PATH=$RUST_SYSROOT/lib/rustlib/src
typeset -gx RUSTDOC_DIR=$XDG_DOCUMENTS_DIR/code/rust/docs
# typeset -gx RUSTDOCFLAGS=""
# ]]]

[[ ${(t)sysexits} != *readonly ]] &&
  readonly -ga sysexits=(
    {1..63}
    # sysexits(3)
    EX_USAGE        # "[64] Command used incorrectly"
    EX_DATAERR      # "[65] Input data was incorrect in some way"
    EX_NOINPUT      # "[66] Input file not readable/doesn't exist"
    EX_NOUSER       # "[67] User specified doesn't exist"
    EX_NOHOST       # "[68] Host specified doesn't exist"
    EX_UNAVAILABLE  # "[69] Service is unavailable"
    EX_SOFTWARE     # "[70] Internal software error"
    EX_OSERR        # "[71] Operating system error"
    EX_OSFILE       # "[72] System file doesn't exist"
    EX_CANTCREAT    # "[73] User specified output file cannot be created"
    EX_IOERR        # "[74] An I/O error occured"
    EX_TEMPFAIL     # "[75] Temporary failure, meaning not really an error"
    EX_PROTOCOL     # "[76] Remote system had an issue during a protocol exchange"
    EX_NOPERM       # "[77] Didn't have sufficient permissions for operation"
    EX_CONFIG       # "[78] Unconfigured / misconfigured state"
  )
