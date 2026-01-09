# ~/.core/zsh/04-keybindings.zsh
# Vi-mode keybindings - minimal configuration
#
# PHILOSOPHY: Commit fully to vi-mode. No Emacs bindings.
# - Navigation: ijkl in command mode (i=up, k=down, j=left, l=right)
# - Word movement: w/b/e in command mode
# - Custom widgets: Ctrl+ and Alt+Ctrl+ prefixes in insert mode
#
# Custom widget bindings are set in zvm_after_init() in 02-zinit.zsh
# to prevent conflicts with zsh-vi-mode plugin

#=============================================================================
# TERMINAL COMPATIBILITY
#=============================================================================
# These ensure basic terminal keys work regardless of mode

# Arrow keys for history (terminal compatibility)
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# Home/End keys
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line  # Home (alternate)
bindkey '^[[4~' end-of-line        # End (alternate)

# Backspace and Delete
bindkey '^H' backward-delete-char
bindkey '^?' backward-delete-char
bindkey '^[[3~' delete-char

# Page Up/Down
bindkey '^[[5~' beginning-of-buffer-or-history
bindkey '^[[6~' end-of-buffer-or-history

#=============================================================================
# COMPLETION MENU NAVIGATION (ijkl)
#=============================================================================
zmodload -i zsh/complist

bindkey -M menuselect '^[[Z' reverse-menu-complete  # Shift+Tab: Reverse
bindkey -M menuselect '^[' send-break               # Escape: Cancel
bindkey -M menuselect '^M' .accept-line             # Enter: Accept
bindkey -M menuselect 'j' vi-backward-char          # j: Left
bindkey -M menuselect 'k' vi-down-line-or-history   # k: Down
bindkey -M menuselect 'i' vi-up-line-or-history     # i: Up
bindkey -M menuselect 'l' vi-forward-char           # l: Right

#=============================================================================
# VI COMMAND MODE - see zvm_after_init() in 02-zinit.zsh
#=============================================================================
# All vicmd bindings are in zvm_after_init() because zsh-vi-mode plugin
# overwrites bindings set here. See 02-zinit.zsh for the full mapping.

#=============================================================================
# INSERT MODE - MULTILINE & RECOVERY
#=============================================================================

# Widget to insert a literal newline (for multiline commands)
function _insert_newline() {
    LBUFFER+=$'\n'
}
zle -N _insert_newline

# Shift+Enter: Insert newline without executing
bindkey -M viins '^[[13;2u' _insert_newline     # Shift+Enter (kitty protocol)
bindkey -M viins '\e[13;2~' _insert_newline     # Shift+Enter (alternate)

# Alt+Enter: Insert newline (common alternative)
bindkey -M viins '\e^M' _insert_newline
bindkey -M viins '^[^M' _insert_newline         # Alt+Enter (alternate encoding)

# Ctrl+C: Cancel and reset to clean insert mode
# Handles the "stuck in mode" issue by forcing a clean state
function _zvm_reset_mode() {
    zle reset-prompt
    zle -R
}
zle -N _zvm_reset_mode
bindkey -M viins '^C' _zvm_reset_mode
bindkey -M vicmd '^C' _zvm_reset_mode
