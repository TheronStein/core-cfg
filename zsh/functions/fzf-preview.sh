#!/usr/bin/env bash
# fzf-preview.sh - Universal preview script for fzf
# Usage: fzf-preview.sh <target>
#
# Handles: files, directories, commands, git objects, archives, images
# Never shows blank output - always falls back to something useful

target="$1"

# Empty input
if [[ -z "$target" ]]; then
    echo -e "\033[2m(no selection)\033[0m"
    exit 0
fi

# Directory
if [[ -d "$target" ]]; then
    if command -v eza &>/dev/null; then
        eza --color=always --icons --group-directories-first -la "$target" 2>/dev/null
    elif command -v exa &>/dev/null; then
        exa --color=always --icons -la "$target" 2>/dev/null
    else
        ls -la --color=always "$target" 2>/dev/null || ls -la "$target"
    fi
    exit 0
fi

# Symlink (resolve and preview target)
if [[ -L "$target" ]]; then
    resolved=$(readlink -f "$target" 2>/dev/null || readlink "$target")
    echo -e "\033[1;36m🔗 Symlink:\033[0m $target"
    echo -e "\033[1;36m→\033[0m $resolved"
    echo ""
    if [[ -e "$resolved" ]]; then
        exec "$0" "$resolved"
    fi
    exit 0
fi

# Regular file - use MIME type for smart detection
if [[ -f "$target" ]]; then
    mime=$(file -b --mime-type "$target" 2>/dev/null)
    size=$(stat -c%s "$target" 2>/dev/null || stat -f%z "$target" 2>/dev/null || echo 0)

    # Large file warning
    if [[ "$size" -gt 5242880 ]]; then
        echo -e "\033[1;33m⚠ Large file:\033[0m $(numfmt --to=iec $size 2>/dev/null || echo "$size bytes")"
        file -b "$target" 2>/dev/null
        echo ""
        echo -e "\033[2m(showing first 50 lines)\033[0m"
        head -50 "$target" 2>/dev/null
        exit 0
    fi

    case "$mime" in
        # Directories (shouldn't hit this but just in case)
        inode/directory)
            ls -la --color=always "$target"
            ;;

        # Images
        image/*)
            echo -e "\033[1;32m🖼️  Image:\033[0m $target"
            file -b "$target" 2>/dev/null
            if command -v chafa &>/dev/null; then
                chafa --size=60x30 "$target" 2>/dev/null
            elif command -v catimg &>/dev/null; then
                catimg -w 60 "$target" 2>/dev/null
            fi
            ;;

        # PDF
        application/pdf)
            echo -e "\033[1;31m📄 PDF:\033[0m $target"
            if command -v pdftotext &>/dev/null; then
                pdftotext -l 2 -layout "$target" - 2>/dev/null | head -80
            else
                file -b "$target" 2>/dev/null
                echo "(install poppler-utils for PDF preview)"
            fi
            ;;

        # Archives
        application/zip|application/x-tar|application/gzip|application/x-bzip2|application/x-xz|application/x-7z-compressed|application/x-rar)
            echo -e "\033[1;33m📦 Archive:\033[0m $target"
            case "${target,,}" in
                *.tar|*.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.tar.zst)
                    tar -tvf "$target" 2>/dev/null | head -40 ;;
                *.zip)
                    unzip -l "$target" 2>/dev/null | head -40 ;;
                *.7z)
                    7z l "$target" 2>/dev/null | head -40 ;;
                *.rar)
                    unrar l "$target" 2>/dev/null | head -40 ;;
                *)
                    file -b "$target" ;;
            esac
            ;;

        # Executables/binaries
        application/x-executable|application/x-sharedlib|application/x-pie-executable)
            echo -e "\033[1;35m⚡ Executable:\033[0m $target"
            file -b "$target" 2>/dev/null
            echo ""
            # Try to show help
            echo -e "\033[1;33m─── Help ───\033[0m"
            "$target" --help 2>&1 | head -40 || \
            "$target" -h 2>&1 | head -40 || \
            echo "(no help available)"
            ;;

        # JSON
        application/json)
            if command -v jq &>/dev/null; then
                jq -C . "$target" 2>/dev/null | head -100
            elif command -v bat &>/dev/null; then
                bat --color=always --style=numbers --language=json "$target" 2>/dev/null | head -100
            else
                head -100 "$target"
            fi
            ;;

        # Text/code files (default)
        text/*|application/x-shellscript|application/javascript|application/xml)
            if command -v bat &>/dev/null; then
                bat --color=always --style=numbers,changes --line-range :200 "$target" 2>/dev/null
            elif command -v batcat &>/dev/null; then
                batcat --color=always --style=numbers --line-range :200 "$target" 2>/dev/null
            else
                head -200 "$target" 2>/dev/null
            fi
            ;;

        # Unknown - try bat, fall back to head
        *)
            if command -v bat &>/dev/null; then
                bat --color=always --style=numbers,changes --line-range :150 "$target" 2>/dev/null || \
                head -150 "$target" 2>/dev/null || \
                { echo -e "\033[1;33m📄 File:\033[0m $target"; file -b "$target" 2>/dev/null; }
            else
                head -150 "$target" 2>/dev/null || \
                { echo -e "\033[1;33m📄 File:\033[0m $target"; file -b "$target" 2>/dev/null; }
            fi
            ;;
    esac
    exit 0
fi

# Not a file - might be a command name
if command -v "$target" &>/dev/null; then
    cmd_path=$(command -v "$target")
    echo -e "\033[1;35m⚡ Command:\033[0m $target"
    echo -e "\033[2mPath: $cmd_path\033[0m"
    echo ""

    # Try man page first
    if man -w "$target" &>/dev/null 2>&1; then
        echo -e "\033[1;33m─── Manual ───\033[0m"
        man "$target" 2>/dev/null | col -bx | head -50
    else
        echo -e "\033[1;33m─── Help ───\033[0m"
        "$target" --help 2>&1 | head -40 || \
        "$target" -h 2>&1 | head -40 || \
        type "$target" 2>/dev/null || \
        echo "(no documentation available)"
    fi
    exit 0
fi

# Git object (commit hash, branch name, etc.)
if git rev-parse "$target" &>/dev/null 2>&1; then
    echo -e "\033[1;33m🔖 Git:\033[0m $target"
    git show --color=always "$target" 2>/dev/null | head -50 || \
    git log --oneline --graph --color=always "$target" 2>/dev/null | head -30
    exit 0
fi

# Final fallback - never blank
echo -e "\033[1;33m📋 Item:\033[0m $target"
type "$target" 2>/dev/null || \
whence -v "$target" 2>/dev/null || \
echo "(unknown)"
