# ~/.core/zsh/04-keybindings.zsh
# Keybindings configuration - maps keyboard shortcuts to widgets and functions

#=============================================================================
# NOTES ON ZSH KEYBINDINGS
#=============================================================================
# Key notation:
#   ^X     = Ctrl+X
#   ^[     = Alt (Meta) or Escape
#   ^[[A   = Up arrow
#   ^[[B   = Down arrow
#   ^[[C   = Right arrow
#   ^[[D   = Left arrow
#   ^[[H   = Home
#   ^[[F   = End
#   ^[[3~  = Delete
#   ^[[5~  = Page Up
#   ^[[6~  = Page Down
#
# Use `cat -v` or `showkey -a` to find key codes
# Use `bindkey` without args to see current bindings
#=============================================================================

#=============================================================================
# BASE KEYMAP SETUP
#=============================================================================
# Start with emacs keymap as base (more compatible)
bindkey -e

# But enable some vi-mode features
bindkey -M main '^[' vi-cmd-mode # Escape to enter vi command mode

#=============================================================================
# FZF WIDGETS (Primary shortcuts)
#=============================================================================
bindkey '^R' widget::fzf-history-search      # Ctrl+R: Enhanced history
bindkey '^F' widget::fzf-file-selector       # Ctrl+F: Find files
bindkey '^[f' widget::fzf-directory-selector # Alt+F: Find directories
bindkey '^K' widget::fzf-kill-process        # Ctrl+K: Kill process
bindkey '^P' widget::command-palette         # Ctrl+P: Command palette

#=============================================================================
# GIT WIDGETS
#=============================================================================
bindkey '^G' widget::fzf-git-status   # Ctrl+G: Git status files
bindkey '^[g' widget::fzf-git-branch  # Alt+G: Git branches
bindkey '^[c' widget::fzf-git-commits # Alt+C: Git commits

#=============================================================================
# TMUX WIDGETS
#=============================================================================
bindkey '^T' widget::fzf-tmux-session # Ctrl+T: Tmux sessions
bindkey '^[t' widget::fzf-tmux-window # Alt+T: Tmux windows

#=============================================================================
# YAZI WIDGETS
#=============================================================================
bindkey '^[y' widget::yazi-picker # Alt+Y: Yazi file picker
bindkey '^Y' widget::yazi-cd      # Ctrl+Y: Yazi with cd

#=============================================================================
# UTILITY WIDGETS
#=============================================================================
bindkey '^[s' widget::fzf-ssh         # Alt+S: SSH host selector
bindkey '^[e' widget::fzf-env         # Alt+E: Environment variables
bindkey '^X^E' widget::edit-command   # Ctrl+X Ctrl+E: Edit in $EDITOR
bindkey '^L' widget::clear-scrollback # Ctrl+L: Clear with scrollback

#=============================================================================
# CLIPBOARD
#=============================================================================
bindkey '^[w' widget::copy-buffer     # Alt+W: Copy buffer
bindkey '^[v' widget::paste-clipboard # Alt+V: Paste clipboard

#=============================================================================
# BOOKMARKS & NOTES
#=============================================================================
bindkey '^[b' widget::bookmark-directory # Alt+B: Bookmark directory
bindkey '^[j' widget::jump-bookmark      # Alt+J: Jump to bookmark
bindkey '^[n' widget::quick-note         # Alt+N: Quick note

#=============================================================================
# TEXT MANIPULATION
#=============================================================================
bindkey '^[=' widget::calculator       # Alt+=: Calculator
bindkey '^[d' widget::insert-date      # Alt+D: Insert date
bindkey '^[T' widget::insert-timestamp # Alt+Shift+T: Insert timestamp
bindkey '^ ' widget::expand-alias      # Ctrl+Space: Expand alias

#=============================================================================
# SUDO TOGGLE (double escape)
#=============================================================================
bindkey -M vicmd "\e\e" widget::toggle-sudo
bindkey -M viins "\e\e" widget::toggle-sudo

#=============================================================================
# HISTORY NAVIGATION
#=============================================================================
# Substring search (from plugin)
bindkey '^[[A' history-substring-search-up   # Up: History search up
bindkey '^[[B' history-substring-search-down # Down: History search down
bindkey '^[OA' history-substring-search-up   # Terminal compatibility
bindkey '^[OB' history-substring-search-down

# Beginning search (type partial command, then search)
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[p' up-line-or-beginning-search   # Alt+P: History up
bindkey '^[n' down-line-or-beginning-search # Alt+N: History down

#=============================================================================
# LINE MOVEMENT (Emacs style)
#=============================================================================
bindkey '^A' beginning-of-line # Ctrl+A: Start of line
bindkey '^E' end-of-line       # Ctrl+E: End of line
bindkey '^B' backward-char     # Ctrl+B: Back one char
bindkey '^[b' backward-word    # Alt+B: Back one word
bindkey '^[f' forward-word     # Alt+F: Forward one word
# bindkey '^U' backward-word
bindkey '^[[8;5u' backward-word
# Home/End keys
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
# bindkey '^U' backward-kill-line   # Ctrl+U: Delete to start
bindkey '^[k' kill-line # Alt+K: Delete to end

#=============================================================================
# TEXT TRANSFORMATION
#=============================================================================
bindkey '^[u' up-case-word    # Alt+U: Uppercase word
bindkey '^[l' down-case-word  # Alt+L: Lowercase word
bindkey '^[c' capitalize-word # Alt+C: Capitalize word
bindkey '^[t' transpose-words # Alt+T: Swap words
bindkey '^T' transpose-chars  # Ctrl+T: Swap chars

#=============================================================================
# UNDO/REDO
#=============================================================================
bindkey '^_' undo  # Ctrl+_: Undo
bindkey '^[/' redo # Alt+/: Redo

#=============================================================================
# COMPLETION
#=============================================================================
# Note: Tab (^I) is handled automatically by fzf-tab when loaded
# Don't manually bind it to avoid recursion issues
bindkey '^[i' expand-or-complete  # Alt+I: Standard completion
bindkey '^[!' expand-history      # Alt+!: Expand history
bindkey '^[~' _bash_complete-word # Alt+~: Bash completion

#=============================================================================
# MENU NAVIGATION (when in completion menu)
#=============================================================================
# Load complist module for menuselect keymap
zmodload -i zsh/complist

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
bindkey -M vicmd 'v' widget::edit-command

#=============================================================================
# SPECIAL FUNCTION KEYS
#=============================================================================
bindkey '^[[5~' beginning-of-buffer-or-history # Page Up
bindkey '^[[6~' end-of-buffer-or-history       # Page Down

#=============================================================================
# HELP KEY (F1)
#=============================================================================
function widget::show-keybindings() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "                    ZSH KEYBINDINGS REFERENCE"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""
  echo "FZF WIDGETS:"
  echo "  Ctrl+R    History search with preview"
  echo "  Ctrl+F    Find and insert files"
  echo "  Alt+F     Find directories"
  echo "  Ctrl+K    Kill processes"
  echo "  Ctrl+P    Command palette"
  echo ""
  echo "GIT:"
  echo "  Ctrl+G    Git status file selector"
  echo "  Alt+G     Git branch selector"
  echo "  Alt+C     Git commit browser"
  echo ""
  echo "TMUX:"
  echo "  Ctrl+T    Tmux session selector"
  echo "  Alt+T     Tmux window selector"
  echo ""
  echo "YAZI:"
  echo "  Ctrl+Y    Yazi with cd on exit"
  echo "  Alt+Y     Yazi file picker"
  echo ""
  echo "UTILITIES:"
  echo "  Alt+S     SSH host selector"
  echo "  Alt+E     Environment variable browser"
  echo "  Ctrl+X E  Edit command in \$EDITOR"
  echo "  Esc Esc   Toggle sudo prefix"
  echo ""
  echo "CLIPBOARD:"
  echo "  Alt+W     Copy buffer to clipboard"
  echo "  Alt+V     Paste from clipboard"
  echo ""
  echo "BOOKMARKS:"
  echo "  Alt+B     Bookmark directory"
  echo "  Alt+J     Jump to bookmark"
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  zle reset-prompt
}
zle -N widget::show-keybindings
bindkey '^[[11~' widget::show-keybindings # F1
bindkey '^[?' widget::show-keybindings    # Alt+?

#=============================================================================
# DOCUMENTATION SYSTEM WIDGETS
#=============================================================================
# Alt+H: Context-aware help for current command/environment
bindkey '\eh' _doc_help_widget

# Alt+/: Search all documentation
bindkey '\e/' _doc_search_widget

# Alt+R: Quick reference menu (functions/widgets/keybindings)
bindkey '\er' _doc_quick_ref_widget

# Ctrl+X ?: Main documentation menu hub
bindkey '^X?' doc-menu

# Ctrl+X H: Generate documentation from code
bindkey '^XH' widget::doc-generate

#=============================================================================
# QUICK REFERENCE ALIAS
#=============================================================================
alias keys='widget::show-keybindings'

# === zce ref ================================================================ [[[
# function :zce-char() {
#   [[ -z $BUFFER ]] && zle up-history
#   zstyle ':zce:*' prompt-char '%B%F{12}Jump to character:%F%b '
#   zstyle ':zce:*' prompt-key '%B%F{12}Target key:%F%b '
#   with-zce zce-raw zce-searchin-read
# }; zle -N :zce-char
#
# function :zce-fchar() {
#   zle :zce-char
# }; zle -N :zce-fchar
# Zkeymaps+=("mode=vicmd f" :zce-fchar)
# Zkeymaps+=("mode=vicmd ;f" :zce-fchar)
# Zkeymaps+=("mode=viins ;f" :zce-fchar)
# Zkeymaps+=("mode=viopp ;f" :zce-fchar)
#
# function :zce-tchar() {
#   zle :zce-char
#   ((CURSOR--))
# }; zle -N :zce-tchar
# Zkeymaps+=("mode=vicmd t" :zce-tchar)
# Zkeymaps+=("mode=vicmd ;t" :zce-tchar)
# Zkeymaps+=("mode=viins ;t" :zce-tchar)
# Zkeymaps+=("mode=viopp ;t" :zce-tchar)
#
# function :zce-Fchar() {
#   zle :zce-char
# }; zle -N :zce-Fchar
# Zkeymaps+=("mode=vicmd F" :zce-Fchar)
# Zkeymaps+=("mode=vicmd ;F" :zce-Fchar)
# Zkeymaps+=("mode=viins ;F" :zce-Fchar)
# Zkeymaps+=("mode=viopp ;F" :zce-Fchar)
#
# function :zce-Tchar() {
#   zle :zce-char
#   ((CURSOR++))
# }; zle -N :zce-Tchar
# Zkeymaps+=("mode=vicmd T" :zce-Tchar)
# Zkeymaps+=("mode=vicmd ;T" :zce-Tchar)
# Zkeymaps+=("mode=viins ;T" :zce-Tchar)
# Zkeymaps+=("mode=viopp ;T" :zce-Tchar)
#
# function :zce-delete-char() {
#   [[ -z $BUFFER ]] && zle up-history
#   typeset -gA reply
#   reply[pbuffer]=$BUFFER reply[pcursor]=$CURSOR
#   local keys=${(j..)$(print {a..z} {A..Z})}
#   zstyle ':zce:*' prompt-char '%B%F{13}Delete to character:%F%b '
#   zstyle ':zce:*' prompt-key '%B%F{13}Target key:%F%b '
#   zce-raw zce-searchin-read $keys
# }; zle -N :zce-delete-char
#
# function :zce-delete-fchar() {
#   zle :zce-delete-char
#   local pcursor=$reply[pcursor] pbuffer=$reply[pbuffer]
#
#   if (( $CURSOR < $pcursor ))  {
#     pbuffer[$CURSOR,$pcursor]=$pbuffer[$CURSOR]
#   } else {
#     pbuffer[$pcursor,((CURSOR+1))]=$pbuffer[$pcursor]
#     CURSOR=$pcursor
#   }
#   BUFFER=$pbuffer
# }; zle -N :zce-delete-fchar
# Zkeymaps+=("mode=vicmd df" :zce-delete-fchar)
# Zkeymaps+=("mode=vicmd dF" :zce-delete-Fchar)
#
# function :zce-delete-tchar() {
#   zle :zce-delete-char
#   local pcursor=$reply[pcursor] pbuffer=$reply[pbuffer]
#
#   if (( $CURSOR < $pcursor ))  {
#     pbuffer[$CURSOR,$pcursor]=$pbuffer[$CURSOR]
#   } else {
#     pbuffer[$pcursor,$CURSOR]=$pbuffer[$pcursor]
#     CURSOR=$pcursor
#   }
#   BUFFER=$pbuffer
# }; zle -N :zce-delete-tchar
# Zkeymaps+=("mode=vicmd dt" :zce-delete-tchar)
# Zkeymaps+=("mode=vicmd dT" :zce-delete-tchar)
# ]]]

# [[[ keymaps array reference
# Zkeymaps+=(
# ========================== Bindings ==========================
#   # 'M-S-R'               fzf-history-widget  # Builtin fzf history widget
#   'mode=viins M-c'        fzf-cd-widget         # Builtin fzf cd widget
#   'mode=viins C-t'        fzf-file-widget       # Insert file into cli
#   'mode=viins C-a'        autosuggest-execute   # Execute the autosuggestion
#
#   'mode=viins M-g'        get-line              # Get line from buffer-stack
#   'mode=viins M-q'        push-line-or-edit     # Push line onto buffer stack
#   # 'M-S-q'               push-input          # Push multi-line onto buffer stack
#   'mode=viins C-y'        yank                  # Insert the contents of the kill buffer at the cursor position
#   'mode=viins C-w'        vi-backward-kill-word    # Kill word backwards
#
#   # 'mode=viins M-['        vi-kill-line         # Kill cursorpos to beginning
#   # 'mode=viins M-]'        vi-kill-eol          # Kill cursorpos to end
#   'mode=viins M-['        backward-kill-line   # Kill cursorpos to beginning
#   'mode=viins M-]'        kill-line            # Kill cursorpos to end
#   'mode=viins C-h'        backward-delete-char
#
#   'mode=viins jk'         vi-cmd-mode        # Switch to vi-cmd mode
#   'mode=viins kj'         vi-cmd-mode        # Switch to vi-cmd mode
#
#   # 'mode=viins C-S-h'      vi-backward-word
#   # 'mode=vicmd :'          execute-named-cmd
#   'mode=vicmd u'          undo
#   'mode=vicmd U'          redo
#   'mode=vicmd ;u'         vi-undo-change
#   # 'mode=viins M-u'      vi-undo-change
#   # 'mode=vicmd L'        end-of-line            # Move to end of line, even on another line
#   # 'mode=vicmd H'        beginning-of-line      # Moves to very beginning, even on another line
#   'mode=vicmd L'          vi-end-of-line
#   'mode=vicmd H'          vi-beginning-of-line
#   'mode=vicmd 0'          vi-digit-or-beginning-of-line
#
#   'mode=vicmd Y'          vi-yank-whole-line
#   'mode=vicmd ye'         vi-yank-eol
#
#   'mode=vicmd ;x'         vi-backward-kill-word    # Kill word backwards
#   'mode=vicmd C'          vi-change-eol        # Kill text to end of line & start in insert
#   'mode=vicmd S'          vi-change-whole-line # Change all text to start over
#   'mode=vicmd cc'         vi-change-whole-line # Change all text to start over
#   'mode=vicmd #'          vi-pound-insert
#   'mode=vicmd %'          vi-match-bracket
#
#   'mode=viins C-x C-d'    _complete_debug
#   'mode=viins C-x ?'      _complete_debug
#   'mode=viins C-x h'      _complete_help
#   'mode=viins C-x C-t'    _complete_tag
#   'mode=viins C-x C-r'    _read_comp
#   'mode=viins C-x .'      fzf-tab-debug
#   'mode=viins C-x i'      insert-files
#
#   'mode=viins C-x m'      _most_recent_file  # Insert most recent file
#   'mode=viins C-x C'      _correct_filename  # Correct filename under cursor
#   'mode=viins C-x c'      _correct_word      # Correct word under cursor
#   'mode=viins C-x a'      _expand_alias      # Expand alias
#   'mode=viins C-x e'      _expand_word       # Expand word
#
#   'mode=viins C-x d'      _list_expansions   #
#   'mode=viins C-x n'      _next_tags         # Don't use tag-order
#
#   # 'mode=viins \e/'       _history_complete_word   #
#
#   # 'mode=viins C-x ~'      _bash_list-choices #
#
# # expand-history spell-word
# # neg-argument list-expand
# # _most_recent_file  _next_tags _history-complete-newer
#
#   'mode=vicmd gC'         where-is             # Tell you the keys for an editor command
#   'mode=vicmd g?'         which-command        # Display info about a command
#   'mode=vicmd ga'         what-cursor-position
#   'mode=vicmd K'          run-help      # Open man-page
#   'mode=vicmd ='          list-choices         # List choices (i.e., alias, command, vars, etc)
#
#   # 'mode=vicmd <'          vi-up-line-or-history
#   # 'mode=vicmd >'          vi-down-line-or-history
#   # 'mode=vicmd /'        vi-history-search-backward
#   'mode=vicmd /'          history-incremental-pattern-search-backward
#
#   ';z'                    zbrowse               # Bring up zbrowse TUI
#
#   # bindkey -M vivis '+'  vi-visual-down-line
#   # bindkey -M vivis ','  vi-visual-rev-repeat-find
#   # bindkey -M vivis '0'  vi-visual-bol
#   # bindkey -M vivis ';'  vi-visual-repeat-find
#
#   'mode=viins ;gw'        efwiki
#   'mode=viins ;gq'        efnvim
#   'mode=viins ;ga'        efzsh
#
#   # "mode=str M-S-'"      ncd                # Zsh navigation tools change dir
#   # 'mode=str M-o'        lf                 # Regular lf
#   'mode=str M-o'          lc                 # Lf change dir
#   'mode=str M-S-O'        lfub               # Lf ueberzug
#   'mode=str ;o'           noptions           # Edit zsh options
#   'mode=+ M-.'            kf                 # Formarks like thing in rust
#   'mode=+ M-,'            frd                # Cd interactively recent dirs
#   'mode=+ M-;'            'fcd 4'            # Cd interactively depth 4
#   "mode=+ M-'"            fcd                # Cd interactively depth 1
#   'mode=+ M-/'            __zoxide_zi        # Cd interactively with zoxide
#   # 'mode=@ M-;'          skim-cd-widget
#   # 'mode=@ M-['            fstat
#   # 'mode=@ M-]'            fadd
#
#   'mode=menuselect Space' .accept-line
#   'mode=menuselect C-r'   history-incremental-search-backward
#   'mode=menuselect C-f'   history-incremental-search-forward
#
# # ========================== Testing ==========================
#
#   # 'mode=vicmd ;d'   dirstack-plus  # show the directory stack
# )

# ]]] keymaps array reference
