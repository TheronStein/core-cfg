# ~/.core/zsh/modules/widgets-advanced.zsh
# Advanced ZLE Widgets for system management, development workflows, and productivity
# Dependencies: fzf, systemctl, docker, wl-clipboard, jq

#=============================================================================
# SYSTEMD MANAGEMENT WIDGETS
#=============================================================================

# Widget: systemd-unit-manager
# Description: Comprehensive systemd unit management
# Keybinding suggestion: Ctrl+Alt+S
function widget::systemd-unit-manager() {
    local unit action
    local unit_types="service timer socket mount path"

    # Select unit type
    local unit_type=$(echo "$unit_types" | tr ' ' '\n' | \
        fzf --height 20% --header "Select unit type")

    [[ -z "$unit_type" ]] && { zle reset-prompt; return; }

    # List units of selected type
    unit=$(systemctl list-units --all --type="$unit_type" --no-legend | \
        fzf --height 60% \
            --preview "SYSTEMD_COLORS=1 systemctl status \$(echo {} | awk '{print \$1}')" \
            --preview-window 'right:60%:wrap' \
            --header "Select $unit_type unit" | \
        awk '{print $1}')

    [[ -z "$unit" ]] && { zle reset-prompt; return; }

    # Select action
    action=$(cat << 'EOF' | fzf --height 30% --header "Action for $unit"
status - Show unit status
start - Start the unit
stop - Stop the unit
restart - Restart the unit
reload - Reload the unit
enable - Enable at boot
disable - Disable at boot
edit - Edit unit file
logs - View logs
cat - Show unit file
dependencies - Show dependencies
failed - Show failed units
mask - Mask unit
unmask - Unmask unit
EOF
    )

    action=$(echo "$action" | cut -d' ' -f1)
    [[ -z "$action" ]] && { zle reset-prompt; return; }

    # Execute action
    case "$action" in
        edit)
            BUFFER="sudo systemctl edit $unit"
            ;;
        logs)
            BUFFER="journalctl -u $unit -f"
            ;;
        cat)
            BUFFER="systemctl cat $unit | bat -l ini"
            ;;
        dependencies)
            BUFFER="systemctl list-dependencies $unit"
            ;;
        failed)
            BUFFER="systemctl --failed"
            ;;
        status|start|stop|restart|reload|enable|disable|mask|unmask)
            if [[ "$action" =~ ^(start|stop|restart|reload|enable|disable|mask|unmask)$ ]]; then
                BUFFER="sudo systemctl $action $unit"
            else
                BUFFER="systemctl $action $unit"
            fi
            ;;
    esac

    zle accept-line
}
zle -N widget::systemd-unit-manager

# Widget: systemd-journal-browser
# Description: Interactive journalctl browser
# Keybinding suggestion: Ctrl+Alt+J
function widget::systemd-journal-browser() {
    local options unit since

    # Select time range
    since=$(cat << 'EOF' | fzf --height 30% --header "Select time range"
1h - Last hour
4h - Last 4 hours
1d - Last day
3d - Last 3 days
1w - Last week
1M - Last month
today - Since today
yesterday - Since yesterday
boot - Since last boot
EOF
    )

    since=$(echo "$since" | cut -d' ' -f1)
    [[ -z "$since" ]] && { zle reset-prompt; return; }

    # Build command
    local cmd="journalctl --since='$since'"

    # Optional: select specific unit
    echo -n "Filter by unit? (y/N): " | read -q && {
        echo
        unit=$(systemctl list-units --all --no-legend | \
            fzf --height 40% --header "Select unit (optional)" | \
            awk '{print $1}')
        [[ -n "$unit" ]] && cmd="$cmd -u $unit"
    }

    # Optional: select priority
    echo -n "Filter by priority? (y/N): " | read -q && {
        echo
        local priority=$(echo "emerg alert crit err warning notice info debug" | \
            tr ' ' '\n' | fzf --height 20% --header "Select priority")
        [[ -n "$priority" ]] && cmd="$cmd -p $priority"
    }

    BUFFER="$cmd -f"
    zle accept-line
}
zle -N widget::systemd-journal-browser

#=============================================================================
# DOCKER/CONTAINER WIDGETS
#=============================================================================

# Widget: docker-container-manager
# Description: Comprehensive Docker container management
# Keybinding suggestion: Ctrl+Alt+D
function widget::docker-container-manager() {
    (( $+commands[docker] )) || { zle -M "Docker not found"; return; }

    local container action

    # Select container (including stopped)
    container=$(docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | \
        fzf --header-lines=1 --height 60% \
            --preview 'docker inspect $(echo {} | awk "{print \$1}")' \
            --preview-window 'right:60%:wrap' \
            --header "Select container" | \
        awk '{print $1}')

    [[ -z "$container" ]] && { zle reset-prompt; return; }

    # Select action
    action=$(cat << 'EOF' | fzf --height 40% --header "Action for $container"
logs - View logs
exec - Execute command
start - Start container
stop - Stop container
restart - Restart container
inspect - Inspect container
stats - Show stats
port - Show port mappings
cp - Copy files
commit - Create image from container
export - Export container
rm - Remove container
top - Show processes
attach - Attach to container
pause - Pause container
unpause - Unpause container
EOF
    )

    action=$(echo "$action" | cut -d' ' -f1)
    [[ -z "$action" ]] && { zle reset-prompt; return; }

    # Execute action
    case "$action" in
        logs)
            BUFFER="docker logs -f $container"
            ;;
        exec)
            BUFFER="docker exec -it $container /bin/bash"
            ;;
        stats)
            BUFFER="docker stats $container"
            ;;
        cp)
            BUFFER="docker cp $container:"
            ;;
        commit)
            BUFFER="docker commit $container "
            ;;
        export)
            BUFFER="docker export $container > ${container}.tar"
            ;;
        attach)
            BUFFER="docker attach $container"
            ;;
        top)
            BUFFER="docker top $container"
            ;;
        *)
            BUFFER="docker $action $container"
            ;;
    esac

    zle accept-line
}
zle -N widget::docker-container-manager

# Widget: docker-image-manager
# Description: Docker image management
# Keybinding suggestion: Ctrl+Alt+I
function widget::docker-image-manager() {
    (( $+commands[docker] )) || { zle -M "Docker not found"; return; }

    local image action

    # Select image
    image=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}" | \
        fzf --header-lines=1 --height 60% \
            --preview 'docker inspect $(echo {} | awk "{print \$1}")' \
            --preview-window 'right:60%:wrap' \
            --header "Select image" | \
        awk '{print $1}')

    [[ -z "$image" ]] && { zle reset-prompt; return; }

    # Select action
    action=$(cat << 'EOF' | fzf --height 30% --header "Action for $image"
run - Run container from image
inspect - Inspect image
history - Show image history
save - Save image to tar
push - Push to registry
tag - Tag image
rmi - Remove image
EOF
    )

    action=$(echo "$action" | cut -d' ' -f1)
    [[ -z "$action" ]] && { zle reset-prompt; return; }

    # Execute action
    case "$action" in
        run)
            BUFFER="docker run -it --rm $image"
            ;;
        save)
            local name=$(echo "$image" | tr '/:' '_')
            BUFFER="docker save $image -o ${name}.tar"
            ;;
        tag)
            BUFFER="docker tag $image "
            ;;
        rmi)
            BUFFER="docker rmi $image"
            ;;
        *)
            BUFFER="docker image $action $image"
            ;;
    esac

    zle accept-line
}
zle -N widget::docker-image-manager

# Widget: docker-compose-manager
# Description: Docker Compose project management
# Keybinding suggestion: Ctrl+Alt+C
function widget::docker-compose-manager() {
    (( $+commands[docker-compose] )) || (( $+commands[docker] )) || { zle -M "Docker Compose not found"; return; }

    local compose_cmd="docker-compose"
    (( $+commands[docker] )) && docker compose version &>/dev/null && compose_cmd="docker compose"

    local action

    # Check for docker-compose.yml
    if [[ ! -f "docker-compose.yml" && ! -f "docker-compose.yaml" ]]; then
        zle -M "No docker-compose.yml found"
        return
    fi

    # Select action
    action=$(cat << 'EOF' | fzf --height 40% --header "Docker Compose Action"
up - Start services
up-d - Start services (detached)
down - Stop and remove
stop - Stop services
start - Start services
restart - Restart services
logs - View logs
ps - List containers
exec - Execute command
build - Build images
pull - Pull images
config - Validate config
top - Display processes
port - Print port binding
EOF
    )

    action=$(echo "$action" | cut -d' ' -f1)
    [[ -z "$action" ]] && { zle reset-prompt; return; }

    # Handle special cases
    case "$action" in
        up-d)
            BUFFER="$compose_cmd up -d"
            ;;
        exec)
            # Select service
            local service=$($compose_cmd ps --services | \
                fzf --height 30% --header "Select service")
            [[ -n "$service" ]] && BUFFER="$compose_cmd exec $service /bin/bash"
            ;;
        logs)
            local service=$($compose_cmd ps --services | \
                fzf --height 30% --header "Select service (optional)")
            if [[ -n "$service" ]]; then
                BUFFER="$compose_cmd logs -f $service"
            else
                BUFFER="$compose_cmd logs -f"
            fi
            ;;
        *)
            BUFFER="$compose_cmd $action"
            ;;
    esac

    [[ -n "$BUFFER" ]] && zle accept-line
}
zle -N widget::docker-compose-manager

#=============================================================================
# WORKSPACE & SESSION WIDGETS
#=============================================================================

# Widget: workspace-launcher
# Description: Launch predefined workspace layouts
# Keybinding suggestion: Ctrl+Alt+W
function widget::workspace-launcher() {
    local workspace
    local workspaces_dir="${XDG_CONFIG_HOME}/workspaces"

    # Create sample workspaces if directory doesn't exist
    if [[ ! -d "$workspaces_dir" ]]; then
        mkdir -p "$workspaces_dir"

        # Create sample workspace
        cat > "$workspaces_dir/dev.sh" << 'EOF'
#!/usr/bin/env bash
# Development workspace
tmux new-session -d -s dev -n editor
tmux split-window -h -p 30
tmux new-window -n terminal
tmux new-window -n logs
tmux select-window -t 1
EOF
        chmod +x "$workspaces_dir/dev.sh"
    fi

    # Select workspace
    workspace=$(find "$workspaces_dir" -name "*.sh" -type f | \
        fzf --preview 'cat {}' \
            --preview-window 'right:60%:wrap' \
            --header "Select workspace")

    if [[ -n "$workspace" ]]; then
        BUFFER="bash '$workspace'"
        zle accept-line
    else
        zle reset-prompt
    fi
}
zle -N widget::workspace-launcher

# Widget: session-manager
# Description: Manage shell sessions across terminals
# Keybinding suggestion: Ctrl+Alt+M
function widget::session-manager() {
    local sessions_dir="${XDG_DATA_HOME}/zsh/sessions"
    mkdir -p "$sessions_dir"

    local action
    action=$(cat << 'EOF' | fzf --height 30% --header "Session Management"
save - Save current session
restore - Restore session
list - List saved sessions
delete - Delete session
export - Export session
EOF
    )

    action=$(echo "$action" | cut -d' ' -f1)
    [[ -z "$action" ]] && { zle reset-prompt; return; }

    case "$action" in
        save)
            local name
            vared -p "Session name: " name
            if [[ -n "$name" ]]; then
                local session_file="$sessions_dir/${name}.session"
                {
                    echo "# Session: $name"
                    echo "# Date: $(date)"
                    echo "cd '$PWD'"
                    echo "export PATH='$PATH'"
                    env | grep -E '^(CORE|PROJECT|VIRTUAL_ENV)' | sed 's/^/export /'
                    fc -ln -100 | sed 's/^/# History: /'
                } > "$session_file"
                zle -M "Session saved: $name"
            fi
            ;;

        restore)
            local session
            session=$(ls "$sessions_dir"/*.session 2>/dev/null | \
                fzf --preview 'cat {}' \
                    --preview-window 'right:60%:wrap' \
                    --header "Select session to restore")

            if [[ -n "$session" ]]; then
                BUFFER="source '$session'"
                zle accept-line
            fi
            ;;

        list)
            BUFFER="ls -la '$sessions_dir'"
            zle accept-line
            ;;

        delete)
            local session
            session=$(ls "$sessions_dir"/*.session 2>/dev/null | \
                fzf --multi --header "Select sessions to delete")

            if [[ -n "$session" ]]; then
                echo "$session" | xargs rm -f
                zle -M "Sessions deleted"
            fi
            ;;

        export)
            BUFFER="tar czf sessions-$(date +%Y%m%d).tar.gz -C '$sessions_dir' ."
            zle accept-line
            ;;
    esac

    zle reset-prompt
}
zle -N widget::session-manager

#=============================================================================
# CLIPBOARD HISTORY WIDGET
#=============================================================================

# Widget: clipboard-history-manager
# Description: Manage clipboard history with persistent storage
# Keybinding suggestion: Ctrl+Alt+V
function widget::clipboard-history-manager() {
    (( $+commands[wl-paste] )) || { zle -M "wl-clipboard not found"; return; }

    local clip_dir="${XDG_DATA_HOME}/zsh/clipboard"
    local clip_file="$clip_dir/history"
    local max_entries=100

    mkdir -p "$clip_dir"
    touch "$clip_file"

    # Save current clipboard if not empty
    local current=$(wl-paste 2>/dev/null)
    if [[ -n "$current" ]]; then
        # Add to history (avoid duplicates)
        if ! grep -qF "$current" "$clip_file" 2>/dev/null; then
            echo "$current" >> "$clip_file"

            # Trim to max entries
            local tmp=$(mktemp)
            tail -n "$max_entries" "$clip_file" > "$tmp"
            mv "$tmp" "$clip_file"
        fi
    fi

    # Select from history
    local selected
    selected=$(tac "$clip_file" | \
        awk '!seen[$0]++' | \
        fzf --height 60% \
            --preview 'echo {} | head -5' \
            --preview-window 'down:3:wrap' \
            --header "Clipboard History (Enter: insert, Ctrl-Y: copy)" \
            --bind 'ctrl-y:execute-silent(echo -n {} | wl-copy)+abort')

    if [[ -n "$selected" ]]; then
        LBUFFER+="$selected"
    fi

    zle reset-prompt
}
zle -N widget::clipboard-history-manager

#=============================================================================
# NETWORK MANAGEMENT WIDGET
#=============================================================================

# Widget: network-manager
# Description: Network connection management
# Keybinding suggestion: Ctrl+Alt+N
function widget::network-manager() {
    local action

    action=$(cat << 'EOF' | fzf --height 40% --header "Network Management"
wifi-connect - Connect to WiFi
wifi-list - List WiFi networks
connections - Show connections
ports - Show listening ports
ip - Show IP addresses
dns - DNS lookup
speed - Test network speed
firewall - Firewall status
vpn - VPN management
EOF
    )

    action=$(echo "$action" | cut -d' ' -f1)
    [[ -z "$action" ]] && { zle reset-prompt; return; }

    case "$action" in
        wifi-connect)
            if (( $+commands[nmcli] )); then
                local ssid=$(nmcli device wifi list | sed 1d | \
                    fzf --height 40% --header "Select network" | \
                    sed 's/^[* ] //' | awk '{print $2}')
                [[ -n "$ssid" ]] && BUFFER="nmcli device wifi connect '$ssid'"
            else
                zle -M "nmcli not found"
            fi
            ;;

        wifi-list)
            BUFFER="nmcli device wifi list"
            ;;

        connections)
            BUFFER="nmcli connection show"
            ;;

        ports)
            BUFFER="ss -tulpn | grep LISTEN"
            ;;

        ip)
            BUFFER="ip -c addr"
            ;;

        dns)
            local domain
            vared -p "Domain to lookup: " domain
            [[ -n "$domain" ]] && BUFFER="dig +short $domain"
            ;;

        speed)
            if (( $+commands[speedtest-cli] )); then
                BUFFER="speedtest-cli"
            else
                BUFFER="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
            fi
            ;;

        firewall)
            if (( $+commands[ufw] )); then
                BUFFER="sudo ufw status verbose"
            elif (( $+commands[firewall-cmd] )); then
                BUFFER="sudo firewall-cmd --list-all"
            else
                BUFFER="sudo iptables -L -v -n"
            fi
            ;;

        vpn)
            if (( $+commands[wg] )); then
                BUFFER="sudo wg show"
            elif (( $+commands[openvpn] )); then
                BUFFER="systemctl status openvpn*"
            else
                BUFFER="nmcli connection show --active | grep vpn"
            fi
            ;;
    esac

    [[ -n "$BUFFER" ]] && zle accept-line || zle reset-prompt
}
zle -N widget::network-manager

#=============================================================================
# PROCESS MANAGEMENT WIDGET
#=============================================================================

# Widget: process-manager
# Description: Advanced process management
# Keybinding suggestion: Ctrl+Alt+P
function widget::process-manager() {
    local process action

    # Select process
    process=$(ps aux | sed 1d | \
        fzf --height 60% \
            --preview 'echo {}' \
            --preview-window 'down:3:wrap' \
            --header "Select process" | \
        awk '{print $2}')

    [[ -z "$process" ]] && { zle reset-prompt; return; }

    # Get process info
    local cmd=$(ps -p "$process" -o comm= 2>/dev/null)

    # Select action
    action=$(cat << EOF | fzf --height 30% --header "Action for PID $process ($cmd)"
kill - Kill process (SIGTERM)
kill9 - Force kill (SIGKILL)
stop - Stop process (SIGSTOP)
cont - Continue process (SIGCONT)
nice - Change priority
lsof - Show open files
strace - Trace system calls
environ - Show environment
limits - Show limits
tree - Show process tree
EOF
    )

    action=$(echo "$action" | cut -d' ' -f1)
    [[ -z "$action" ]] && { zle reset-prompt; return; }

    case "$action" in
        kill)
            BUFFER="kill $process"
            ;;
        kill9)
            BUFFER="kill -9 $process"
            ;;
        stop)
            BUFFER="kill -STOP $process"
            ;;
        cont)
            BUFFER="kill -CONT $process"
            ;;
        nice)
            local priority
            vared -p "New nice value (-20 to 19): " priority
            [[ -n "$priority" ]] && BUFFER="sudo renice $priority -p $process"
            ;;
        lsof)
            BUFFER="lsof -p $process"
            ;;
        strace)
            BUFFER="sudo strace -p $process"
            ;;
        environ)
            BUFFER="cat /proc/$process/environ | tr '\\0' '\\n'"
            ;;
        limits)
            BUFFER="cat /proc/$process/limits"
            ;;
        tree)
            BUFFER="pstree -p $process"
            ;;
    esac

    [[ -n "$BUFFER" ]] && zle accept-line || zle reset-prompt
}
zle -N widget::process-manager

#=============================================================================
# KEY BINDINGS
#=============================================================================
# System management
bindkey '^[^s' widget::systemd-unit-manager
bindkey '^[^j' widget::systemd-journal-browser

# Docker management
bindkey '^[^d' widget::docker-container-manager
bindkey '^[^i' widget::docker-image-manager
bindkey '^[^c' widget::docker-compose-manager

# Workspace & session
bindkey '^[^w' widget::workspace-launcher
bindkey '^[^m' widget::session-manager

# Utilities
bindkey '^[^v' widget::clipboard-history-manager
bindkey '^[^n' widget::network-manager
bindkey '^[^p' widget::process-manager