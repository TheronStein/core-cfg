# ~/.core/zsh/integrations/navigation.zsh
# Seamless pane navigation: ZSH -> tmux -> nvim -> terminal
#
# Uses terminal-nav CLI script for terminal pane navigation.
# Keybinds: Ctrl+Shift+W/A/S/D for Up/Left/Down/Right

#=============================================================================
# TERMINAL NAVIGATION SCRIPT
#=============================================================================
_TERMINAL_NAV="${HOME}/.local/bin/terminal-nav"

#=============================================================================
# NAVIGATION FUNCTION
# Handles: tmux pane edge detection, then terminal-nav for terminal splits
#=============================================================================
__navigate_pane() {
    local direction="$1"

    if [[ -n "$TMUX" ]]; then
        # Inside tmux - check if at edge
        local at_edge=0
        case "$direction" in
            up)    [[ "$(tmux display -p '#{pane_at_top}')" == "1" ]] && at_edge=1 ;;
            down)  [[ "$(tmux display -p '#{pane_at_bottom}')" == "1" ]] && at_edge=1 ;;
            left)  [[ "$(tmux display -p '#{pane_at_left}')" == "1" ]] && at_edge=1 ;;
            right) [[ "$(tmux display -p '#{pane_at_right}')" == "1" ]] && at_edge=1 ;;
        esac

        if (( at_edge )); then
            # At tmux edge - navigate terminal
            [[ -x "$_TERMINAL_NAV" ]] && "$_TERMINAL_NAV" "$direction"
        else
            # Not at edge - navigate tmux panes
            local tmux_dir
            case "$direction" in
                up)    tmux_dir="-U" ;;
                down)  tmux_dir="-D" ;;
                left)  tmux_dir="-L" ;;
                right) tmux_dir="-R" ;;
            esac
            tmux select-pane $tmux_dir
        fi
    else
        # Not in tmux - navigate terminal directly
        [[ -x "$_TERMINAL_NAV" ]] && "$_TERMINAL_NAV" "$direction"
    fi
}

#=============================================================================
# ZLE WIDGETS
#=============================================================================
__nav_up()    { __navigate_pane up;    zle redisplay; }
__nav_down()  { __navigate_pane down;  zle redisplay; }
__nav_left()  { __navigate_pane left;  zle redisplay; }
__nav_right() { __navigate_pane right; zle redisplay; }

zle -N __nav_up
zle -N __nav_down
zle -N __nav_left
zle -N __nav_right

#=============================================================================
# KEY BINDINGS: Ctrl+Shift+W/A/S/D
# These require CSI u mode to distinguish Ctrl+Shift from plain Ctrl
# Bind in all keymaps for vi-mode compatibility
#=============================================================================
for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^[[119;6u' __nav_up     # Ctrl+Shift+W
    bindkey -M "$keymap" '^[[97;6u'  __nav_left   # Ctrl+Shift+A
    bindkey -M "$keymap" '^[[115;6u' __nav_down   # Ctrl+Shift+S
    bindkey -M "$keymap" '^[[100;6u' __nav_right  # Ctrl+Shift+D
done
