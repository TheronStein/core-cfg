# ~/.core/zsh/modules/keybindings.zsh
# Keybindings configuration - comprehensive keyboard shortcut mappings

#=============================================================================
# ZLE (Zsh Line Editor) Setup
#=============================================================================
# Use emacs mode as base (more compatible with terminal shortcuts)
bindkey -e

# Alternative: Enable vi mode with emacs-style shortcuts
# bindkey -v
# export KEYTIMEOUT=1

#=============================================================================
# TERMINAL KEY CODE REFERENCE
# Use `cat -v` or `showkey -a` to discover key codes on your terminal
#=============================================================================
# ^X     = Ctrl+X
# ^[     = Alt (Meta) or Escape
# ^[[A   = Up arrow     ^[[B   = Down arrow
# ^[[C   = Right arrow  ^[[D   = Left arrow
# ^[[H   = Home         ^[[F   = End
# ^[[3~  = Delete       ^[[5~  = Page Up
# ^[[6~  = Page Down
#=============================================================================

#=============================================================================
# FZF INTEGRATION WIDGETS
#=============================================================================
bindkey '^R' widget::fzf-history-search      # Ctrl+R: Enhanced history
bindkey '^F' widget::fzf-file-selector       # Ctrl+F: Find files
bindkey '^[f' widget::fzf-directory-selector # Alt+F: Find directories
bindkey '^K' widget::fzf-kill-process        # Ctrl+K: Kill process
bindkey '^P' widget::command-palette         # Ctrl+P: Command palette

#=============================================================================
# GIT INTEGRATION
#=============================================================================
bindkey '^G' widget::fzf-git-status   # Ctrl+G: Git status files
bindkey '^[g' widget::fzf-git-branch  # Alt+G: Git branches
bindkey '^[c' widget::fzf-git-commits # Alt+C: Git commits
bindkey '^[r' widget::fzf-git-remotes # Alt+R: Git remotes

#=============================================================================
# TMUX INTEGRATION
#=============================================================================
bindkey '^T' widget::fzf-tmux-session # Ctrl+T: Tmux sessions
bindkey '^[t' widget::fzf-tmux-window # Alt+T: Tmux windows
bindkey '^[p' widget::fzf-tmux-pane   # Alt+P: Tmux panes

#=============================================================================
# YAZI INTEGRATION
#=============================================================================
bindkey '^[y' widget::yazi-picker # Alt+Y: Yazi file picker
bindkey '^Y' widget::yazi-cd      # Ctrl+Y: Yazi with cd

#=============================================================================
# NEOVIM INTEGRATION
#=============================================================================
bindkey '^X^E' widget::edit-command-nvim # Ctrl+X Ctrl+E: Edit in nvim
bindkey '^[o' widget::nvim-recent-files  # Alt+O: Recent nvim files

#=============================================================================
# CLIPBOARD OPERATIONS
#=============================================================================
bindkey '^[w' widget::copy-buffer     # Alt+W: Copy buffer
bindkey '^[v' widget::paste-clipboard # Alt+V: Paste clipboard
bindkey '^[x' widget::cut-buffer      # Alt+X: Cut buffer

#=============================================================================
# BOOKMARKS & NAVIGATION
#=============================================================================
bindkey '^[b' widget::bookmark-directory # Alt+B: Bookmark directory
bindkey '^[j' widget::jump-bookmark      # Alt+J: Jump to bookmark
bindkey '^[z' widget::zoxide-interactive # Alt+Z: Zoxide jump

#=============================================================================
# TEXT INSERTION
#=============================================================================
bindkey '^[=' widget::calculator       # Alt+=: Calculator
bindkey '^[d' widget::insert-date      # Alt+D: Insert date
bindkey '^[D' widget::insert-timestamp # Alt+Shift+D: Insert timestamp
bindkey '^[u' widget::insert-uuid      # Alt+U: Insert UUID

#=============================================================================
# UTILITY WIDGETS
#=============================================================================
bindkey '^[s' widget::fzf-ssh         # Alt+S: SSH host selector
bindkey '^[e' widget::fzf-env         # Alt+E: Environment variables
bindkey '^L' widget::clear-scrollback # Ctrl+L: Clear with scrollback
bindkey '^[n' widget::quick-note      # Alt+N: Quick note
bindkey '^[ ' widget::expand-alias    # Alt+Space: Expand alias

#=============================================================================
# SUDO TOGGLE (double escape)
#=============================================================================
bindkey "\e\e" widget::toggle-sudo # Esc Esc: Toggle sudo

#=============================================================================
# HISTORY NAVIGATION
#=============================================================================
# Substring search (requires zsh-history-substring-search plugin)
bindkey '^[[A' history-substring-search-up   # Up: History search up
bindkey '^[[B' history-substring-search-down # Down: History search down
bindkey '^[OA' history-substring-search-up   # Terminal compatibility
bindkey '^[OB' history-substring-search-down

# Beginning search (type partial, then navigate)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[p' up-line-or-beginning-search   # Alt+P: History up
bindkey '^[n' down-line-or-beginning-search # Alt+N: History down

#=============================================================================
# LINE MOVEMENT (Emacs style)
#=============================================================================
bindkey '^A' beginning-of-line    # Ctrl+A: Start of line
bindkey '^E' end-of-line          # Ctrl+E: End of line
bindkey '^B' backward-char        # Ctrl+B: Back one char
bindkey '^[b' backward-word       # Alt+B: Back one word
bindkey '^[f' forward-word        # Alt+F: Forward one word
bindkey '^[[H' beginning-of-line  # Home
bindkey '^[[F' end-of-line        # End
bindkey '^[[1~' beginning-of-line # Home (alternate)
bindkey '^[[4~' end-of-line       # End (alternate)

#=============================================================================
# TEXT DELETION
#=============================================================================
bindkey '^H' backward-delete-char # Backspace
bindkey '^?' backward-delete-char # Backspace (alternate)
bindkey '^[[3~' delete-char       # Delete
bindkey '^W' backward-kill-word   # Ctrl+W: Delete word back
bindkey '^[d' kill-word           # Alt+D: Delete word forward
bindkey '^U' backward-kill-line   # Ctrl+U: Delete to start
bindkey '^[k' kill-line           # Alt+K: Delete to end

#=============================================================================
# TEXT TRANSFORMATION
#=============================================================================
bindkey '^[U' up-case-word    # Alt+Shift+U: Uppercase word
bindkey '^[l' down-case-word  # Alt+L: Lowercase word
bindkey '^[C' capitalize-word # Alt+Shift+C: Capitalize word
bindkey '^[t' transpose-words # Alt+T: Swap words
bindkey '^T' transpose-chars  # Ctrl+T: Swap chars

#=============================================================================
# UNDO/REDO
#=============================================================================
bindkey '^_' undo  # Ctrl+_: Undo
bindkey '^[/' redo # Alt+/: Redo

#=============================================================================
# COMPLETION MENU NAVIGATION
#=============================================================================
bindkey -M menuselect '^[[Z' reverse-menu-complete # Shift+Tab: Reverse
bindkey -M menuselect '^[' send-break              # Escape: Cancel
bindkey -M menuselect '^M' .accept-line            # Enter: Accept
bindkey -M menuselect 'h' vi-backward-char         # h: Left
bindkey -M menuselect 'j' vi-down-line-or-history  # j: Down
bindkey -M menuselect 'k' vi-up-line-or-history    # k: Up
bindkey -M menuselect 'l' vi-forward-char          # l: Right

#=============================================================================
# VI MODE BINDINGS (when in vi command mode)
#=============================================================================
bindkey -M vicmd 'H' beginning-of-line
bindkey -M vicmd 'L' end-of-line
bindkey -M vicmd 'u' undo
bindkey -M vicmd '^R' redo
bindkey -M vicmd '/' widget::fzf-history-search
bindkey -M vicmd 'v' widget::edit-command-nvim

#=============================================================================
# SPECIAL FUNCTION KEYS
#=============================================================================
bindkey '^[[5~' beginning-of-buffer-or-history # Page Up
bindkey '^[[6~' end-of-buffer-or-history       # Page Down

#=============================================================================
# HELP/REFERENCE KEY
#=============================================================================
function widget::show-keybindings() {
  echo ""
  cat <<'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                           ZSH KEYBINDINGS REFERENCE                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ FZF WIDGETS                    │ GIT INTEGRATION                             ║
║   Ctrl+R    History search     │   Ctrl+G    Git status files               ║
║   Ctrl+F    Find files         │   Alt+G     Git branches                   ║
║   Alt+F     Find directories   │   Alt+C     Git commits                    ║
║   Ctrl+K    Kill processes     │   Alt+R     Git remotes                    ║
║   Ctrl+P    Command palette    │                                            ║
╠──────────────────────────────────┼──────────────────────────────────────────╣
║ TMUX                           │ YAZI                                        ║
║   Ctrl+T    Tmux sessions      │   Ctrl+Y    Yazi with cd                   ║
║   Alt+T     Tmux windows       │   Alt+Y     Yazi file picker               ║
║   Alt+P     Tmux panes         │                                            ║
╠──────────────────────────────────┼──────────────────────────────────────────╣
║ CLIPBOARD                      │ NAVIGATION                                  ║
║   Alt+W     Copy buffer        │   Alt+B     Bookmark directory             ║
║   Alt+V     Paste clipboard    │   Alt+J     Jump to bookmark               ║
║   Alt+X     Cut buffer         │   Alt+Z     Zoxide interactive             ║
╠──────────────────────────────────┼──────────────────────────────────────────╣
║ UTILITIES                      │ TEXT INSERTION                              ║
║   Alt+S     SSH host selector  │   Alt+=     Calculator                     ║
║   Alt+E     Environment vars   │   Alt+D     Insert date                    ║
║   Ctrl+L    Clear scrollback   │   Alt+U     Insert UUID                    ║
║   Esc Esc   Toggle sudo        │   Ctrl+X E  Edit in $EDITOR                ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
  zle reset-prompt
}
zle -N widget::show-keybindings
bindkey '^[[11~' widget::show-keybindings # F1
bindkey '^[?' widget::show-keybindings    # Alt+?
