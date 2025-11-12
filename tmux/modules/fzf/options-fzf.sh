#!/usr/bin/env bash
# ~/.tmux/scripts/options-fzf.sh

# Grab the raw list of global options
raw_opts=$(tmux show-options -g)

# Function to regenerate the grouped, ANSI‑header list
generate_grouped() {
  echo "$raw_opts" | sort -t- -k1,1 | awk -F- '
    BEGIN { prev="" }
    {
      split($1,a,"-")
      grp=a[1]
      if (grp!=prev) {
        # colour‑code the group header
        printf("\033[1;33m%s\033[0m\n", grp)
        prev=grp
      }
      printf("  %s\n", $0)
    }
  '
}

# Run fzf on that grouped list
generate_grouped | fzf \
  --ansi \
  --delimiter="  " \
  --preview='zsh -c "
    line=\"{0}\"
    # if it’s a group header (ANSI yellow), strip the codes & show all in that group
    if [[ \"\$line\" =~ ^\x1b ]]; then
      grp=$(echo -e \"\$line\" | sed -E \"s/\x1b\[1;33m(.+)\x1b\[0m/\1/\")
      # filter raw_opts by that prefix
      echo \"$raw_opts\" | awk -F- -v g=\"\$grp\" '\'$1==g{print}'\'
    else
      # show just the one option you highlighted
      echo \"\$line\"
    fi
  "' \
  --bind 'enter:execute-silent(
      # Extract the option name (first word of field2)
      opt=$(echo "{2}" | awk "{print \$1}")
      # prompt you for a new value, apply it immediately
      tmux command-prompt -p "Set $opt" "set-option -g $opt %%"
    )+reload:shell ~/.config/tmux/scripts/options-fzf.sh'
