# ~/.core/zsh/03-widgets.zsh
# ZLE (Zsh Line Editor) Widgets - custom interactive command-line widgets
# ~/.config/zsh/widgets/universal-fzf-overlay.zsh

widget::universal-overlay() {
  local choice

  choice=$(printf '%s\n' \
    "Files           :: Find & insert file" \
    "Directories     :: Find & cd/insert directory" \
    "History         :: Enhanced history search" \
    "Kill Process    :: Fuzzy kill processes" \
    "Git Status      :: Select changed files" \
    "Git Branch      :: Checkout branch" \
    "Git Commits     :: Browse & insert commit" \
    "Tmux Sessions   :: Switch/attach session" \
    "Tmux Windows    :: Switch window" \
    "SSH Hosts       :: Connect to host" \
    "Env Vars        :: Insert environment variable" \
    "Command Palette :: Run common commands" \
    "Yazi Picker     :: Choose files via Yazi" \
    "Yazi CD         :: Change dir via Yazi" \
    "Bookmarks       :: Jump to bookmarked dir" \
    "Quick Note      :: Add timestamped note" \
    "Calculator      :: Evaluate expression" \
  | fzf \
      --height=100% \
      --reverse \
      --border=rounded \
      --border-label=" Universal Command Palette " \
      --prompt="Action ❯ " \
      --preview='echo "Select an action above"' \
      --preview-window=down:1:wrap \
      --color="$(_fzf_colors)")

  [[ -z "$choice" ]] && return

  case "$choice" in
    "Files           :: "*)
      selected=$(fd --type f --hidden --follow --exclude .git | fzf $(_fzf_base_opts) --preview 'bat --style=numbers --color=always {}')
      [[ -n "$selected" ]] && LBUFFER+="${(q)selected}"
      ;;
    "Directories     :: "*)
      selected=$(fd --type d --hidden --follow --exclude .git | fzf $(_fzf_base_opts) --preview 'eza -la --color=always --icons {}')
      [[ -n "$selected" ]] && { [[ -z "$BUFFER" ]] && cd "$selected" || LBUFFER+="${(q)selected}" }
      ;;
    "History         :: "*)
      selected=$(fc -rl 1 | awk '!seen[$0]++' | fzf $(_fzf_base_opts) --tiebreak=index --preview 'echo {2..}' --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort')
      [[ -n "$selected" ]] && zle vi-fetch-history -n $(echo "$selected" | awk '{print $1}')
      ;;
    "Kill Process    :: "*)
      pid=$(ps aux | sed 1d | fzf $(_fzf_base_opts) -m --preview 'echo {}' | awk '{print $2}')
      [[ -n "$pid" ]] && echo "$pid" | xargs -r kill -9
      ;;
    "Git Status      :: "*)
      git rev-parse --is-inside-work-tree >/dev/null || return
      selected=$(git status --short | fzf $(_fzf_base_opts) -m --ansi --preview 'git diff --color=always -- {-1} | delta' | awk '{print $2}')
      [[ -n "$selected" ]] && LBUFFER+="$selected"
      ;;
    "Git Branch      :: "*)
      git rev-parse --is-inside-work-tree >/dev/null || return
      branch=$(git branch --all --color=always | grep -v HEAD | fzf $(_fzf_base_opts) --ansi --preview 'git log --oneline --graph $(echo {} | sed "s/.* //")' | sed 's/.* //;s#remotes/origin/##')
      [[ -n "$branch" ]] && { [[ -z "$BUFFER" ]] && git checkout "$branch" || LBUFFER+="$branch" }
      ;;
    # … add the rest exactly like your old widgets …
    "Quick Note      :: "*)
      local note; vared -p "Note: " note
      [[ -n "$note" ]] && echo "- [$(date +%H:%M)] $note" >> "${XDG_DATA_HOME:-$HOME/.local/share}/notes/$(date +%Y-%m-%d).md"
      zle -M "Note saved"
      ;;
    *)
      zle -M "Not implemented yet: $choice"
      ;;
  esac

  zle reset-prompt
}

zle -N widget::universal-overlay
# NOTE: Keybinding moved to zvm_after_init to avoid conflicts with zsh-vi-mode
# See 02-zinit.zsh for the zvm_after_init_commands configuration

#=============================================================================
# WIDGET: FZF-POWERED FILE SELECTOR
# Usage: Ctrl+F to fuzzy-find files and insert at cursor
#=============================================================================
function widget::fzf-file-selector() {
    local selected
    selected=$(fd --type f --hidden --follow --exclude .git 2>/dev/null | \
        fzf $(_fzf_base_opts) --height 40% \
            --preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}')

    if [[ -n "$selected" ]]; then
        LBUFFER+="${(q)selected}"
    fi
    zle reset-prompt
}
zle -N widget::fzf-file-selector

#=============================================================================
# WIDGET: FZF-POWERED DIRECTORY SELECTOR
# Usage: Ctrl+D to fuzzy-find directories and cd or insert
#=============================================================================
function widget::fzf-directory-selector() {
    local selected
    selected=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | \
        fzf $(_fzf_base_opts) --height 40% \
            --preview 'eza -la --color=always --icons {} 2>/dev/null')

    if [[ -n "$selected" ]]; then
        if [[ -z "$BUFFER" ]]; then
            # Empty buffer: cd to directory
            cd "$selected"
            zle accept-line
        else
            # Non-empty buffer: insert path
            LBUFFER+="${(q)selected}"
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-directory-selector

#=============================================================================
# WIDGET: FZF HISTORY SEARCH WITH PREVIEW
# Usage: Ctrl+R for enhanced history search
#=============================================================================
function widget::fzf-history-search() {
    local selected num
    setopt localoptions noglobsubst noposixbuiltins pipefail 2>/dev/null

    selected=$(fc -rl 1 | awk '!seen[$0]++' | \
        fzf $(_fzf_base_opts) --height 80% --tiebreak=index \
            --query "${LBUFFER}" \
            --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort' \
            --header 'Ctrl-Y: copy to clipboard' \
            --preview 'echo {2..} | bat --style=plain --color=always -l bash' \
            --preview-window 'down:3:wrap')

    if [[ -n "$selected" ]]; then
        num=$(echo "$selected" | awk '{print $1}')
        if [[ -n "$num" ]]; then
            zle vi-fetch-history -n $num
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-history-search

#=============================================================================
# WIDGET: PROCESS KILLER
# Usage: Ctrl+K to fuzzy-find and kill processes
#=============================================================================
function widget::fzf-kill-process() {
    local pid
    pid=$(ps aux | sed 1d | fzf $(_fzf_base_opts) --multi --height 40% \
        --header 'Select process(es) to kill' \
        --preview 'echo {}' \
        --preview-window 'down:3:wrap' | \
        awk '{print $2}')

    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs -r kill -9
        zle send-break
    fi
    zle reset-prompt
}
zle -N widget::fzf-kill-process

#=============================================================================
# WIDGET: GIT STATUS SELECTOR
# Usage: Ctrl+G to select git files
#=============================================================================
function widget::fzf-git-status() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && return

    local selected
    selected=$(git status --short | \
        fzf $(_fzf_base_opts) --multi --ansi --height 60% \
            --preview 'git diff --color=always -- {-1} | delta' \
            --header 'Select files to add to buffer' | \
        awk '{print $2}')

    if [[ -n "$selected" ]]; then
        LBUFFER+="${selected}"
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-status

#=============================================================================
# WIDGET: GIT BRANCH SELECTOR
# Usage: Ctrl+B to switch git branches
#=============================================================================
function widget::fzf-git-branch() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && return

    local selected
    selected=$(git branch --all --color=always | \
        grep -v 'HEAD' | \
        fzf $(_fzf_base_opts) --ansi --height 40% \
            --preview 'git log --oneline --color=always --graph $(echo {} | sed "s/.* //")' | \
        sed 's/.* //' | sed 's#remotes/origin/##')

    if [[ -n "$selected" ]]; then
        if [[ -z "$BUFFER" ]]; then
            git checkout "$selected"
            zle accept-line
        else
            LBUFFER+="$selected"
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-branch

#=============================================================================
# WIDGET: GIT COMMIT BROWSER
# Usage: Ctrl+Alt+C to browse commits
#=============================================================================
function widget::fzf-git-commits() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && return

    local selected
    selected=$(git log --oneline --color=always --graph | \
        fzf $(_fzf_base_opts) --ansi --no-sort --height 80% \
            --tiebreak=index \
            --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1)' \
            --bind 'ctrl-o:execute(git show --color=always $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1) | less -R)')

    if [[ -n "$selected" ]]; then
        local hash=$(echo "$selected" | grep -o "[a-f0-9]\{7\}" | head -1)
        LBUFFER+="$hash"
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-commits

#=============================================================================
# WIDGET: TMUX SESSION SELECTOR
# Usage: Ctrl+T to select/create tmux sessions
#=============================================================================
function widget::fzf-tmux-session() {
    local session

    if [[ -n "$TMUX" ]]; then
        session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" 2>/dev/null | \
            fzf $(_fzf_base_opts) --height 40% \
                --header "Current: $(tmux display-message -p '#S')" \
                --preview 'tmux capture-pane -ep -t $(echo {} | cut -d: -f1) 2>/dev/null' | \
            cut -d: -f1)

        if [[ -n "$session" ]]; then
            tmux switch-client -t "$session"
        fi
    else
        session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | \
            fzf $(_fzf_base_opts) --height 40% \
                --header "Select session to attach" | \
            cut -d: -f1)

        if [[ -n "$session" ]]; then
            BUFFER="tmux attach -t ${(q)session}"
            zle accept-line
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-tmux-session

#=============================================================================
# WIDGET: TMUX WINDOW SELECTOR
# Usage: Ctrl+W to select tmux windows
#=============================================================================
function widget::fzf-tmux-window() {
    [[ -z "$TMUX" ]] && return

    local selected
    selected=$(tmux list-windows -F "#{window_index}: #{window_name} #{window_flags}" | \
        fzf $(_fzf_base_opts) --height 40% \
            --header "Current: $(tmux display-message -p '#I:#W')" | \
        cut -d: -f1)

    if [[ -n "$selected" ]]; then
        tmux select-window -t "$selected"
    fi
    zle reset-prompt
}
zle -N widget::fzf-tmux-window

#=============================================================================
# WIDGET: COMMAND PALETTE (run common commands)
# Usage: Ctrl+P for command palette
#=============================================================================
function widget::command-palette() {
    local commands=(
        "edit:nvim:Open Neovim"
        "files:yazi:Open Yazi file manager"
        "git-status:git status:Show git status"
        "git-log:git log --oneline -20:Show recent commits"
        "git-diff:git diff:Show git diff"
        "docker-ps:docker ps -a:List Docker containers"
        "docker-images:docker images:List Docker images"
        "ports:ss -tulpn:Show listening ports"
        "disk:df -h:Show disk usage"
        "memory:free -h:Show memory usage"
        "processes:procs:Show processes"
        "system:btm:Open system monitor"
        "update:paru -Syu:System update"
        "clean:paru -Sc:Clean package cache"
        "orphans:paru -Qtdq:List orphan packages"
    )

    local selected
    selected=$(printf '%s\n' "${commands[@]}" | \
        fzf $(_fzf_base_opts) --height 50% \
            --delimiter ':' \
            --with-nth 1,3 \
            --preview 'echo "Command: $(echo {} | cut -d: -f2)"' \
            --preview-window 'down:1:wrap')

    if [[ -n "$selected" ]]; then
        local cmd=$(echo "$selected" | cut -d: -f2)
        BUFFER="$cmd"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::command-palette

#=============================================================================
# WIDGET: SSH HOST SELECTOR
# Usage: Alt+S to select SSH hosts
#=============================================================================
function widget::fzf-ssh() {
    local host
    host=$(grep -E "^Host [^*]" ~/.ssh/config 2>/dev/null | awk '{print $2}' | \
        fzf $(_fzf_base_opts) --height 40% \
            --header "Select SSH host" \
            --preview 'grep -A 10 "^Host {}" ~/.ssh/config 2>/dev/null')

    if [[ -n "$host" ]]; then
        BUFFER="ssh ${host}"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::fzf-ssh

#=============================================================================
# WIDGET: ENVIRONMENT VARIABLE BROWSER
# Usage: Alt+E to browse/insert env vars
#=============================================================================
function widget::fzf-env() {
    local selected
    selected=$(env | sort | \
        fzf $(_fzf_base_opts) --height 60% \
            --header "Select environment variable" \
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
# WIDGET: EDIT COMMAND IN EDITOR
# Usage: Ctrl+X Ctrl+E to edit in $EDITOR
#=============================================================================
function widget::edit-command() {
    local tmpfile=$(mktemp)
    echo "$BUFFER" > "$tmpfile"
    ${EDITOR:-nvim} "$tmpfile"
    BUFFER=$(cat "$tmpfile")
    rm -f "$tmpfile"
    zle reset-prompt
}
zle -N widget::edit-command

#=============================================================================
# WIDGET: CLEAR SCREEN AND SCROLLBACK
# Usage: Ctrl+L (enhanced)
#=============================================================================
function widget::clear-scrollback() {
    clear
    printf '\033[3J'  # Clear scrollback
    zle reset-prompt
}
zle -N widget::clear-scrollback

#=============================================================================
# WIDGET: INSERT LAST COMMAND OUTPUT
# Usage: Alt+. to insert previous command's output
#=============================================================================
function widget::insert-last-output() {
    LBUFFER+="$(fc -e - -1 2>/dev/null)"
    zle reset-prompt
}
zle -N widget::insert-last-output

#=============================================================================
# WIDGET: TOGGLE SUDO PREFIX
# Usage: Escape Escape to toggle sudo
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
# WIDGET: YAZI FILE PICKER
# Usage: Alt+Y to open yazi and insert selected files
#=============================================================================
function widget::yazi-picker() {
    local tmp="$(mktemp)"
    yazi --chooser-file="$tmp"
    if [[ -s "$tmp" ]]; then
        local selected=$(cat "$tmp" | tr '\n' ' ')
        LBUFFER+="$selected"
    fi
    rm -f "$tmp"
    zle reset-prompt
}
zle -N widget::yazi-picker

#=============================================================================
# WIDGET: YAZI CD (change to yazi's cwd on exit)
# Usage: Alt+Y in shell to use yazi for navigation
#=============================================================================
function widget::yazi-cd() {
    local tmp="$(mktemp)"
    yazi --cwd-file="$tmp"
    if [[ -f "$tmp" ]]; then
        local cwd=$(cat "$tmp")
        if [[ -d "$cwd" && "$cwd" != "$PWD" ]]; then
            cd "$cwd"
        fi
    fi
    rm -f "$tmp"
    zle reset-prompt
}
zle -N widget::yazi-cd

#=============================================================================
# WIDGET: COPY BUFFER TO CLIPBOARD
# Usage: Alt+C to copy command line to clipboard
#=============================================================================
function widget::copy-buffer() {
    if command -v wl-copy &>/dev/null; then
        echo -n "$BUFFER" | wl-copy
        zle -M "Copied to clipboard"
    elif command -v xclip &>/dev/null; then
        echo -n "$BUFFER" | xclip -selection clipboard
        zle -M "Copied to clipboard"
    fi
}
zle -N widget::copy-buffer

#=============================================================================
# WIDGET: PASTE FROM CLIPBOARD
# Usage: Alt+V to paste from clipboard
#=============================================================================
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

#=============================================================================
# WIDGET: QUICK CALCULATOR
# Usage: Alt+= to evaluate math expression
#=============================================================================
function widget::calculator() {
    if [[ -n "$BUFFER" ]]; then
        local result=$(echo "$BUFFER" | bc -l 2>/dev/null)
        if [[ -n "$result" ]]; then
            BUFFER="$result"
        fi
    else
        zle -M "Enter expression first"
    fi
    zle reset-prompt
}
zle -N widget::calculator

#=============================================================================
# WIDGET: EXPAND ALIAS UNDER CURSOR
# Usage: Ctrl+Space to expand alias
#=============================================================================
function widget::expand-alias() {
    zle _expand_alias
    zle expand-word
}
zle -N widget::expand-alias

#=============================================================================
# WIDGET: QUICK NOTE
# Usage: Alt+N to quickly save a note
#=============================================================================
function widget::quick-note() {
    local note_dir="${CORE}/.notes"
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
# WIDGET: BITWARDEN
# Usage: Alt+B to open Bitwarden interactive menu
#=============================================================================
function widget::bitwarden() {
    bw::interactive
    zle reset-prompt
}
zle -N widget::bitwarden

#=============================================================================
# WIDGET: JUMP TO BOOKMARK
# Usage: Alt+J to jump to bookmarked directory
#=============================================================================
function widget::jump-bookmark() {
    local bookmark_file="${XDG_DATA_HOME}/zsh/bookmarks"
    [[ ! -f "$bookmark_file" ]] && { zle -M "No bookmarks"; return; }

    local selected
    selected=$(cat "$bookmark_file" | \
        fzf $(_fzf_base_opts) --height 40% \
            --preview 'eza -la --color=always --icons {}')

    if [[ -n "$selected" && -d "$selected" ]]; then
        cd "$selected"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::jump-bookmark

#=============================================================================
# WIDGET: INSERT TIMESTAMP
# Usage: Alt+T to insert current timestamp
#=============================================================================
function widget::insert-timestamp() {
    LBUFFER+="$(date '+%Y-%m-%d %H:%M:%S')"
}
zle -N widget::insert-timestamp

#=============================================================================
# WIDGET: INSERT DATE
# Usage: Alt+D to insert current date
#=============================================================================
function widget::insert-date() {
    LBUFFER+="$(date '+%Y-%m-%d')"
}
zle -N widget::insert-date
