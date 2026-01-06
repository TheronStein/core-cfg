#!/usr/bin/env bash
# ==============================================================================
# WezTerm Regex Browser - WRAPPER
# ==============================================================================
# DEPRECATED: This file now calls the global library.
# The regex browser is available via ~/.core/.cortex/lib/fzf-browsers/regex-browser.sh
#
# For new code, call the global browser directly:
#   ~/.core/.cortex/lib/fzf-browsers/regex-browser.sh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_BROWSER="${HOME}/.core/.cortex/lib/fzf-browsers/regex-browser.sh"

# Call global browser with local data directory
if [[ -x "$GLOBAL_BROWSER" ]]; then
    exec "$GLOBAL_BROWSER" --data-dir "$SCRIPT_DIR/data" "$@"
else
    echo "Error: Global regex browser not found: $GLOBAL_BROWSER" >&2
    exit 1
fi
