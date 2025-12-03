#!/usr/bin/env bash
# ==============================================================================
# popup-fzf.sh - Tmux Popup FZF Operations for Yazi
# ==============================================================================
# Launches fzf-based operations in tmux popup overlay while keeping yazi visible
#
# Usage: popup-fzf.sh <action> <cwd> [extra_args...]
#
# Actions:
#   rga-search    - Search inside archives with ripgrep-all
#   duplicates    - Find duplicate files with fclones
#   large-files   - Find files over size threshold
#   archive-list  - Browse archive contents
#   dir-compare   - Compare two directories
#   file-select   - Generic file selection
#
# Result Handling:
#   - Results are written to temp file
#   - On exit, ya emit is called to navigate yazi to selection
# ==============================================================================

set -euo pipefail

# Configuration
SCRIPT_NAME="popup-fzf"
RESULT_FILE="/tmp/yazi-popup-result-$$-$(date +%s)"
LOG_FILE="/tmp/yazi-popup.log"

# FZF defaults
FZF_DEFAULT_OPTS="
    --height=100%
    --border=rounded
    --info=inline
    --prompt='> '
    --pointer='>'
    --marker='*'
    --bind 'ctrl-a:toggle-all'
    --bind 'ctrl-d:half-page-down'
    --bind 'ctrl-u:half-page-up'
    --bind 'ctrl-/:toggle-preview'
"

# Cleanup handler
cleanup() {
    rm -f "$RESULT_FILE" 2>/dev/null
}
trap cleanup EXIT

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$SCRIPT_NAME] $*" >> "$LOG_FILE"
}

# Parse arguments
ACTION="${1:-}"
CWD="${2:-$PWD}"
shift 2 2>/dev/null || true
EXTRA_ARGS=("$@")

if [[ -z "$ACTION" ]]; then
    echo "Usage: $0 <action> <cwd> [extra_args...]"
    echo ""
    echo "Actions:"
    echo "  rga-search <pattern>  - Search archives"
    echo "  duplicates            - Find duplicates"
    echo "  large-files <size>    - Find large files (default: 100M)"
    echo "  archive-list <file>   - Browse archive contents"
    echo "  dir-compare <dir2>    - Compare directories"
    echo "  file-select           - Generic file selection"
    exit 1
fi

log "Action: $ACTION, CWD: $CWD, Args: ${EXTRA_ARGS[*]:-none}"

# ==============================================================================
# Action Implementations
# ==============================================================================

action_rga_search() {
    local pattern="${EXTRA_ARGS[0]:-}"

    if [[ -z "$pattern" ]]; then
        # Interactive pattern input
        echo -n "Search pattern: "
        read -r pattern
        [[ -z "$pattern" ]] && exit 0
    fi

    echo "Searching for '$pattern' in $CWD..."
    echo ""

    # Run rga and pipe to fzf
    rga --files-with-matches "$pattern" "$CWD" 2>/dev/null | \
        fzf $FZF_DEFAULT_OPTS \
            --multi \
            --prompt="Results for '$pattern' > " \
            --preview="rga --context 5 --color=always '$pattern' {} 2>/dev/null | head -60" \
            --preview-window=right:60%:wrap \
            --header="ENTER: view full | CTRL-O: open dir | CTRL-Y: copy path | TAB: select" \
            --bind "enter:execute(rga --context 15 --color=always '$pattern' {} | less -R)" \
            --bind "ctrl-o:execute(xdg-open \$(dirname {}) 2>/dev/null &)" \
            --bind "ctrl-y:execute-silent(echo {} | wl-copy 2>/dev/null || xclip -selection clipboard)" \
            > "$RESULT_FILE" || true
}

action_duplicates() {
    local tool="${EXTRA_ARGS[0]:-fclones}"

    echo "Scanning for duplicates in $CWD..."
    echo "Tool: $tool"
    echo ""

    case "$tool" in
        fclones)
            fclones group "$CWD" 2>/dev/null | \
                grep -v '^#' | grep -v '^$' | \
                fzf $FZF_DEFAULT_OPTS \
                    --multi \
                    --prompt="Duplicates > " \
                    --preview='
                        echo "=== File Info ==="
                        du -h {}
                        file -b {}
                        echo ""
                        echo "=== Preview ==="
                        bat --style=plain --color=always --line-range :40 {} 2>/dev/null || hexdump -C {} | head -20
                    ' \
                    --preview-window=right:55%:wrap \
                    --header="First in each group is original | TAB: select | CTRL-T: trash" \
                    --bind "ctrl-t:execute(trash-put {} 2>/dev/null && echo 'Trashed: {}')" \
                    --bind "enter:execute(bat --style=numbers --color=always {} | less -R)" \
                    > "$RESULT_FILE" || true
            ;;
        rmlint)
            local report_dir="/tmp/rmlint-popup-$$"
            mkdir -p "$report_dir"

            rmlint --types=duplicates --progress \
                   --output=json:"${report_dir}/duplicates.json" \
                   --output=sh:"${report_dir}/duplicates.sh" \
                   "$CWD"

            if command -v jq >/dev/null 2>&1; then
                jq -r '.[] | select(.type == "duplicate_file") | .path' "${report_dir}/duplicates.json" 2>/dev/null | \
                    fzf $FZF_DEFAULT_OPTS \
                        --multi \
                        --prompt="Duplicates (rmlint) > " \
                        --preview="bat --style=plain --color=always {} 2>/dev/null | head -40" \
                        --header="Review script: ${report_dir}/duplicates.sh" \
                        > "$RESULT_FILE" || true
            fi

            echo ""
            echo "Removal script: ${report_dir}/duplicates.sh"
            echo "Run: ${report_dir}/duplicates.sh -d -p (dry-run)"
            read -r -p "Press Enter to continue..."
            ;;
    esac
}

action_large_files() {
    local threshold="${EXTRA_ARGS[0]:-100M}"

    echo "Finding files larger than $threshold in $CWD..."
    echo ""

    fd --type f --size "+$threshold" . "$CWD" 2>/dev/null | \
        fzf $FZF_DEFAULT_OPTS \
            --multi \
            --prompt="Files > $threshold > " \
            --preview='
                echo "=== File Info ==="
                echo "Size: $(du -h {} | cut -f1)"
                echo "Type: $(file -b {})"
                echo "Modified: $(stat -c "%y" {} 2>/dev/null | cut -d"." -f1)"
                echo ""
                echo "=== Preview ==="
                bat --style=plain --color=always --line-range :40 {} 2>/dev/null || hexdump -C {} | head -20
            ' \
            --preview-window=right:55%:wrap \
            --header="CTRL-T: trash | CTRL-Y: copy path | CTRL-O: open dir | TAB: select" \
            --bind "ctrl-t:execute(trash-put {} 2>/dev/null)+reload(fd --type f --size +$threshold . '$CWD')" \
            --bind "ctrl-y:execute-silent(echo {} | wl-copy 2>/dev/null)" \
            --bind "ctrl-o:execute(xdg-open \$(dirname {}) 2>/dev/null &)" \
            > "$RESULT_FILE" || true
}

action_archive_list() {
    local archive="${EXTRA_ARGS[0]:-}"

    if [[ -z "$archive" ]]; then
        echo "Error: Archive file required"
        exit 1
    fi

    if [[ ! -f "$archive" ]]; then
        echo "Error: Archive not found: $archive"
        exit 1
    fi

    local archive_name
    archive_name=$(basename "$archive")

    echo "Browsing archive: $archive_name"
    echo ""

    # List archive contents
    (7z l "$archive" 2>/dev/null | tail -n +20 | head -n -2 | awk '{$1=$2=$3=$4=$5=""; print $0}' | sed 's/^[ ]*//' || \
     tar -tvf "$archive" 2>/dev/null | awk '{print $NF}' || \
     unzip -l "$archive" 2>/dev/null | tail -n +4 | head -n -2 | awk '{print $4}') | \
        fzf $FZF_DEFAULT_OPTS \
            --prompt="$archive_name > " \
            --preview="echo 'Path: {}'" \
            --header="Archive contents | CTRL-Y: copy path" \
            --bind "ctrl-y:execute-silent(echo {} | wl-copy 2>/dev/null)" \
            > "$RESULT_FILE" || true
}

action_dir_compare() {
    local dir2="${EXTRA_ARGS[0]:-}"

    if [[ -z "$dir2" ]]; then
        # Select second directory
        echo "Select directory to compare with $CWD"
        dir2=$(fd --type d . "$HOME" 2>/dev/null | \
            fzf --prompt="Compare with > " \
                --preview="ls -la {} | head -20" \
                --header="Select second directory")
    fi

    [[ -z "$dir2" ]] && exit 0

    echo "Comparing:"
    echo "  Dir 1: $CWD"
    echo "  Dir 2: $dir2"
    echo ""

    # Create temp files for comparison
    local list1="/tmp/dir1-$$"
    local list2="/tmp/dir2-$$"

    (cd "$CWD" && find . -type f | sort) > "$list1"
    (cd "$dir2" && find . -type f | sort) > "$list2"

    local common
    local only1
    local only2
    common=$(comm -12 "$list1" "$list2" | wc -l)
    only1=$(comm -23 "$list1" "$list2" | wc -l)
    only2=$(comm -13 "$list1" "$list2" | wc -l)

    echo "Results:"
    echo "  Common files: $common"
    echo "  Only in Dir 1: $only1"
    echo "  Only in Dir 2: $only2"
    echo ""

    local choice
    choice=$(printf '%s\n' \
        "common - View common files ($common)" \
        "unique1 - View files only in Dir 1 ($only1)" \
        "unique2 - View files only in Dir 2 ($only2)" \
        "exit - Done" | \
        fzf --prompt="Select > " --height=30%)

    case "$choice" in
        common*)
            comm -12 "$list1" "$list2" | \
                fzf --prompt="Common files > " \
                    --preview="echo 'In both directories: {}'" \
                    > "$RESULT_FILE" || true
            ;;
        unique1*)
            comm -23 "$list1" "$list2" | \
                fzf --prompt="Only in Dir 1 > " \
                    --preview="bat --style=plain --color=always '$CWD/{}' 2>/dev/null | head -30" \
                    > "$RESULT_FILE" || true
            ;;
        unique2*)
            comm -13 "$list1" "$list2" | \
                fzf --prompt="Only in Dir 2 > " \
                    --preview="bat --style=plain --color=always '$dir2/{}' 2>/dev/null | head -30" \
                    > "$RESULT_FILE" || true
            ;;
    esac

    rm -f "$list1" "$list2"
}

action_file_select() {
    local file_type="${EXTRA_ARGS[0]:-f}"  # f=files, d=dirs, e=empty
    local pattern="${EXTRA_ARGS[1]:-}"

    local fd_args="--type $file_type"
    [[ -n "$pattern" ]] && fd_args="$fd_args -e $pattern"

    fd $fd_args . "$CWD" 2>/dev/null | \
        fzf $FZF_DEFAULT_OPTS \
            --multi \
            --prompt="Select > " \
            --preview='
                if [[ -d {} ]]; then
                    ls -la {} | head -20
                else
                    bat --style=plain --color=always --line-range :40 {} 2>/dev/null || file {}
                fi
            ' \
            --preview-window=right:55%:wrap \
            --header="TAB: select | ENTER: confirm | CTRL-Y: copy path" \
            --bind "ctrl-y:execute-silent(echo {} | wl-copy 2>/dev/null)" \
            > "$RESULT_FILE" || true
}

# ==============================================================================
# Main Dispatch
# ==============================================================================

case "$ACTION" in
    rga-search|rga|search)
        action_rga_search
        ;;
    duplicates|dupes|dup)
        action_duplicates
        ;;
    large-files|large|big)
        action_large_files
        ;;
    archive-list|archive|list)
        action_archive_list
        ;;
    dir-compare|compare|diff)
        action_dir_compare
        ;;
    file-select|select|files)
        action_file_select
        ;;
    *)
        echo "Unknown action: $ACTION"
        echo "Run '$0' without arguments for help"
        exit 1
        ;;
esac

# ==============================================================================
# Result Handling
# ==============================================================================

# If result file has content, emit to yazi
if [[ -s "$RESULT_FILE" ]]; then
    RESULT=$(head -1 "$RESULT_FILE")

    log "Result: $RESULT"

    # Determine how to handle the result
    if [[ -f "$RESULT" ]]; then
        # It's a file - reveal it in yazi
        log "Emitting reveal for file: $RESULT"
        ya emit reveal "$RESULT" 2>/dev/null || true
    elif [[ -d "$RESULT" ]]; then
        # It's a directory - cd to it
        log "Emitting cd for directory: $RESULT"
        ya emit cd "$RESULT" 2>/dev/null || true
    else
        # Might be a relative path - try to make it absolute
        if [[ -f "$CWD/$RESULT" ]]; then
            log "Emitting reveal for relative file: $CWD/$RESULT"
            ya emit reveal "$CWD/$RESULT" 2>/dev/null || true
        elif [[ -d "$CWD/$RESULT" ]]; then
            log "Emitting cd for relative dir: $CWD/$RESULT"
            ya emit cd "$CWD/$RESULT" 2>/dev/null || true
        else
            log "Result is not a valid path: $RESULT"
        fi
    fi
fi

log "Action $ACTION completed"
