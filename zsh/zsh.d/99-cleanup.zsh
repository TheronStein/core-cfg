# ~/.core/cfg/zsh/zsh.d/99-cleanup.zsh
# Final cleanup and startup completion

# Remove startup guards
unset ZSH_LOADING_CONFIGS
unset ZSH_STARTING_UP

# Remove error trap
trap - ERR

# Reset resource limits
ulimit -t unlimited 2>/dev/null || true

# Disable any remaining scheduler activity
zstyle ':zinit:scheduler' disable yes

# Mark configuration as fully loaded
export _ZSHRC_FULLY_LOADED=1
