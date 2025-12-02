# ~/.core/zsh/integrations/widgets.zsh
#
# REFERENCE/EXAMPLE FILE - Simplified Widget Implementation Examples
#
# This file demonstrates a streamlined approach to creating fzf-based widgets
# using the unified theme system from integrations/fzf.zsh.
#
# NOTE: The functions in this file are EXAMPLES ONLY and are NOT sourced by default.
#       The production widgets are in 03-widgets.zsh and use the same theme system.
#
# Key concepts demonstrated here:
# 1. _fzf_colors() - Dynamic color fetching from wezterm theme
# 2. _fzf_base() - Reusable base configuration for consistent widget styling
# 3. Compact widget implementations using the base configuration
#
# You can use this file as a reference when creating new widgets or as a
# starting point for a completely streamlined widget configuration.
#
#=============================================================================

# One shared function that returns your current beautiful fzf colors
# This is also defined in integrations/fzf.zsh
_fzf_colors() {
  "$HOME/.core/.sys/cfg/wezterm/scripts/theme-browser/get-current-fzf-colors.zsh" 2>/dev/null || cat <<'EOF'
bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4
header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc
fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,border:#89b4fa
label:#89b4fa,query:#cdd6f4
EOF
}

# Reusable fzf base options — this is your exact style, just not 100% height
_fzf_base() {
  fzf \
    --height=50% \
    --reverse \
    --border=rounded \
    --border-label-pos=3 \
    --prompt="❯ " \
    --pointer="▶" \
    --marker="✓" \
    --color="$(_fzf_colors)" \
    --bind="ctrl-/:toggle-preview" \
    --preview-window="right:60%:wrap:rounded"
}

# Now rewrite every widget in 1–2 lines each
widget::fzf-file() {
  local sel=$(_fzf_base --preview='bat --style=numbers --color=always --line-range=:300 {}' < <(fd -tf --hidden --follow --exclude .git))
  [[ -n "$sel" ]] && LBUFFER+="${(q)sel}"
  zle reset-prompt
}
zle -N widget::fzf-file
bindkey '^F' widget::fzf-file

widget::fzf-dir() {
  local sel=$(_fzf_base --preview='eza -la --color=always --icons {}' < <(fd -td --hidden --follow --exclude .git))
  [[ -n "$sel" ]] && { [[ -z "$BUFFER" ]] && cd "$sel" && zle accept-line || LBUFFER+="${(q)sel}" }
  zle reset-prompt
}
zle -N widget::fzf-dir
bindkey '^D' widget::fzf-dir

widget::fzf-history() {
  local sel=$(fc -rl 1 | awk '!seen[$0]++' | _fzf_base --tiebreak=index --preview='echo {2..}' --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort')
  [[ -n "$sel" ]] && zle vi-fetch-history -n $(echo "$sel" | awk '{print $1}')
  zle reset-prompt
}
zle -N widget::fzf-history
bindkey '^R' widget::fzf-history

widget::fzf-kill() {
  local pid=$(ps aux | sed 1d | _fzf_base -m --preview='echo {}' | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs -r kill -9
  zle reset-prompt
}
zle -N widget::fzf-kill
bindkey '^K' widget::fzf-kill

widget::fzf-git-status() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local files=$(git status --short | _fzf_base -m --ansi --preview='git diff --color=always -- {-1} | delta' | awk '{print $2}')
  [[ -n "$files" ]] && LBUFFER+="$files "
  zle reset-prompt
}
zle -N widget::fzf-git-status
bindkey '^G' widget::fzf-git-status

#=============================================================================
# USAGE NOTES
#=============================================================================
#
# This file is provided as a reference implementation showing how to create
# compact, streamlined widgets using the unified fzf theme system.
#
# To use these example widgets instead of the ones in 03-widgets.zsh:
# 1. Backup your current 03-widgets.zsh
# 2. Source this file in your .zshrc instead of 03-widgets.zsh
# 3. Adjust keybindings as needed
#
# To integrate the theme system into your own widgets:
# 1. Ensure integrations/fzf.zsh is sourced (it provides _fzf_colors and _fzf_base_opts)
# 2. Use $(_fzf_base_opts) in your fzf commands for consistent theming
# 3. Or create your own wrapper function like _fzf_base() shown above
#
# The main advantage of this approach is that ALL fzf widgets automatically
# match your wezterm theme without any manual color configuration.
#
#=============================================================================
