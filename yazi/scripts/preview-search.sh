#!/bin/bash
# preview-search.sh - Open file preview in tmux popup with search capability
# Usage: preview-search.sh <file> [mode]
# Modes: less (default), copymode, fzf

file="$1"
mode="${2:-less}"

if [[ ! -f "$file" ]]; then
    echo "Error: File not found: $file"
    exit 1
fi

case "$mode" in
    less)
        # Simple approach: bat with less pager
        # Search: / (forward), ? (backward), n/N (next/prev match)
        # Exit: q
        tmux popup -E -w 95% -h 95% "bat --color=always --paging=always --style=numbers,header \"$file\""
        ;;

    copymode)
        # True tmux copy-mode approach
        # Creates a temporary pane, displays content, enters copy-mode
        # Search: / (forward), ? (backward)
        # Exit: q or Escape

        # Generate content to a temp file
        tmpfile=$(mktemp /tmp/yazi-preview.XXXXXX)
        bat --color=always --paging=never --style=numbers,header "$file" > "$tmpfile"

        # Open popup with a shell that displays content and waits
        # Then send copy-mode keys
        tmux popup -w 95% -h 95% -E "less -R \"$tmpfile\"; rm -f \"$tmpfile\""
        ;;

    fzf)
        # FZF-powered line search with live filtering
        # Type to filter lines, Enter to select, Ctrl-C to exit
        # Preview shows context around selected line

        tmux popup -E -w 95% -h 95% "bat --color=always --paging=never --style=numbers \"$file\" | \
            fzf --ansi \
                --layout=reverse \
                --no-sort \
                --exact \
                --header=\"$(basename "$file") | Type to search, Enter to select line, Ctrl-C to exit\" \
                --preview='echo {}' \
                --preview-window=up:3:wrap"
        ;;

    *)
        echo "Unknown mode: $mode"
        echo "Available modes: less, copymode, fzf"
        exit 1
        ;;
esac
