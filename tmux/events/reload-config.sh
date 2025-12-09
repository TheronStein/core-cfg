#!/bin/bash

# Get the actual config path
CONFIG_PATH="${HOME}/.core/cfg/tmux/tmux.conf"

# Check if config exists
if [ ! -f "$CONFIG_PATH" ]; then
  tmux display-message "Error: Config not found at $CONFIG_PATH"
  exit 1
fi

# Source the config
tmux source-file "$CONFIG_PATH"

# Display success message
tmux display-message "Config reloaded from $CONFIG_PATH"
