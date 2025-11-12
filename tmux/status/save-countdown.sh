#!/bin/bash

# Get the save interval from tmux (default 15 minutes)
save_interval=$(tmux show-option -gv @continuum-save-interval 2>/dev/null || echo "15")

# Get the last save time from the resurrect directory
resurrect_dir=$(tmux show-option -gv @resurrect-dir 2>/dev/null || echo "~/.tmux/resurrect")
resurrect_dir=$(eval echo $resurrect_dir) # Expand ~ if present

last_file="$resurrect_dir/last"
if [[ -f "$last_file" ]] && [[ -L "$last_file" ]]; then
    # Get the timestamp from the symlink target
    target=$(readlink "$last_file")
    if [[ $target =~ tmux_resurrect_([0-9]{8}T[0-9]{6})\.txt ]]; then
        timestamp=${BASH_REMATCH[1]}
        # Convert to epoch time (YYYYMMDDTHHMMSS -> epoch)
        last_save_epoch=$(date -d "${timestamp:0:8} ${timestamp:9:2}:${timestamp:11:2}:${timestamp:13:2}" +%s 2>/dev/null)
    fi
fi

current_epoch=$(date +%s)

if [[ -n "$last_save_epoch" ]]; then
    # Calculate time since last save
    time_since_save=$((current_epoch - last_save_epoch))
    save_interval_seconds=$((save_interval * 60))

    # Calculate time until next save
    time_until_save=$((save_interval_seconds - time_since_save))

    if [[ $time_until_save -le 0 ]]; then
        echo "💾 Saving..."
    else
        minutes=$((time_until_save / 60))
        seconds=$((time_until_save % 60))
        if [[ $minutes -gt 0 ]]; then
            echo "💾 ${minutes}m${seconds}s"
        else
            echo "💾 ${seconds}s"
        fi
    fi
else
    # No previous save found
    echo "💾 ${save_interval}m"
fi
