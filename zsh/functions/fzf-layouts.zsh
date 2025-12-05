#!/usr/bin/env zsh

# fzf-layouts.zsh - Interactively switch fzf layouts
# Place this file at $CORE_CFG/zsh/functions/fzf-layouts.zsh
# Exports the new FZF_DEFAULT_OPTS in the current session

# Determine script path for reliable self-reference
typeset THIS_SCRIPT="${0:A}"
if [[ -z "$THIS_SCRIPT" || ! -f "$THIS_SCRIPT" ]]; then
  THIS_SCRIPT="${CORE_CFG:-$HOME/.core/.sys/cfg}/zsh/functions/fzf-layouts.zsh"
fi

# If we're in the relaunch phase (after applying the new opts), show the demo
if [[ -n "${FZF_LAYOUT_SWITCHER_RELAUNCH:-}" ]]; then
  unset FZF_LAYOUT_SWITCHER_RELAUNCH
  clear
  print "\033[1;32mNew fzf layout applied to this session!\033[0m\n"
  print "Here's a quick demo (listing your home directory):\n"
  print "Current FZF_DEFAULT_OPTS:\n\033[1;34m$FZF_DEFAULT_OPTS\033[0m\n"
  # Simple demo without nesting fzf
  command ls -1 ~ | head -20 | fzf --preview='ls -lah ~/{}'
  return 0
fi

# Temporary file for storing presets (accessible to preview subprocess)
typeset PRESETS_FILE=$(mktemp)
trap 'rm -f "$PRESETS_FILE"' EXIT

# Preset list: "Name|options"
# Write presets to temp file so preview can access them
cat > "$PRESETS_FILE" << 'PRESETS_EOF'
Classic reverse|--height=40% --layout=reverse --border --info=inline
With margin and padding|--height=40% --layout=reverse --info=inline --border --margin=1 --padding=1
Sharp borders with markers|--height=50% --layout=reverse --border=sharp --info=inline --prompt='> ' --pointer='>' --marker='*'
Reverse-list for previews|--height=60% --layout=reverse-list --border=double --info=inline --margin=5%,2%
Minimal floating window|--height=~100% --layout=reverse --info=hidden --border=none --margin=10%
Fancy themed dark|--height=50% --layout=reverse --info=inline --border=rounded --margin=1,2 --padding=1 --color=bg+:#223344,fg+:#ddeeff,hl:#ff99cc,hl+:#ff66aa,info:#778899,prompt:#bbccdd
Default reset|
PRESETS_EOF

# Build display list with numbers
typeset -a display_lines
typeset i=1
while IFS='|' read -r name opts; do
  display_lines+=("$i. $name")
  ((i++))
done < "$PRESETS_FILE"

# Interactive selection with preview showing the options (not nested fzf)
typeset selection
selection=$(printf '%s\n' "${display_lines[@]}" |
  fzf --ansi \
      --header='Select an fzf layout preset (Enter to apply, Esc to cancel)' \
      --prompt='Layout> ' \
      --height=60% --layout=reverse --border=rounded \
      --preview="
        # Extract line number from selection
        idx=\$(echo {} | cut -d. -f1)
        # Get the corresponding preset line
        line=\$(sed -n \"\${idx}p\" '$PRESETS_FILE')
        opts=\$(echo \"\$line\" | cut -d'|' -f2-)

        echo -e '\033[1;33mLayout Options:\033[0m'
        echo ''
        if [[ -z \"\$opts\" ]]; then
          echo '  (Default fzf settings - no custom options)'
        else
          # Display options one per line for readability
          echo \"\$opts\" | tr ' ' '\n' | sed 's/^/  /'
        fi
        echo ''
        echo -e '\033[1;36mPreview of fzf appearance:\033[0m'
        echo '  This layout will be applied when you press Enter.'
      " \
      --preview-window=right:50%:wrap)

# Exit if nothing selected
if [[ -z "$selection" ]]; then
  print "No layout selected."
  return 0
fi

# Extract chosen options
typeset idx chosen_line chosen_opts chosen_name
idx=$(echo "$selection" | cut -d. -f1)
chosen_line=$(sed -n "${idx}p" "$PRESETS_FILE")
chosen_name="${chosen_line%%|*}"
chosen_opts="${chosen_line#*|}"

# Apply permanently to ~/.zshrc (replace or add)
typeset config_file="$HOME/.zshrc"

if grep -q '^export FZF_DEFAULT_OPTS=' "$config_file" 2>/dev/null; then
  if [[ $(uname) == Darwin ]]; then
    sed -i '' "/^export FZF_DEFAULT_OPTS=/c\\
export FZF_DEFAULT_OPTS='$chosen_opts'" "$config_file"
  else
    sed -i "/^export FZF_DEFAULT_OPTS=/c\\
export FZF_DEFAULT_OPTS='$chosen_opts'" "$config_file"
  fi
  print "\033[1;32mUpdated FZF_DEFAULT_OPTS in $config_file\033[0m"
else
  print "\n# fzf layout preset (selected $(date +'%Y-%m-%d'))\nexport FZF_DEFAULT_OPTS='$chosen_opts'" >> "$config_file"
  print "\033[1;32mAdded FZF_DEFAULT_OPTS to $config_file\033[0m"
fi

print "\033[1;32mApplied preset:\033[0m $chosen_name"

# Apply immediately to the current shell session
export FZF_DEFAULT_OPTS="$chosen_opts"

# Show confirmation
print ""
print "\033[1;33mNew FZF_DEFAULT_OPTS:\033[0m"
if [[ -z "$chosen_opts" ]]; then
  print "  (Default - no custom options)"
else
  echo "$chosen_opts" | tr ' ' '\n' | sed 's/^/  /'
fi
print ""
print "The new layout is now active in this session."
print "New terminal sessions will also use this layout."
