#!/bin/bash

echo "Complete Configuration Test"
echo "==========================="

# Test all components
tests=(
    "type ex"           "Archive extraction"
    "type calc"         "Calculator"
    "type serve"        "HTTP server"
    "type grt"          "Git root"
    "type zmv"          "Zmv"
    "bindkey '^R'"      "Ctrl+R binding"
    "alias -g G"        "Global aliases"
)

echo -e "\nFunction & Alias Tests:"
for ((i=1; i<=${#tests[@]}; i+=2)); do
    name="${tests[i]}"
    cmd="${tests[i-1]}"
    
    if zsh -ic "$cmd" &>/dev/null; then
        printf "  %-20s ✓\n" "$name:"
    else
        printf "  %-20s ✗\n" "$name:"
    fi
done

echo -e "\nPerformance Metrics:"
zsh -ic 'zsh-stats-full 2>/dev/null | head -8'

echo -e "\nStartup Time:"
time zsh -i -c exit
