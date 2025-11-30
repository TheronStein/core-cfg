# ~/.core/zsh/local.zsh
# Local Configuration - Machine-specific settings (not tracked in git)
# Copy this template and customize for each machine

#=============================================================================
# MACHINE IDENTIFICATION
#=============================================================================
# Uncomment and set for machine-specific logic
# export MACHINE_TYPE="laptop"    # laptop, desktop, server, vm
# export MACHINE_NAME="$(hostname)"

#=============================================================================
# PATH ADDITIONS
# Add machine-specific paths here
#=============================================================================
# path=(
#     "$HOME/bin"
#     "$HOME/scripts"
#     $path
# )

#=============================================================================
# ENVIRONMENT OVERRIDES
#=============================================================================
# Override default editor
# export EDITOR="vim"

# Override browser
# export BROWSER="chromium"

# Machine-specific API keys (use with caution!)
# export OPENAI_API_KEY="sk-..."
# export GITHUB_TOKEN="ghp_..."

#=============================================================================
# WORK-SPECIFIC CONFIGURATION
#=============================================================================
# Proxy settings
# export HTTP_PROXY="http://proxy.company.com:8080"
# export HTTPS_PROXY="$HTTP_PROXY"
# export NO_PROXY="localhost,127.0.0.1,.company.com"

# Work directories
# export WORK_DIR="$HOME/work"
# hash -d work="$WORK_DIR"

# SSH agent for work
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

#=============================================================================
# HARDWARE-SPECIFIC SETTINGS
#=============================================================================
# GPU configuration (NVIDIA)
# export __NV_PRIME_RENDER_OFFLOAD=1
# export __GLX_VENDOR_LIBRARY_NAME=nvidia

# High DPI / Scaling
# export GDK_SCALE=2
# export QT_SCALE_FACTOR=2

# Audio
# export PULSE_SERVER=unix:/run/user/1000/pulse/native

#=============================================================================
# ALIASES - MACHINE SPECIFIC
#=============================================================================
# Quick SSH to frequently used hosts
# alias work-server='ssh user@work-server.company.com'
# alias home-nas='ssh admin@192.168.1.100'

# Project shortcuts
# alias proj1='cd ~/projects/project1 && nvim'
# alias proj2='cd ~/projects/project2 && nvim'

# Machine-specific commands
# alias suspend='systemctl suspend'
# alias hibernate='systemctl hibernate'
# alias lock='swaylock -f'

#=============================================================================
# FUNCTIONS - LOCAL HELPERS
#=============================================================================

# Example: Quick project opener
# function proj() {
#     local project
#     project=$(fd --type d --max-depth 2 . ~/projects ~/work 2>/dev/null | \
#         fzf --header '╭─ Projects ─╮')
#     [[ -n "$project" ]] && cd "$project" && nvim .
# }

# Example: VPN connection
# function vpn-connect() {
#     sudo wg-quick up wg0
# }
# function vpn-disconnect() {
#     sudo wg-quick down wg0
# }

#=============================================================================
# AUTO-START / SESSION SETUP
#=============================================================================
# Start SSH agent if not running
# if [[ -z "$SSH_AUTH_SOCK" ]]; then
#     eval $(ssh-agent -s)
#     ssh-add ~/.ssh/id_ed25519
# fi

# Auto-attach to tmux (uncomment to enable)
# if [[ -z "$TMUX" && -n "$PS1" && -z "$SSH_CONNECTION" ]]; then
#     tmux attach -t main 2>/dev/null || tmux new-session -s main
# fi

# Set terminal title
# print -Pn "\e]0;${USER}@${HOST}\a"

#=============================================================================
# CONDITIONAL LOADING
#=============================================================================

# Load work config only at work
# if [[ "$MACHINE_TYPE" == "work" ]] || [[ -d "/opt/company-tools" ]]; then
#     source "$ZSH_CORE/work.zsh"
# fi

# Load server-specific config
# if [[ "$MACHINE_TYPE" == "server" ]]; then
#     source "$ZSH_CORE/server.zsh"
# fi

#=============================================================================
# CLEANUP / FINAL SETUP
#=============================================================================
# Any final setup that should happen after all other configs load

# Ensure PATH doesn't have duplicates
typeset -U PATH path
