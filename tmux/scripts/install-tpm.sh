#!/usr/bin/env bash

# TPM installation script
TPM_DIR="$HOME/.core/cfg/tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "TPM installed successfully!"
    echo "Now reload tmux config with: tmux source ~/.core/cfg/tmux/tmux.conf"
    echo "Then press Prefix + M-i to install plugins"
else
    echo "TPM is already installed at $TPM_DIR"
fi
