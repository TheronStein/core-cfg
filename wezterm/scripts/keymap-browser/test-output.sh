#!/usr/bin/env bash
cd "$(dirname "$0")"
jq -r '.categories[] | [.id, .name, .description, (.count // (.keybinds | length)), .is_key_table, (.is_default // false), (.icon // "")] | @tsv' data/keymaps.json | \
while IFS=$'\t' read -r id name desc count is_key_table is_default custom_icon; do
    icon="⌨"
    [[ "$is_key_table" == "true" ]] && icon="⚡"
    [[ -n "$custom_icon" && "$is_default" == "true" ]] && icon="$custom_icon"
    printf "%s\t%s %s | %s (%d)\n" "$id" "$icon" "$name" "$desc" "$count"
done
