# ~/.core/zsh/modules/docker.zsh
# Docker Integration - container management, compose helpers, and shortcuts

#=============================================================================
# CHECK FOR DOCKER
#=============================================================================
(( $+commands[docker] )) || return 0

#=============================================================================
# ENVIRONMENT
#=============================================================================
export DOCKER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/docker"
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

#=============================================================================
# BASE ALIASES
#=============================================================================
alias d='docker'
alias dc='docker compose'

#=============================================================================
# CONTAINER MANAGEMENT
#=============================================================================
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpsq='docker ps -q'
alias dpsl='docker ps -l'
alias dstart='docker start'
alias dstop='docker stop'
alias drestart='docker restart'
alias drm='docker rm'
alias drmf='docker rm -f'
alias dkill='docker kill'
alias dpause='docker pause'
alias dunpause='docker unpause'
alias dwait='docker wait'

# Stop all containers
alias dsa='docker stop $(docker ps -q)'

# Remove all stopped containers
alias drma='docker rm $(docker ps -qa --filter status=exited)'

# Remove all containers
alias drmall='docker rm -f $(docker ps -qa)'

#=============================================================================
# IMAGE MANAGEMENT
#=============================================================================
alias di='docker images'
alias dia='docker images -a'
alias drmi='docker rmi'
alias drmif='docker rmi -f'
alias dpull='docker pull'
alias dpush='docker push'
alias dbuild='docker build'
alias dtag='docker tag'
alias dsave='docker save'
alias dload='docker load'
alias dhist='docker history'
alias dinsp='docker inspect'

# Remove dangling images
alias drmi-dangling='docker rmi $(docker images -f "dangling=true" -q)'

# Remove all images
alias drmi-all='docker rmi -f $(docker images -q)'

#=============================================================================
# EXEC/ATTACH
#=============================================================================
alias dex='docker exec -it'
alias dexb='docker exec -it bash'
alias dexs='docker exec -it sh'
alias datt='docker attach'

#=============================================================================
# LOGS
#=============================================================================
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias dlogt='docker logs --tail'

#=============================================================================
# DOCKER COMPOSE
#=============================================================================
alias dcup='docker compose up'
alias dcupd='docker compose up -d'
alias dcupb='docker compose up --build'
alias dcupbd='docker compose up --build -d'
alias dcdn='docker compose down'
alias dcdnv='docker compose down -v'
alias dcstart='docker compose start'
alias dcstop='docker compose stop'
alias dcrestart='docker compose restart'
alias dcps='docker compose ps'
alias dclogs='docker compose logs'
alias dclogsf='docker compose logs -f'
alias dcex='docker compose exec'
alias dcbuild='docker compose build'
alias dcpull='docker compose pull'
alias dcconfig='docker compose config'
alias dcrun='docker compose run --rm'
alias dcrm='docker compose rm'
alias dctop='docker compose top'

#=============================================================================
# SYSTEM/CLEANUP
#=============================================================================
alias dinfo='docker info'
alias dversion='docker version'
alias ddf='docker system df'
alias dprune='docker system prune'
alias dprunea='docker system prune -af'
alias dprunev='docker system prune -af --volumes'
alias dvprune='docker volume prune'
alias dnprune='docker network prune'
alias diprune='docker image prune'

#=============================================================================
# NETWORK
#=============================================================================
alias dn='docker network'
alias dnls='docker network ls'
alias dnrm='docker network rm'
alias dncreate='docker network create'
alias dninsp='docker network inspect'
alias dncon='docker network connect'
alias dndis='docker network disconnect'

#=============================================================================
# VOLUME
#=============================================================================
alias dv='docker volume'
alias dvls='docker volume ls'
alias dvrm='docker volume rm'
alias dvcreate='docker volume create'
alias dvinsp='docker volume inspect'

#=============================================================================
# FUNCTIONS
#=============================================================================

# Shell into container (auto-detect shell)
function dsh() {
    local container="$1"
    local shell="${2:-}"
    
    if [[ -z "$shell" ]]; then
        # Try bash, then sh
        docker exec -it "$container" bash 2>/dev/null || \
        docker exec -it "$container" sh
    else
        docker exec -it "$container" "$shell"
    fi
}

# Interactive container selector for exec
function dexf() {
    local container
    container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | tail -n +2 | \
        fzf --header '╭─ Select container ─╮' | \
        awk '{print $1}')
    
    if [[ -n "$container" ]]; then
        dsh "$container" "$@"
    fi
}

# Interactive log viewer
function dlogf() {
    local container
    container=$(docker ps --format "{{.Names}}" | \
        fzf --header '╭─ Select container ─╮')
    
    [[ -n "$container" ]] && docker logs -f "$container"
}

# Run with auto-remove
function drun() {
    docker run -it --rm "$@"
}

# Run with volume mount
function drunv() {
    local image="$1"
    shift
    docker run -it --rm -v "$(pwd):/app" -w /app "$image" "$@"
}

# Inspect container JSON
function dinspf() {
    local container
    container=$(docker ps -a --format "{{.Names}}" | \
        fzf --header '╭─ Select container ─╮')
    
    [[ -n "$container" ]] && docker inspect "$container" | jq '.'
}

# Get container IP
function dip() {
    local container="${1:-}"
    
    if [[ -z "$container" ]]; then
        container=$(docker ps --format "{{.Names}}" | fzf)
    fi
    
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container"
}

# Container stats
function dstats() {
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
}

# Live stats
function dstatsl() {
    docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
}

# Container resource usage summary
function dres() {
    echo "╭─ Docker Resource Usage ─╮"
    docker system df
    echo ""
    echo "Running containers: $(docker ps -q | wc -l)"
    echo "All containers: $(docker ps -aq | wc -l)"
    echo "Images: $(docker images -q | wc -l)"
    echo "Volumes: $(docker volume ls -q | wc -l)"
    echo "Networks: $(docker network ls -q | wc -l)"
    echo "╰──────────────────────────╯"
}

# Copy file from container
function dcpf() {
    local container="$1"
    local src="$2"
    local dest="${3:-.}"
    docker cp "$container:$src" "$dest"
}

# Copy file to container
function dcpt() {
    local src="$1"
    local container="$2"
    local dest="$3"
    docker cp "$src" "$container:$dest"
}

# Build with custom tag
function dbuildt() {
    local tag="${1:-latest}"
    shift
    docker build -t "$tag" "$@" .
}

# Follow container logs with timestamp
function dlogts() {
    docker logs -f --timestamps "$1"
}

# Interactive image selector for run
function drunf() {
    local image
    image=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | tail -n +2 | \
        fzf --header '╭─ Select image ─╮' | \
        awk '{print $1}')
    
    [[ -n "$image" ]] && docker run -it --rm "$image" "$@"
}

# Clean everything
function dclean() {
    echo "Stopping all containers..."
    docker stop $(docker ps -q) 2>/dev/null
    
    echo "Removing all containers..."
    docker rm $(docker ps -aq) 2>/dev/null
    
    echo "Removing dangling images..."
    docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null
    
    echo "Removing unused volumes..."
    docker volume prune -f
    
    echo "Removing unused networks..."
    docker network prune -f
    
    echo "Done!"
    dres
}

# Docker compose project selector
function dcf() {
    local dir
    dir=$(fd -t f 'docker-compose\.ya?ml|compose\.ya?ml' --max-depth 3 | \
        xargs -I {} dirname {} | sort -u | \
        fzf --header '╭─ Select compose project ─╮' \
            --preview 'cat {}/docker-compose.yml 2>/dev/null || cat {}/compose.yml')
    
    if [[ -n "$dir" ]]; then
        cd "$dir"
        docker compose ps
    fi
}

#=============================================================================
# LAZYDOCKER INTEGRATION
#=============================================================================
if (( $+commands[lazydocker] )); then
    alias lzd='lazydocker'
fi

#=============================================================================
# COMPLETIONS
#=============================================================================
# Docker completion is usually provided by docker itself
# Ensure it's loaded
if [[ -f /usr/share/zsh/site-functions/_docker ]]; then
    source /usr/share/zsh/site-functions/_docker
fi
