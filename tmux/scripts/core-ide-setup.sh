#!/bin/bash
# Core-IDE Setup Script
# Sets up the complete Core-IDE integrated workspace environment

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

CORE_BASE="${HOME}/.core"
CORE_SYS="${CORE_BASE}/.sys"
TMUX_CONF="${CORE_SYS}/cfg/tmux"
NVIM_CONF="${CORE_SYS}/cfg/nvim"
YAZI_CONF="${CORE_SYS}/cfg/yazi"
WEZTERM_CONF="${CORE_SYS}/cfg/wezterm"
ZSH_CONF="${CORE_SYS}/cfg/zsh"

# Core-IDE directories
CORE_IDE_BASE="${HOME}/.local/state/core-ide"
CORE_IDE_SOCKETS="${CORE_IDE_BASE}/sockets"
CORE_IDE_SESSIONS="${CORE_IDE_BASE}/sessions"
CORE_IDE_LAYOUTS="${CORE_IDE_BASE}/layouts"
CORE_IDE_CONFIG="${CORE_IDE_BASE}/config"
CORE_IDE_SCRIPTS="${TMUX_CONF}/modules/core-ide"

# Default socket contexts
SOCKET_CONTEXTS=("main" "work" "personal" "research" "system" "remote" "build" "debug")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create directory structure
create_directories() {
    log_info "Creating Core-IDE directory structure..."

    mkdir -p "${CORE_IDE_BASE}"
    mkdir -p "${CORE_IDE_SOCKETS}/active"
    mkdir -p "${CORE_IDE_SOCKETS}/locks"

    for context in "${SOCKET_CONTEXTS[@]}"; do
        mkdir -p "${CORE_IDE_SESSIONS}/${context}"
        mkdir -p "${CORE_IDE_SESSIONS}/${context}/layouts"
        mkdir -p "${CORE_IDE_SESSIONS}/${context}/yazi"
        mkdir -p "${CORE_IDE_SESSIONS}/${context}/nvim"
    done

    mkdir -p "${CORE_IDE_LAYOUTS}"
    mkdir -p "${CORE_IDE_CONFIG}"
    mkdir -p "${CORE_IDE_SCRIPTS}"

    log_success "Directory structure created"
}

# Create socket registry file
create_registry() {
    log_info "Creating socket registry..."

    cat > "${CORE_IDE_SOCKETS}/registry" << 'EOF'
# Core-IDE Socket Registry
# Format: CONTEXT|SOCKET_PATH|STATUS|CREATED|LAST_ACTIVE|SESSIONS
# Example: main|/tmp/tmux-core-ide-main|active|2025-01-15T10:30:00|2025-01-15T14:45:00|3
EOF

    log_success "Socket registry created"
}

# Create configuration files
create_config_files() {
    log_info "Creating configuration files..."

    # Global Core-IDE configuration
    cat > "${CORE_IDE_CONFIG}/core-ide.conf" << 'EOF'
# Core-IDE Global Configuration

# Socket settings
CORE_IDE_SOCKET_PREFIX="/tmp/tmux-core-ide"
CORE_IDE_DEFAULT_CONTEXT="main"

# Layout settings
CORE_IDE_LEFT_SIDEBAR_WIDTH="25%"
CORE_IDE_RIGHT_SIDEBAR_WIDTH="20%"
CORE_IDE_MIN_CENTER_WIDTH="40%"

# Yazi settings
CORE_IDE_YAZI_LEFT_ENABLED=1
CORE_IDE_YAZI_RIGHT_ENABLED=0
CORE_IDE_YAZI_SYNC_ENABLED=1

# Persistence settings
CORE_IDE_AUTO_SAVE=1
CORE_IDE_AUTO_SAVE_INTERVAL=300  # 5 minutes
CORE_IDE_RESTORE_ON_START=1

# Theme settings
CORE_IDE_SOCKET_COLORS=(
    "main:#7aa2f7"      # blue
    "work:#9ece6a"      # green
    "personal:#bb9af7"  # purple
    "research:#e0af68"  # yellow
    "system:#f7768e"    # red
    "remote:#73daca"    # cyan
    "build:#ff9e64"     # orange
    "debug:#2ac3de"     # light blue
)
EOF

    log_success "Configuration files created"
}

# Install tmux plugins if needed
install_tmux_plugins() {
    log_info "Checking tmux plugins..."

    # Install TPM if not already installed
    if [ ! -d "${TMUX_CONF}/plugins/tpm" ]; then
        log_info "Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm "${TMUX_CONF}/plugins/tpm"
    fi

    # Install tmux-resurrect
    if [ ! -d "${TMUX_CONF}/plugins/tmux-resurrect" ]; then
        log_info "Installing tmux-resurrect..."
        git clone https://github.com/tmux-plugins/tmux-resurrect "${TMUX_CONF}/plugins/tmux-resurrect"
    fi

    log_success "Tmux plugins installed"
}

# Create layout templates
create_layout_templates() {
    log_info "Creating layout templates..."

    # Default layout
    cat > "${CORE_IDE_LAYOUTS}/default.tmux" << 'EOF'
# Core-IDE Default Layout
# Left sidebar (yazi) | Center workspace | Right sidebar (optional yazi)

select-layout "225a,274x59,0,0{68x59,0,0[68x29,0,0,0,68x29,0,30,3],137x59,69,0,1,68x59,207,0[68x29,207,0,4,68x29,207,30,5]}"
EOF

    # Code layout
    cat > "${CORE_IDE_LAYOUTS}/code.tmux" << 'EOF'
# Core-IDE Code Layout
# Left yazi | Editor + Terminal | Right diagnostics

select-layout "b147,274x59,0,0{68x59,0,0,0,137x59,69,0[137x39,69,0,1,137x19,69,40,2],68x59,207,0,3}"
EOF

    # Review layout
    cat > "${CORE_IDE_LAYOUTS}/review.tmux" << 'EOF'
# Core-IDE Review Layout
# Left file tree | Center diff | Right blame/log

select-layout "3ea5,274x59,0,0{68x59,0,0,0,137x59,69,0,1,68x59,207,0[68x29,207,0,2,68x29,207,30,3]}"
EOF

    # Debug layout
    cat > "${CORE_IDE_LAYOUTS}/debug.tmux" << 'EOF'
# Core-IDE Debug Layout
# Left yazi | Debugger + Code | Right watches

select-layout "8a9c,274x59,0,0{68x59,0,0,0,137x59,69,0[137x29,69,0,1,137x29,69,30,2],68x59,207,0,3}"
EOF

    log_success "Layout templates created"
}

# Setup yazibar integration
setup_yazibar() {
    log_info "Setting up yazibar integration..."

    # Ensure yazibar scripts are executable
    if [ -d "${TMUX_CONF}/modules/yazibar/scripts" ]; then
        chmod +x "${TMUX_CONF}/modules/yazibar/scripts"/*.sh 2>/dev/null || true
    fi

    log_success "Yazibar integration configured"
}

# Create helper scripts
create_helper_scripts() {
    log_info "Creating helper scripts..."

    # Main launcher script
    cat > "${CORE_IDE_SCRIPTS}/core-ide-launch" << 'EOF'
#!/bin/bash
# Launch Core-IDE with specified context

CONTEXT="${1:-main}"
SOCKET_PATH="/tmp/tmux-core-ide-${CONTEXT}"
CORE_IDE_BASE="${HOME}/.local/state/core-ide"

# Check if socket already exists
if tmux -L "core-ide-${CONTEXT}" list-sessions &>/dev/null; then
    echo "Core-IDE context '${CONTEXT}' is already running"
    echo "Attaching to existing session..."
    exec tmux -L "core-ide-${CONTEXT}" attach
else
    echo "Starting Core-IDE context: ${CONTEXT}"
    exec tmux -L "core-ide-${CONTEXT}" new-session -s "${CONTEXT}-main"
fi
EOF
    chmod +x "${CORE_IDE_SCRIPTS}/core-ide-launch"

    # Socket switcher script
    cat > "${CORE_IDE_SCRIPTS}/core-ide-switch" << 'EOF'
#!/bin/bash
# Switch between Core-IDE contexts

CORE_IDE_BASE="${HOME}/.local/state/core-ide"
CURRENT_SOCKET="${TMUX%%,*}"

# Get list of active sockets
echo "Active Core-IDE contexts:"
for socket in /tmp/tmux-core-ide-*; do
    if [ -S "$socket" ]; then
        context="${socket##*/tmux-core-ide-}"
        sessions=$(tmux -S "$socket" list-sessions 2>/dev/null | wc -l)
        echo "  ${context}: ${sessions} sessions"
    fi
done

# Use fzf if available, otherwise read input
if command -v fzf >/dev/null 2>&1; then
    CONTEXT=$(ls /tmp/tmux-core-ide-* 2>/dev/null | xargs -n1 basename | sed 's/tmux-core-ide-//' | fzf --prompt="Select context: ")
else
    read -p "Enter context to switch to: " CONTEXT
fi

if [ -n "$CONTEXT" ]; then
    SOCKET_PATH="/tmp/tmux-core-ide-${CONTEXT}"
    if [ -S "$SOCKET_PATH" ]; then
        tmux -L "core-ide-${CONTEXT}" switch-client
    else
        echo "Context '${CONTEXT}' not found or not active"
    fi
fi
EOF
    chmod +x "${CORE_IDE_SCRIPTS}/core-ide-switch"

    # Status script
    cat > "${CORE_IDE_SCRIPTS}/core-ide-status" << 'EOF'
#!/bin/bash
# Display status of all Core-IDE contexts

echo "Core-IDE Status Report"
echo "====================="

for socket in /tmp/tmux-core-ide-*; do
    if [ -S "$socket" ]; then
        context="${socket##*/tmux-core-ide-}"
        echo ""
        echo "Context: ${context}"
        echo "  Socket: ${socket}"
        echo "  Sessions:"
        tmux -S "$socket" list-sessions 2>/dev/null | sed 's/^/    /'
        echo "  Windows:"
        tmux -S "$socket" list-windows -a 2>/dev/null | head -5 | sed 's/^/    /'
    fi
done

echo ""
echo "Memory Usage:"
ps aux | grep -E "tmux.*core-ide" | grep -v grep | awk '{sum+=$6} END {printf "  Total: %.2f MB\n", sum/1024}'
EOF
    chmod +x "${CORE_IDE_SCRIPTS}/core-ide-status"

    log_success "Helper scripts created"
}

# Create symlinks for easy access
create_symlinks() {
    log_info "Creating symlinks for easy access..."

    # Create symlinks in user's bin directory
    BIN_DIR="${HOME}/.local/bin"
    mkdir -p "$BIN_DIR"

    ln -sf "${CORE_IDE_SCRIPTS}/core-ide-launch" "${BIN_DIR}/core-ide"
    ln -sf "${CORE_IDE_SCRIPTS}/core-ide-switch" "${BIN_DIR}/core-ide-switch"
    ln -sf "${CORE_IDE_SCRIPTS}/core-ide-status" "${BIN_DIR}/core-ide-status"

    log_success "Symlinks created in ${BIN_DIR}"
}

# ============================================================================
# MAIN SETUP
# ============================================================================

main() {
    echo "=================================="
    echo "    Core-IDE Setup Script"
    echo "=================================="
    echo ""

    # Check dependencies
    log_info "Checking dependencies..."

    for cmd in tmux yazi nvim; do
        if ! command -v "$cmd" &>/dev/null; then
            log_warning "$cmd is not installed. Some features may not work."
        fi
    done

    # Create directory structure
    create_directories

    # Create registry and config files
    create_registry
    create_config_files

    # Install tmux plugins
    install_tmux_plugins

    # Create layout templates
    create_layout_templates

    # Setup yazibar
    setup_yazibar

    # Create helper scripts
    create_helper_scripts

    # Create symlinks
    create_symlinks

    echo ""
    echo "=================================="
    echo "    Setup Complete!"
    echo "=================================="
    echo ""
    echo "Core-IDE has been successfully set up!"
    echo ""
    echo "To start using Core-IDE:"
    echo "  1. Launch a context: core-ide [context]"
    echo "     Available contexts: ${SOCKET_CONTEXTS[*]}"
    echo ""
    echo "  2. Switch between contexts: core-ide-switch"
    echo ""
    echo "  3. Check status: core-ide-status"
    echo ""
    echo "Configuration files are located at:"
    echo "  ${CORE_IDE_BASE}"
    echo ""
    echo "Remember to:"
    echo "  - Press Prefix + I in tmux to install plugins"
    echo "  - Restart tmux for all changes to take effect"
}

# Run main setup
main "$@"