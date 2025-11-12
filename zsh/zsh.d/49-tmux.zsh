# Tmux integration

if (( $+commands[tmux] )); then
    # Attach or create session
    function tm() {
        [[ -n "$TMUX" ]] && return 1
        
        local session=${1:-main}
        tmux attach-session -t "$session" 2>/dev/null || \
        tmux new-session -s "$session"
    }
    
    # Kill session
    function tmk() {
        local session=${1:-$(tmux display-message -p '#S')}
        tmux kill-session -t "$session"
    }
    
    # List sessions with preview
    function tml() {
        tmux list-sessions -F "#{session_name}: #{session_windows} windows" 2>/dev/null
    }
    
    # Switch session with fzf
    if (( $+commands[fzf] )); then
        function tms() {
            local session
            session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf)
            [[ -n "$session" ]] && tmux switch-client -t "$session"
        }
    fi
fi
