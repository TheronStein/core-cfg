#!/bin/bash
# Task/Process Progress Monitor for TMUX Status Bar
# Shows active downloads, uploads, compression, and transfers with progress

# Keep tasks aligned to the right with proper spacing
# Output format: "  <tasks>" to ensure right alignment after cloud-storage tabs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/transfer-monitor.sh"
