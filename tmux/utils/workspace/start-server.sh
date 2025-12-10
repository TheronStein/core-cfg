#!/usr/bin/env bash
# ============================================================================
# Tmux Server Starter with Custom Configurations
# ============================================================================
# Usage:
#   ./start-server.sh development
#   ./start-server.sh default
#
# This script starts a tmux server with a specific configuration file
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

SERVER_NAME="${1:-}"

if [[ -z "$SERVER_NAME" ]]; then
    echo "Usage: $0 <server-name>"
    echo ""
    echo "Available configurations:"
    ls -1 "$TMUX_CONFIG_DIR"/*.tmux 2>/dev/null | while read -r config; do
        basename "$config" .tmux
    done
    exit 1
fi

CONFIG_FILE="$TMUX_CONFIG_DIR/${SERVER_NAME}.tmux"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    echo ""
    echo "Available configurations:"
    ls -1 "$TMUX_CONFIG_DIR"/*.tmux 2>/dev/null | while read -r config; do
        basename "$config" .tmux
    done
    exit 1
fi

# Check if server is already running
if tmux -L "$SERVER_NAME" list-sessions &>/dev/null; then
    echo "Server '$SERVER_NAME' is already running with sessions:"
    tmux -L "$SERVER_NAME" list-sessions
    echo ""
    read -p "Attach to this server? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        tmux -L "$SERVER_NAME" attach-session
    fi
    exit 0
fi

echo "Starting tmux server: $SERVER_NAME"
echo "Configuration: $CONFIG_FILE"

# Create resurrect directory if it doesn't exist
RESURRECT_DIR="$HOME/.tmux/resurrect/$SERVER_NAME"
mkdir -p "$RESURRECT_DIR"
echo "Resurrect directory: $RESURRECT_DIR"

# Start the server with the specific configuration
# -f: config file
# -L: socket name (server name)
# new-session: create initial session
# -s: session name
# -d: detached mode (optional, remove to attach immediately)

tmux -f "$CONFIG_FILE" -L "$SERVER_NAME" new-session -s main -d

echo "Server '$SERVER_NAME' started successfully!"
echo ""
echo "To attach:"
echo "  tmux -L $SERVER_NAME attach-session"
echo ""
echo "To list sessions:"
echo "  tmux -L $SERVER_NAME list-sessions"
