#!/bin/zsh
# Docker entrypoint script - auto-initializes working copy

# Define paths to match host structure
CORE="${HOME}/.core"
THEMES_CONFIG="${CORE}/cfg/themes"
ZSH_CONFIG="${CORE}/cfg/zsh"
TMUX_CONFIG="${CORE}/cfg/tmux"
YAZI_CONFIG="${CORE}/cfg/yazi"
NVIM_CONFIG="${CORE}/cfg/nvim"
ZSH_MOUNTED="${ZSH_CONFIG}-mounted"
TMUX_MOUNTED="${TMUX_CONFIG}-mounted"
YAZI_MOUNTED="${YAZI_CONFIG}-mounted"
NVIM_MOUNTED="${NVIM_CONFIG}-mounted"


# Auto-initialize working copy if empty
if [[ ! -f "${ZSH_CONFIG}/.zshenv" && -d "${ZSH_MOUNTED}" ]]; then
    echo "================================================"
    echo "Initializing working copy from mounted source..."
    echo "  Source: ${ZSH_MOUNTED}/ (read-only)"
    echo "  Target: ${ZSH_CONFIG}/ (working copy)"
    echo "================================================"

    # Copy all files including hidden ones
    cp -r ${ZSH_MOUNTED}/* ${ZSH_CONFIG}/ 2>/dev/null || true
    cp -r ${ZSH_MOUNTED}/.* ${ZSH_CONFIG}/ 2>/dev/null || true
    cp -r ${TMUX_MOUNTED}/* ${ZSH_CONFIG}/ 2>/dev/null || true
    cp -r ${TMUX_MOUNTED}/.* ${ZSH_CONFIG}/ 2>/dev/null || true
    cp -r ${THEMES_MOUNTED}/.* ${ZSH_CONFIG}/ 2>/dev/null || true
    cp -r ${THEMES_MOUNTED}/.* ${ZSH_CONFIG}/ 2>/dev/null || true
    cp -r ${NVIM_MOUNTED}/* ${ZSH_CONFIG}/ 2>/dev/null || true
    cp -r ${NVIM_MOUNTED}/.* ${ZSH_CONFIG}/ 2>/dev/null || true
    cp -r ${YAZI_MOUNTED}/* ${ZSH_CONFIG}/ 2>/dev/null || true
    cp -r ${YAZI_MOUNTED}/.* ${ZSH_CONFIG}/ 2>/dev/null || true

    echo "Working copy initialized successfully!"
    echo "================================================"
fi

ln -sf ${ZSH_CONFIG}/.zshenv.local ${HOME}/.zshenv
ln -sf ${ZSH_CONIG]/.zshrc 
ln -sf ${TMUX_CONFIG]/tmux.conf ${HOME}/.tmux.conf 
ln -sf ${HOME}/ref/zsh.ref ${ZSH_CONFIG}/ref/zsh

# Execute the command passed to docker run
exec "$@"
