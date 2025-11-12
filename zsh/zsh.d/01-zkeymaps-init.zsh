#!/usr/bin/env zsh
# Initialize Zkeymaps associative array to fix plugin errors
# This must be loaded early (01-) before plugins that use it

# Declare Zkeymaps as a global associative array
typeset -gA Zkeymaps=()