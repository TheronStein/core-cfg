#!/usr/bin/env bash
# Script to open files in the parent nvim instance without closing yazi

# Get the nvim server address from environment (set by the yazi-sidebar module)
NVIM_SERVER="${NVIM_SIDEBAR_SERVER:-$NVIM}"

# If we have files to open
if [ -n "$1" ]; then
	# Try to use nvim remote if available
	if [ -n "$NVIM_SERVER" ]; then
		# Send edit command to the nvim instance
		nvim --server "$NVIM_SERVER" --remote "$@" 2>/dev/null || {
			# Fallback: write to chooser file
			echo "$@" >> "${YAZI_CHOOSER_FILE:-/tmp/yazi-chooser}"
		}
	else
		# Fallback: write to chooser file
		echo "$@" >> "${YAZI_CHOOSER_FILE:-/tmp/yazi-chooser}"
	fi
fi

# Don't quit yazi - return success
exit 0
