#!/bin/bash
# Install TPM (Tmux Plugin Manager)

TMUX_CONF="/home/theron/.core/.sys/cfg/tmux"
PLUGIN_DIR="$TMUX_CONF/plugins"

# Create plugins directory if it doesn't exist
mkdir -p "$PLUGIN_DIR"

# Clone TPM if not already installed
if [ ! -d "$PLUGIN_DIR/tpm" ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$PLUGIN_DIR/tpm"
else
    echo "TPM already installed"
fi

# Make tpm executable
chmod +x "$PLUGIN_DIR/tpm/tpm"
chmod +x "$PLUGIN_DIR/tpm/bin/install_plugins"

echo "TPM installation complete"
echo "Press prefix + I (capital i) in tmux to install plugins"
