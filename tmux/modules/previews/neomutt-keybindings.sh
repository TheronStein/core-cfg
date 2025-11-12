#!/usr/bin/env bash

# Display neomutt keybindings in a tmux pane

KEYBINDINGS_FILE="$HOME/.core/cfg/neomutt/keybindings-reference.txt"

# Catppuccin Mocha colors
BG="\033[48;2;30;30;46m"    # #1e1e2e
FG="\033[38;2;205;214;244m" # #cdd6f4
HEADER="\033[38;2;137;180;250m" # #89b4fa (blue)
SECTION="\033[38;2;166;227;161m" # #a6e3a1 (green)
BIND="\033[38;2;249;226;175m"   # #f9e2af (yellow)
RESET="\033[0m"

# Set terminal background
printf "${BG}${FG}"
clear

# Read and display with colors
while IFS= read -r line; do
  if [[ "$line" =~ ^[A-Z].+$ ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
    # Main headers (all caps lines)
    echo -e "${HEADER}${line}${RESET}"
  elif [[ "$line" =~ ^-+$ ]]; then
    # Underlines
    echo -e "${HEADER}${line}${RESET}"
  elif [[ "$line" =~ ^[[:space:]]*$ ]]; then
    # Empty lines
    echo ""
  elif [[ "$line" =~ ^[[:space:]]*[a-zA-Z\<\^] ]]; then
    # Keybinding lines - highlight the key
    key=$(echo "$line" | awk -F ' - ' '{print $1}')
    desc=$(echo "$line" | awk -F ' - ' '{$1=""; print substr($0,2)}')
    if [[ -n "$desc" ]]; then
      printf "${BIND}%-20s${RESET} - ${FG}%s${RESET}\n" "$key" "$desc"
    else
      echo -e "${FG}${line}${RESET}"
    fi
  else
    # Regular text
    echo -e "${FG}${line}${RESET}"
  fi
done < "$KEYBINDINGS_FILE"

# Keep pane open
read -r
