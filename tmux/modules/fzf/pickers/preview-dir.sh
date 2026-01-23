#!/usr/bin/env bash
# Preview script for directory picker
# Expands ~ to $HOME and shows eza tree

dir="$1"
dir="${dir/#\~/$HOME}"

if [[ -d "$dir" ]]; then
    eza -ahlT -L=2 -s=extension --group-directories-first --icons --git --git-ignore --no-user --color=always --color-scale=all --color-scale-mode=gradient "$dir"
else
    echo "Not a directory: $dir"
fi
