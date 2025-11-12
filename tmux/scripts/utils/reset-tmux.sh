#!/bin/bash
# Reset tmux: Save session, kill server, and relaunch
# This is useful for applying major configuration changes or recovering from issues

set -e

RESURRECT_SAVE="$HOME/.core/cfg/tmux/plugins/tmux-resurrect/scripts/save.sh"
TMUX_CONF="$HOME/.core/cfg/tmux/tmux.conf"

echo "🔄 Resetting tmux server..."
echo ""

# Step 1: Save current session state
if [[ -f "$RESURRECT_SAVE" ]]; then
    echo "💾 Saving current session state..."
    bash "$RESURRECT_SAVE" 2>/dev/null || echo "⚠️  Warning: Save may have failed"
    echo "✓ Session state saved"
else
    echo "⚠️  Warning: tmux-resurrect save script not found, skipping save"
fi

echo ""

# Step 2: Kill the tmux server
echo "🛑 Killing tmux server..."
tmux kill-server 2>/dev/null || echo "✓ Server already stopped"
sleep 1

echo "✓ Server killed"
echo ""

# Step 3: Relaunch tmux
echo "🚀 Relaunching tmux..."
sleep 0.5

# Check if we should launch in a specific way
if [[ -n "$TMUX" ]]; then
    # We're already in tmux (this shouldn't happen, but just in case)
    echo "⚠️  Already in a tmux session"
else
    # Launch new tmux session
    if [[ -f "$TMUX_CONF" ]]; then
        tmux -f "$TMUX_CONF" new-session -d -s main 2>/dev/null || tmux new-session -d -s main
        echo "✓ New session 'main' created"
        echo ""
        echo "📋 To attach: tmux attach -t main"
        echo "   Or restore from resurrect: prefix + Ctrl-r"
    else
        tmux new-session -d -s main
        echo "✓ New session 'main' created"
    fi
fi

echo ""
echo "✅ Tmux reset complete!"
