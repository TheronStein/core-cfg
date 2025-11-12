#!/bin/bash
# Monitor active rsync/rclone transfers and show progress

get_rsync_progress() {
    local pids=$(pgrep -x rsync)
    if [ -z "$pids" ]; then
        return 1
    fi

    # Try to extract progress from common log files
    for logfile in /tmp/migration_log.txt /tmp/*rsync*.log; do
        if [ -f "$logfile" ]; then
            local last_line=$(tail -1 "$logfile" 2>/dev/null)

            # Format: to-chk=5627/185512
            if echo "$last_line" | grep -qP 'ir-chk=\d+/\d+'; then
                local numbers=$(echo "$last_line" | grep -oP 'ir-chk=\d+/\d+' | head -1)
                local remaining=$(echo "$numbers" | cut -d= -f2 | cut -d/ -f1)
                local total=$(echo "$numbers" | cut -d= -f2 | cut -d/ -f2)
                local done=$(( total - remaining ))

                # Extract speed (format: "11.81MB/s")
                local speed=$(echo "$last_line" | grep -oP '\d+\.\d+[MKG]B/s' | tail -1)

                if [ "$total" -gt 0 ]; then
                    local percent=$(( 100 - (remaining * 100 / total) ))
                    local label="$done/$total"
                    [ -n "$speed" ] && label="$label @ $speed"
                    echo "rsync:$percent:$label"
                    return 0
                fi
            fi
        fi
    done

    # Fallback: just show that rsync is active
    echo "rsync:?:active"
    return 0
}

get_rclone_progress() {
    # Get rclone processes but exclude mount operations (they're not transfers)
    local pids=$(pgrep -x rclone | while read pid; do
        ps -p $pid -o args= | grep -qv "rclone mount" && echo $pid
    done)
    if [ -z "$pids" ]; then
        return 1
    fi

    # Check rclone log files
    for logfile in /tmp/*rclone*.log /tmp/proton*.log /tmp/stream_backup.log; do
        if [ -f "$logfile" ]; then
            # Look for "Transferred: X / Y, Z%"
            local last_lines=$(tail -20 "$logfile" 2>/dev/null | tac)
            local transfer_line=$(echo "$last_lines" | grep -m1 "Transferred:" 2>/dev/null)

            if [ -n "$transfer_line" ]; then
                # Extract percentage if available
                local percent=$(echo "$transfer_line" | grep -oP '\d+%' | head -1 | tr -d '%')
                # Extract speed and size info
                local speed=$(echo "$transfer_line" | grep -oP '\d+\.?\d*\s*[KMGT]i?B/s' | head -1 | tr -d ' ')
                local size_info=$(echo "$transfer_line" | grep -oP '\d+\.?\d*\s*[KMGT]i?B\s*/\s*\d+\.?\d*\s*[KMGT]i?B' | head -1 | tr -s ' ' | tr ' ' '')

                if [ -n "$percent" ] && [ "$percent" != "0" ]; then
                    local label=""
                    [ -n "$size_info" ] && label="$size_info"
                    [ -n "$speed" ] && label="$label @ $speed"
                    [ -z "$label" ] && label="uploading"
                    echo "rclone:$percent:$label"
                    return 0
                elif [ -n "$speed" ]; then
                    echo "rclone:?:$speed"
                    return 0
                fi
            fi
        fi
    done

    # Fallback: just show that rclone is active
    echo "rclone:?:waiting"
    return 0
}

generate_progress_bar() {
    local percent=$1
    local width=20
    local label=$2

    if [ "$percent" = "?" ]; then
        echo "[#[fg=yellow]$label#[default]]"
        return
    fi

    local filled=$(( percent * width / 100 ))
    local empty=$(( width - filled ))

    # Color based on progress
    local color="#[fg=cyan]"
    if [ "$percent" -ge 75 ]; then
        color="#[fg=green]"
    elif [ "$percent" -ge 50 ]; then
        color="#[fg=yellow]"
    fi

    local bar="["
    for ((i=0; i<filled; i++)); do bar+="${color}█#[default]"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    bar+="]"

    echo "$bar ${color}$percent%#[default] $label"
}

main() {
    local output=""
    local queued_tasks=""

    # Check for rsync
    local rsync_info=$(get_rsync_progress)
    if [ $? -eq 0 ]; then
        IFS=':' read -r type percent label <<< "$rsync_info"
        # Only show if actively transferring (has percentage and not 100%)
        if [ "$percent" != "?" ] && [ "$percent" != "100" ] && [ -n "$percent" ]; then
            local bar=$(generate_progress_bar "$percent" "$label")
            output+="rsync: $bar "
        elif [ "$percent" = "?" ] || [ "$label" = "waiting" ]; then
            # Add to queue list
            [ -n "$queued_tasks" ] && queued_tasks+=", "
            queued_tasks+="rsync"
        fi
    fi

    # Check for rclone
    local rclone_info=$(get_rclone_progress)
    if [ $? -eq 0 ]; then
        IFS=':' read -r type percent label <<< "$rclone_info"
        # Only show if actively transferring (has percentage > 0 and not 100%)
        if [ "$percent" != "?" ] && [ "$percent" != "100" ] && [ "$percent" != "0" ] && [ -n "$percent" ]; then
            local bar=$(generate_progress_bar "$percent" "$label")
            output+="rclone: $bar "
        elif [ "$percent" = "?" ] || [ "$percent" = "0" ] || [ "$label" = "waiting" ]; then
            # Add to queue list with context
            [ -n "$queued_tasks" ] && queued_tasks+=", "
            if [ "$label" = "waiting" ]; then
                queued_tasks+="rclone (waiting)"
            else
                queued_tasks+="rclone"
            fi
        fi
    fi

    # Check for background compression/backup scripts waiting
    local pending_count=0
    if pgrep -f "stream_compress_backup.sh" >/dev/null 2>&1; then
        # Check if it's waiting (not actively compressing)
        if ! pgrep -f "zstd" >/dev/null 2>&1; then
            ((pending_count++))
        fi
    fi

    # Count queued tasks
    [ -n "$queued_tasks" ] && pending_count=$((pending_count + $(echo "$queued_tasks" | tr ',' '\n' | wc -l)))

    # Add notification badge with count if there are pending transfers
    if [ $pending_count -gt 0 ]; then
        output+="#[fg=#f1fc79,bg=#292D3E]#[fg=#444267,bg=#f1fc79] $pending_count #[default]"
    fi

    echo "$output"
}

main
