#!/bin/bash
# ~/.config/eza/alias.sh
# Source this file in your .bashrc/.zshrc: source ~/.config/eza/alias.sh

# Ensure eza always uses color when outputting to terminal
export EZA_COLORS="always"

# Base eza command with git repos at the end (using perl for reliability)
eza_base() {
  eza -alh --group-directories-first --icons --git --git-repos --color=always "$@" |
    perl -pe '
        next if /^total|^$/;
        if (/^(\S+)\s+(\S+)\s+(.*)$/) {
            my ($perms, $git, $rest) = ($1, $2, $3);
            my $rest_clean = $rest;
            $rest_clean =~ s/\x1b\[[0-9;]*m//g;
            my $pad = 65 - length($rest_clean);
            $pad = 0 if $pad < 0;
            $_ = sprintf("%s  %s%s  %s\n", $perms, $rest, " " x $pad, $git);
        }
    '
}

# Standard aliases with color preservation
alias ls='eza --icons --color=always'
alias ll='eza_base'
alias la='eza_base -a'
alias l='eza_base'
alias l.='eza_base -d .*'
alias lt='eza_base --tree'
alias llt='eza_base --tree --level=2'
alias lls='eza_base --sort=size'
alias llm='eza_base --sort=modified'
alias lld='eza_base --only-dirs'
alias llf='eza_base --only-files'

# Git-specific views
alias lg='eza_base --git-ignore'
alias lgs='eza -alh --git --git-repos --color=always --sort=modified | head -20'

# Extended listing with more details
alias lle='eza -alh --group-directories-first --icons --git --git-repos --extended --color=always'

# Function for interactive tree view
lti() {
  local depth="${1:-2}"
  eza --tree --level="$depth" --icons --git --git-repos --color=always
}

# Function to list with specific git status
lgit() {
  local status="${1:-M}" # Default to modified files
  eza_base | grep --color=never "[$status]"
}
