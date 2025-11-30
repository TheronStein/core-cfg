# ~/.core/zsh/modules/widgets.zsh
# ZLE Widgets - interactive command-line widgets for enhanced shell experience

#=============================================================================
# FZF FILE SELECTOR
# Insert files into command line with preview
#=============================================================================
function widget::fzf-file-selector() {
    local selected
    selected=$(fd --type f --hidden --follow --exclude .git 2>/dev/null | \
        fzf --height 60% --reverse --multi \
            --preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}' \
            --preview-window 'right:60%:wrap' \
            --header '╭─ Files ─╮  Ctrl+A: select all  Ctrl+/: toggle preview' \
            --bind 'ctrl-/:toggle-preview' \
            --bind 'ctrl-a:toggle-all')
    
    if [[ -n "$selected" ]]; then
        # Quote filenames with spaces
        local files=("${(@f)selected}")
        LBUFFER+="${(j: :)${(q)files}}"
    fi
    zle reset-prompt
}
zle -N widget::fzf-file-selector

#=============================================================================
# FZF DIRECTORY SELECTOR
# Navigate to directory or insert path
#=============================================================================
function widget::fzf-directory-selector() {
    local selected
    selected=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | \
        fzf --height 50% --reverse \
            --preview 'eza -la --color=always --icons --group-directories-first {} 2>/dev/null | head -30' \
            --preview-window 'right:50%:wrap' \
            --header '╭─ Directories ─╮  Empty buffer: cd  With buffer: insert path')
    
    if [[ -n "$selected" ]]; then
        if [[ -z "$BUFFER" ]]; then
            cd "$selected"
            zle accept-line
        else
            LBUFFER+="${(q)selected}"
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-directory-selector

#=============================================================================
# FZF HISTORY SEARCH
# Enhanced history search with preview and copy support
#=============================================================================
function widget::fzf-history-search() {
    local selected
    setopt localoptions noglobsubst noposixbuiltins pipefail 2>/dev/null

    # Get unique history entries
    selected=$(fc -rl 1 | awk '!seen[$0]++' | \
        fzf --height 80% --reverse --tiebreak=index \
            --query "${LBUFFER}" \
            --preview 'echo {2..} | bat --style=plain --color=always -l bash' \
            --preview-window 'down:3:wrap' \
            --header '╭─ History ─╮  Ctrl+Y: copy  Enter: execute' \
            --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort')
    
    if [[ -n "$selected" ]]; then
        local num=$(echo "$selected" | awk '{print $1}')
        if [[ -n "$num" ]]; then
            zle vi-fetch-history -n $num
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-history-search

#=============================================================================
# FZF KILL PROCESS
# Interactive process killer with preview
#=============================================================================
function widget::fzf-kill-process() {
    local pids
    pids=$(ps aux | sed 1d | \
        fzf --multi --height 50% --reverse \
            --header '╭─ Processes ─╮  Select processes to kill' \
            --preview 'echo {}' \
            --preview-window 'down:3:wrap' | \
        awk '{print $2}')
    
    if [[ -n "$pids" ]]; then
        echo "$pids" | xargs -r kill -9
        zle -M "Killed: $pids"
    fi
    zle reset-prompt
}
zle -N widget::fzf-kill-process

#=============================================================================
# GIT STATUS FILE SELECTOR
# Select modified files for staging
#=============================================================================
function widget::fzf-git-status() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && {
        zle -M "Not in a git repository"
        return
    }

    local selected
    selected=$(git status --short | \
        fzf --multi --ansi --height 60% --reverse \
            --preview 'git diff --color=always -- {-1} 2>/dev/null | head -100' \
            --preview-window 'right:60%:wrap' \
            --header '╭─ Git Status ─╮  Select files' | \
        awk '{print $2}')
    
    if [[ -n "$selected" ]]; then
        LBUFFER+="$selected "
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-status

#=============================================================================
# GIT BRANCH SELECTOR
# Switch branches interactively
#=============================================================================
function widget::fzf-git-branch() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && {
        zle -M "Not in a git repository"
        return
    }

    local selected
    selected=$(git branch --all --color=always | \
        grep -v 'HEAD' | \
        fzf --ansi --height 50% --reverse \
            --preview 'git log --oneline --color=always --graph -20 $(echo {} | sed "s/.* //" | sed "s#remotes/origin/##")' \
            --preview-window 'right:50%:wrap' \
            --header '╭─ Git Branches ─╮' | \
        sed 's/.* //' | sed 's#remotes/origin/##')
    
    if [[ -n "$selected" ]]; then
        if [[ -z "$BUFFER" ]]; then
            BUFFER="git checkout $selected"
            zle accept-line
        else
            LBUFFER+="$selected"
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-branch

#=============================================================================
# GIT COMMIT BROWSER
# Browse and select commits
#=============================================================================
function widget::fzf-git-commits() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && {
        zle -M "Not in a git repository"
        return
    }

    local selected
    selected=$(git log --oneline --color=always --graph -100 | \
        fzf --ansi --no-sort --height 80% --reverse \
            --tiebreak=index \
            --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1) | head -200' \
            --preview-window 'right:60%:wrap' \
            --header '╭─ Git Commits ─╮  Ctrl+O: view full commit' \
            --bind 'ctrl-o:execute(git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1) | less -R)')
    
    if [[ -n "$selected" ]]; then
        local hash=$(echo "$selected" | grep -o "[a-f0-9]\{7,\}" | head -1)
        LBUFFER+="$hash"
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-commits

#=============================================================================
# GIT REMOTES SELECTOR
# Browse and manage remotes
#=============================================================================
function widget::fzf-git-remotes() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && {
        zle -M "Not in a git repository"
        return
    }

    local selected
    selected=$(git remote -v | awk '{print $1}' | sort -u | \
        fzf --height 40% --reverse \
            --preview 'git remote get-url {}' \
            --preview-window 'down:2:wrap' \
            --header '╭─ Git Remotes ─╮')
    
    if [[ -n "$selected" ]]; then
        LBUFFER+="$selected"
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-remotes

#=============================================================================
# TMUX SESSION SELECTOR
# Switch between tmux sessions
#=============================================================================
function widget::fzf-tmux-session() {
    local session
    
    if [[ -n "$TMUX" ]]; then
        local current=$(tmux display-message -p '#S')
        session=$(tmux list-sessions -F "#{session_name}: #{session_windows} win (#{?session_attached,attached,detached})" 2>/dev/null | \
            fzf --height 50% --reverse \
                --header "╭─ Tmux Sessions ─╮  Current: $current" \
                --preview 'tmux capture-pane -ep -t $(echo {} | cut -d: -f1) 2>/dev/null | head -30' \
                --preview-window 'right:60%:wrap' | \
            cut -d: -f1)
        
        [[ -n "$session" ]] && tmux switch-client -t "$session"
    else
        session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | \
            fzf --height 40% --reverse \
                --header "╭─ Tmux Sessions ─╮  Select to attach")
        
        if [[ -n "$session" ]]; then
            BUFFER="tmux attach -t ${(q)session}"
            zle accept-line
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-tmux-session

#=============================================================================
# TMUX WINDOW SELECTOR
# Switch between windows in current session
#=============================================================================
function widget::fzf-tmux-window() {
    [[ -z "$TMUX" ]] && { zle -M "Not in tmux"; return; }

    local selected
    selected=$(tmux list-windows -F "#{window_index}: #{window_name} #{window_flags}" | \
        fzf --height 40% --reverse \
            --header "╭─ Tmux Windows ─╮  Current: $(tmux display-message -p '#I:#W')" \
            --preview 'tmux capture-pane -ep -t :{1} 2>/dev/null | head -20' \
            --preview-window 'right:50%' | \
        cut -d: -f1)
    
    [[ -n "$selected" ]] && tmux select-window -t "$selected"
    zle reset-prompt
}
zle -N widget::fzf-tmux-window

#=============================================================================
# TMUX PANE SELECTOR
# Switch between panes
#=============================================================================
function widget::fzf-tmux-pane() {
    [[ -z "$TMUX" ]] && { zle -M "Not in tmux"; return; }

    local selected
    selected=$(tmux list-panes -F "#{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height})" | \
        fzf --height 40% --reverse \
            --header "╭─ Tmux Panes ─╮" | \
        cut -d: -f1)
    
    [[ -n "$selected" ]] && tmux select-pane -t ".$selected"
    zle reset-prompt
}
zle -N widget::fzf-tmux-pane

#=============================================================================
# YAZI FILE PICKER
# Select files with yazi and insert into command line
#=============================================================================
function widget::yazi-picker() {
    local tmp="$(mktemp -t "yazi-picker.XXXXXX")"
    yazi --chooser-file="$tmp" 2>/dev/null
    
    if [[ -s "$tmp" ]]; then
        local files=("${(@f)$(cat "$tmp")}")
        LBUFFER+="${(j: :)${(q)files}}"
    fi
    rm -f "$tmp"
    zle reset-prompt
}
zle -N widget::yazi-picker

#=============================================================================
# YAZI CD
# Navigate with yazi and cd to selected directory
#=============================================================================
function widget::yazi-cd() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi --cwd-file="$tmp" "$@" 2>/dev/null
    
    if [[ -f "$tmp" ]]; then
        local cwd="$(cat "$tmp")"
        if [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
            cd "$cwd"
        fi
    fi
    rm -f "$tmp"
    zle reset-prompt
}
zle -N widget::yazi-cd

#=============================================================================
# COMMAND PALETTE
# Quick access to common commands
#=============================================================================
function widget::command-palette() {
    local commands=(
        "edit:nvim:Open Neovim"
        "files:yazi:Open Yazi file manager"
        "git-status:git status:Show git status"
        "git-log:git log --oneline --graph -20:Git log graph"
        "git-diff:git diff:Show git diff"
        "git-branch:git branch -a:List branches"
        "docker-ps:docker ps -a:List containers"
        "docker-images:docker images:List images"
        "top:btm:System monitor"
        "ports:ss -tulpn:Listening ports"
        "disk:duf:Disk usage"
        "tree:eza -T --icons -L 3:Directory tree"
        "weather:curl wttr.in?format=3:Weather"
        "ip:curl -s ifconfig.me:Public IP"
        "history:fc -l -20:Recent history"
        "processes:procs:Process list"
        "services:systemctl --user list-units:User services"
        "journal:journalctl -f:Follow journal"
        "clear:clear && printf '\\e[3J':Clear scrollback"
    )
    
    local selected
    selected=$(printf '%s\n' "${commands[@]}" | \
        fzf --height 60% --reverse \
            --delimiter ':' \
            --with-nth 1,3 \
            --preview 'echo "Command: {2}"' \
            --preview-window 'down:2:wrap' \
            --header '╭─ Command Palette ─╮')
    
    if [[ -n "$selected" ]]; then
        local cmd=$(echo "$selected" | cut -d: -f2)
        BUFFER="$cmd"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::command-palette

#=============================================================================
# SSH HOST SELECTOR
# Interactive SSH connection
#=============================================================================
function widget::fzf-ssh() {
    local host
    host=$(grep -E "^Host [^*]" ~/.ssh/config 2>/dev/null | awk '{print $2}' | \
        fzf --height 40% --reverse \
            --header '╭─ SSH Hosts ─╮' \
            --preview 'grep -A 10 "^Host {}[[:space:]]*$" ~/.ssh/config 2>/dev/null | head -12')
    
    if [[ -n "$host" ]]; then
        BUFFER="ssh $host"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::fzf-ssh

#=============================================================================
# ENVIRONMENT VARIABLE BROWSER
# Browse and insert environment variables
#=============================================================================
function widget::fzf-env() {
    local selected
    selected=$(env | sort | \
        fzf --height 60% --reverse \
            --header '╭─ Environment Variables ─╮' \
            --preview 'echo {} | cut -d= -f2-' \
            --preview-window 'down:3:wrap')
    
    if [[ -n "$selected" ]]; then
        local var=$(echo "$selected" | cut -d= -f1)
        LBUFFER+="\${$var}"
    fi
    zle reset-prompt
}
zle -N widget::fzf-env

#=============================================================================
# EDIT COMMAND IN NEOVIM
# Open current buffer in nvim for complex editing
#=============================================================================
function widget::edit-command-nvim() {
    local tmpfile=$(mktemp -t "zsh-edit.XXXXXX.sh")
    echo "$BUFFER" > "$tmpfile"
    ${EDITOR:-nvim} "$tmpfile"
    BUFFER=$(cat "$tmpfile")
    rm -f "$tmpfile"
    zle reset-prompt
}
zle -N widget::edit-command-nvim

#=============================================================================
# NEOVIM RECENT FILES
# Open recent files from nvim oldfiles
#=============================================================================
function widget::nvim-recent-files() {
    local file
    file=$(nvim --headless -c 'echo join(v:oldfiles, "\n")' -c 'q' 2>&1 | \
        grep -v '^$' | head -50 | \
        fzf --height 50% --reverse \
            --header '╭─ Recent Files ─╮' \
            --preview 'bat --style=numbers --color=always {} 2>/dev/null | head -30')
    
    if [[ -n "$file" && -f "$file" ]]; then
        BUFFER="nvim ${(q)file}"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::nvim-recent-files

#=============================================================================
# ZOXIDE INTERACTIVE
# Jump to directories with zoxide
#=============================================================================
function widget::zoxide-interactive() {
    local result
    result=$(zoxide query -l 2>/dev/null | \
        fzf --height 50% --reverse \
            --header '╭─ Zoxide Directories ─╮' \
            --preview 'eza -la --color=always --icons {} 2>/dev/null | head -20' \
            --preview-window 'right:50%' \
            --tiebreak=index)
    
    if [[ -n "$result" ]]; then
        cd "$result"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::zoxide-interactive

#=============================================================================
# CLEAR SCROLLBACK
# Clear terminal and scrollback buffer
#=============================================================================
function widget::clear-scrollback() {
    clear
    printf '\033[3J'
    zle reset-prompt
}
zle -N widget::clear-scrollback

#=============================================================================
# TOGGLE SUDO PREFIX
# Add or remove sudo from command
#=============================================================================
function widget::toggle-sudo() {
    if [[ "$BUFFER" == sudo\ * ]]; then
        BUFFER="${BUFFER#sudo }"
    else
        BUFFER="sudo $BUFFER"
    fi
    zle end-of-line
}
zle -N widget::toggle-sudo

#=============================================================================
# CLIPBOARD OPERATIONS
#=============================================================================
function widget::copy-buffer() {
    if command -v wl-copy &>/dev/null; then
        echo -n "$BUFFER" | wl-copy
    elif command -v xclip &>/dev/null; then
        echo -n "$BUFFER" | xclip -selection clipboard
    fi
    zle -M "Copied to clipboard"
}
zle -N widget::copy-buffer

function widget::paste-clipboard() {
    local content
    if command -v wl-paste &>/dev/null; then
        content=$(wl-paste 2>/dev/null)
    elif command -v xclip &>/dev/null; then
        content=$(xclip -selection clipboard -o 2>/dev/null)
    fi
    LBUFFER+="$content"
    zle reset-prompt
}
zle -N widget::paste-clipboard

function widget::cut-buffer() {
    widget::copy-buffer
    BUFFER=""
    zle reset-prompt
}
zle -N widget::cut-buffer

#=============================================================================
# BOOKMARK DIRECTORY
# Save current directory for quick access
#=============================================================================
function widget::bookmark-directory() {
    local bookmark_file="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/bookmarks"
    mkdir -p "${bookmark_file:h}"
    
    if ! grep -qF "$PWD" "$bookmark_file" 2>/dev/null; then
        echo "$PWD" >> "$bookmark_file"
        zle -M "Bookmarked: $PWD"
    else
        zle -M "Already bookmarked"
    fi
    zle reset-prompt
}
zle -N widget::bookmark-directory

#=============================================================================
# JUMP TO BOOKMARK
# Navigate to bookmarked directory
#=============================================================================
function widget::jump-bookmark() {
    local bookmark_file="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/bookmarks"
    [[ ! -f "$bookmark_file" ]] && { zle -M "No bookmarks"; return; }
    
    local selected
    selected=$(cat "$bookmark_file" | \
        fzf --height 50% --reverse \
            --header '╭─ Bookmarks ─╮' \
            --preview 'eza -la --color=always --icons {} 2>/dev/null | head -20' \
            --preview-window 'right:50%')
    
    if [[ -n "$selected" && -d "$selected" ]]; then
        cd "$selected"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::jump-bookmark

#=============================================================================
# TEXT INSERTION WIDGETS
#=============================================================================
function widget::insert-date() {
    LBUFFER+="$(date '+%Y-%m-%d')"
    zle reset-prompt
}
zle -N widget::insert-date

function widget::insert-timestamp() {
    LBUFFER+="$(date '+%Y-%m-%d %H:%M:%S')"
    zle reset-prompt
}
zle -N widget::insert-timestamp

function widget::insert-uuid() {
    LBUFFER+="$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)"
    zle reset-prompt
}
zle -N widget::insert-uuid

#=============================================================================
# CALCULATOR
# Evaluate mathematical expression in buffer
#=============================================================================
function widget::calculator() {
    if [[ -n "$BUFFER" ]]; then
        local result=$(echo "$BUFFER" | bc -l 2>/dev/null)
        if [[ -n "$result" ]]; then
            BUFFER="$result"
            zle -M "= $result"
        fi
    else
        zle -M "Enter expression first"
    fi
    zle reset-prompt
}
zle -N widget::calculator

#=============================================================================
# QUICK NOTE
# Quickly save a note with timestamp
#=============================================================================
function widget::quick-note() {
    local note_dir="${XDG_DATA_HOME:-$HOME/.local/share}/notes"
    mkdir -p "$note_dir"
    local note_file="$note_dir/$(date +%Y-%m-%d).md"
    
    local note
    vared -p "Note: " note
    
    if [[ -n "$note" ]]; then
        echo "- [$(date +%H:%M)] $note" >> "$note_file"
        zle -M "Note saved to $note_file"
    fi
    zle reset-prompt
}
zle -N widget::quick-note

#=============================================================================
# EXPAND ALIAS
# Expand alias under cursor
#=============================================================================
function widget::expand-alias() {
    zle _expand_alias
    zle expand-word
}
zle -N widget::expand-alias
