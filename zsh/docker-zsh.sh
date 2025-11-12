#!/usr/bin/env bash
# Script to build and run the zsh configuration testing container

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current user info (UID is readonly, so we use USER_ID)
export USER_ID=$(id -u)
export USER_GID=$(id -g)
export USERNAME=$(whoami)

print_help() {
    echo "Usage: $0 [COMMAND] [CONFIG]"
    echo ""
    echo "Commands:"
    echo "  build         - Build the Docker image"
    echo "  run [safe|main] - Run container with safe (default) or main config"
    echo "  test          - Test the safe configuration"
    echo "  test-main     - Test the main configuration"
    echo "  debug         - Run safe config with DEBUG_ZSH=1"
    echo "  debug-main    - Debug main config with verbose output"
    echo "  clean         - Remove container and volumes"
    echo "  rebuild       - Clean and rebuild everything"
    echo "  shell         - Enter running container"
    echo "  logs          - Show container logs"
    echo ""
    echo "Examples:"
    echo "  $0 run              # Start with safe config"
    echo "  $0 run main         # Start with main config (might be broken)"
    echo "  $0 test-main        # Test if main config loads"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
}

build_image() {
    echo -e "${GREEN}Building Docker image...${NC}"

    # Create necessary directories
    mkdir -p docker-exports

    docker-compose build --build-arg UID=$USER_ID --build-arg GID=$USER_GID --build-arg USERNAME=$USERNAME
}

run_container() {
    local config="${2:-safe}"
    echo -e "${GREEN}Starting zsh configuration test container (config: $config)...${NC}"

    if [[ "$config" == "main" ]]; then
        ZDOTDIR=/home/$USERNAME/.core/cfg/zsh ZSH_CONFIG=main docker-compose up -d
    else
        ZSH_CONFIG=safe docker-compose up -d
    fi

    docker-compose exec zsh-env zsh -i -l
}

test_config() {
    echo -e "${YELLOW}Testing safe zsh configuration...${NC}"
    docker-compose run --rm zsh-env zsh -d -f -c 'source $ZDOTDIR/.zshenv && source $ZDOTDIR/.zshrc && echo "Safe configuration loaded successfully"'
}

test_main_config() {
    echo -e "${YELLOW}Testing main zsh configuration...${NC}"
    ZDOTDIR=/home/$USERNAME/.core/cfg/zsh docker-compose run --rm zsh-env zsh -d -f -c 'source $ZDOTDIR/.zshenv && source $ZDOTDIR/.zshrc && echo "Main configuration loaded successfully"'
}

debug_config() {
    echo -e "${YELLOW}Running safe config in debug mode...${NC}"
    DEBUG_ZSH=1 docker-compose run --rm zsh-env zsh -i -l
}

debug_main_config() {
    echo -e "${YELLOW}Running main config in debug mode...${NC}"
    ZDOTDIR=/home/$USERNAME/.core/cfg/zsh DEBUG_ZSH=1 docker-compose run --rm zsh-env zsh -i -l
}

clean_all() {
    echo -e "${RED}Cleaning up containers and volumes...${NC}"
    docker-compose down -v
    docker rmi zsh-config-test:latest 2>/dev/null || true
}

rebuild_all() {
    clean_all
    build_image
}

enter_shell() {
    if [ "$(docker ps -q -f name=zsh-config-test)" ]; then
        docker exec -it zsh-config-test zsh -i -l
    else
        echo -e "${RED}Container is not running. Use '$0 run' first.${NC}"
        exit 1
    fi
}

show_logs() {
    docker-compose logs -f zsh-env
}

# Main script logic
case "${1:-run}" in
    build)
        build_image
        ;;
    run)
        if [ ! "$(docker images -q zsh-config-test:latest)" ]; then
            build_image
        fi
        run_container "$@"
        ;;
    test)
        test_config
        ;;
    test-main)
        test_main_config
        ;;
    debug)
        debug_config
        ;;
    debug-main)
        debug_main_config
        ;;
    clean)
        clean_all
        ;;
    rebuild)
        rebuild_all
        ;;
    shell)
        enter_shell
        ;;
    logs)
        show_logs
        ;;
    -h|--help|help)
        print_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        print_help
        exit 1
        ;;
esac