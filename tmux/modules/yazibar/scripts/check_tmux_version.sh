#!/usr/bin/env bash

VERSION="$1"
UNSUPPORTED_MSG="$2"

# Source yazibar utilities (includes display_message and tmux option functions)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# this is used to get "clean" integer version number. Examples:
# `tmux 1.9` => `19`
# `1.9a`     => `19`
get_digits_from_string() {
	local string="$1"
	local only_digits="$(echo "$string" | tr -dC '[:digit:]')"
	echo "$only_digits"
}

tmux_version_int() {
	local tmux_version_string=$(tmux -V)
	echo "$(get_digits_from_string "$tmux_version_string")"
}

unsupported_version_message() {
	if [ -n "$UNSUPPORTED_MSG" ]; then
		echo "$UNSUPPORTED_MSG"
	else
		echo "Error, Tmux version unsupported! Please install Tmux version $VERSION or greater!"
	fi
}

exit_if_unsupported_version() {
	local current_version="$1"
	local supported_version="$2"
	if [ "$current_version" -lt "$supported_version" ]; then
		display_message "$(unsupported_version_message)"
		exit 1
	fi
}

main() {
	local supported_version_int="$(get_digits_from_string "$VERSION")"
	local current_version_int="$(tmux_version_int)"
	exit_if_unsupported_version "$current_version_int" "$supported_version_int"
}
main
