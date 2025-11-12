#!/usr/bin/env bash
# Safe zsh config testing in Docker with process monitoring

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="zsh-config-test"

usage() {
    cat << EOF
Usage: $0 [command]

Commands:
    build       Build the Docker image
    test        Run quick test (30s timeout)
    shell       Start interactive shell with monitoring
    monitor     Show process monitor output
    clean       Remove Docker image
    help        Show this help

The monitor will kill zsh if more than 30 processes are spawned.
EOF
    exit 0
}

build() {
    echo "Building Docker image: $IMAGE_NAME"
    cd "$SCRIPT_DIR"
    docker build -t "$IMAGE_NAME" -f DockerFile .
    echo "✓ Build complete"
}

test() {
    echo "Testing zsh config (30s timeout, max 200 processes)..."
    docker run --rm \
        --ulimit nproc=200:200 \
        --ulimit nofile=2048:2048 \
        "$IMAGE_NAME" \
        /usr/local/bin/test-zsh.sh
    echo "✓ Test passed"
}

shell() {
    echo "Starting interactive shell with process monitoring..."
    echo "Type 'exit' to quit. Monitor will kill shell if >30 processes spawn."
    docker run -it --rm \
        --ulimit nproc=200:200 \
        --ulimit nofile=2048:2048 \
        "$IMAGE_NAME"
}

monitor() {
    echo "Showing process count (Ctrl+C to stop)..."
    docker run -it --rm \
        --ulimit nproc=50:50 \
        --ulimit nofile=1024:1024 \
        "$IMAGE_NAME" \
        /bin/bash -c 'watch -n 1 "ps aux | wc -l"'
}

clean() {
    echo "Removing Docker image: $IMAGE_NAME"
    docker rmi "$IMAGE_NAME"
    echo "✓ Cleaned"
}

case "${1:-help}" in
    build)   build ;;
    test)    test ;;
    shell)   shell ;;
    monitor) monitor ;;
    clean)   clean ;;
    help|*)  usage ;;
esac
