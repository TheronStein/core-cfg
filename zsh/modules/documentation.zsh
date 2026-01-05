#!/usr/bin/env zsh
# ============================================================================
# Documentation System for ZSH Configuration
# ============================================================================
# Purpose: Comprehensive documentation management system with interactive
#          browsing, searching, editing, and generation capabilities.
#
# Features:
# - Interactive documentation browser with fzf integration
# - Context-aware help based on current environment
# - Documentation search and quick reference
# - Auto-generation from code comments
# - Easy documentation addition and editing workflows
#
# Dependencies:
# - fzf: Interactive fuzzy finder
# - bat or less: Document viewer
# - rg: Fast text search
# - nvim or $EDITOR: Documentation editing
# ============================================================================

# Configuration
export ZSH_DOC_BASE="${ZSH_DOC_BASE:-$HOME/.core/.cortex}"
export ZSH_DOC_ZSH="${ZSH_DOC_BASE}/zsh"
export ZSH_CONFIG_BASE="${ZSH_CONFIG_BASE:-$HOME/.core/.sys/dev/zsh}"
export ZSH_DOC_VIEWER="${ZSH_DOC_VIEWER:-bat}"
export ZSH_DOC_EDITOR="${ZSH_DOC_EDITOR:-${EDITOR:-nvim}}"

# Documentation categories mapping
typeset -gA ZSH_DOC_CATEGORIES=(
    [zsh]="$ZSH_DOC_BASE/zsh"
    [system]="$ZSH_DOC_BASE/system"
    [linux]="$ZSH_DOC_BASE/linux"
    [neovim]="$ZSH_DOC_BASE/system/neovim"
    [tmux]="$ZSH_DOC_BASE/system/tmux"
    [git]="$ZSH_DOC_BASE/linux/git"
    [ai]="$ZSH_DOC_BASE/ai"
    [server]="$ZSH_DOC_BASE/server"
    [development]="$ZSH_DOC_BASE/development"
    [reference]="$ZSH_DOC_BASE/.ref"
)

# ============================================================================
# Core Documentation Functions
# ============================================================================

# Function: doc-browse
# Description: Interactive documentation browser with category selection
# Usage: doc-browse [category]
# Dependencies: fzf, bat/less
doc-browse() {
    local category="${1:-}"
    local base_dir doc_file

    if [[ -n "$category" && -n "${ZSH_DOC_CATEGORIES[$category]}" ]]; then
        base_dir="${ZSH_DOC_CATEGORIES[$category]}"
    else
        # Show category selector
        category=$(printf "%s\n" "${(k)ZSH_DOC_CATEGORIES[@]}" | \
            fzf --prompt="Select category> " \
                --header="Documentation Categories" \
                --preview="echo 'Documents in {}:' && find '${ZSH_DOC_CATEGORIES[{}]}' -name '*.md' 2>/dev/null | head -20" \
                --preview-window=right:50%:wrap)

        [[ -z "$category" ]] && return 1
        base_dir="${ZSH_DOC_CATEGORIES[$category]}"
    fi

    # Browse documents in selected category
    doc_file=$(find "$base_dir" -name "*.md" -o -name "*.txt" 2>/dev/null | \
        sed "s|^$base_dir/||" | \
        fzf --prompt="Documentation ($category)> " \
            --header="Press ENTER to view, CTRL-E to edit, CTRL-Y to copy path" \
            --preview="$ZSH_DOC_VIEWER --color=always --style=numbers,header '$base_dir/{}' 2>/dev/null || cat '$base_dir/{}'" \
            --preview-window=right:65%:wrap \
            --bind="ctrl-e:execute($ZSH_DOC_EDITOR '$base_dir/{}')" \
            --bind="ctrl-y:execute(echo -n '$base_dir/{}' | wl-copy)")

    [[ -n "$doc_file" ]] && doc-view "$base_dir/$doc_file"
}

# Function: doc-view
# Description: View a documentation file with proper formatting
# Usage: doc-view <file>
# Dependencies: bat/less
doc-view() {
    local file="$1"
    [[ ! -f "$file" ]] && { echo "File not found: $file" >&2; return 1; }

    if command -v bat &>/dev/null; then
        bat --color=always --style=numbers,header,grid --paging=always "$file"
    else
        less -R "$file"
    fi
}

# Function: doc-search
# Description: Search across all documentation
# Usage: doc-search [query]
# Dependencies: rg, fzf
doc-search() {
    local query="${*:-}"
    local result

    if [[ -z "$query" ]]; then
        echo -n "Search query: "
        read -r query
    fi

    [[ -z "$query" ]] && return 1

    # Search with ripgrep and show results in fzf
    result=$(rg --color=always --line-number --no-heading \
             --smart-case --max-columns=150 \
             "$query" "$ZSH_DOC_BASE" 2>/dev/null | \
        fzf --ansi \
            --prompt="Search results> " \
            --header="Documentation search: $query" \
            --delimiter=: \
            --preview='file={1}; line={2}; bat --color=always --highlight-line={2} --line-range=$((line>5?line-5:1)):$((line+20)) {1} 2>/dev/null || sed -n "$((line>5?line-5:1)),$((line+20))p" {1}' \
            --preview-window=right:65%:wrap:+{2}-5 \
            --bind='enter:execute(nvim {1} +{2})')
}

# Function: doc-quick-ref
# Description: Quick reference for ZSH functions, widgets, and keybindings
# Usage: doc-quick-ref [type]
# Types: functions, widgets, keybindings, aliases, snippets
doc-quick-ref() {
    local ref_type="${1:-}"
    local content

    if [[ -z "$ref_type" ]]; then
        ref_type=$(printf "functions\nwidgets\nkeybindings\naliases\nsnippets\nintegrations" | \
            fzf --prompt="Quick reference> " \
                --header="Select reference type")
    fi

    case "$ref_type" in
        functions)
            # Extract function documentation from ZSH config files
            find "$ZSH_CONFIG_BASE" -name "*.zsh" -exec grep -l "^function\|^.*() {" {} \; | \
                xargs grep -B2 "^function\|^.*() {" | \
                grep -E "^#|^function|^[a-z_-]+\(\)" | \
                fzf --prompt="Functions> " \
                    --header="ZSH Functions Reference" \
                    --preview='echo {} | grep -oE "[a-z_-]+(\(\)|function [a-z_-]+)" | sed "s/function //" | sed "s/()//" | xargs -I{} grep -A20 "^{}\(\)\|^function {}" '$ZSH_CONFIG_BASE'/**/*.zsh' \
                    --preview-window=right:65%:wrap
            ;;

        widgets)
            # Show all defined widgets
            zle -la | \
                fzf --prompt="Widgets> " \
                    --header="ZLE Widgets" \
                    --preview='widget={}; grep -B2 -A15 "function _$widget\|_$widget()" '$ZSH_CONFIG_BASE'/**/*.zsh 2>/dev/null || echo "Built-in widget: {}"' \
                    --preview-window=right:65%:wrap
            ;;

        keybindings)
            # Show current keybindings
            bindkey | \
                fzf --prompt="Keybindings> " \
                    --header="Current Key Bindings" \
                    --preview='echo "Key sequence: $(echo {} | cut -d" " -f1)"; echo "Widget/Command: $(echo {} | cut -d" " -f2-)"; echo; echo "Widget details:"; widget=$(echo {} | cut -d" " -f2 | tr -d "\""); grep -B2 -A10 "function $widget\|$widget()" '$ZSH_CONFIG_BASE'/**/*.zsh 2>/dev/null || echo "Built-in or undefined"' \
                    --preview-window=right:65%:wrap
            ;;

        aliases)
            # Show all aliases with their definitions
            alias | \
                fzf --prompt="Aliases> " \
                    --header="Command Aliases" \
                    --preview='echo "Alias: $(echo {} | cut -d= -f1)"; echo "Command: $(echo {} | cut -d= -f2-)"; echo; echo "Related documentation:"; alias_name=$(echo {} | cut -d= -f1); grep -i "$alias_name" '$ZSH_DOC_BASE'/**/*.md 2>/dev/null | head -10' \
                    --preview-window=right:65%:wrap
            ;;

        snippets)
            # Show pet snippets if available
            if command -v pet &>/dev/null; then
                pet list | \
                    fzf --prompt="Snippets> " \
                        --header="Command Snippets (pet)" \
                        --preview='pet list | grep -A3 "{}"' \
                        --preview-window=right:65%:wrap
            else
                echo "Pet snippet manager not installed"
            fi
            ;;

        integrations)
            # Show available integrations
            find "$ZSH_CONFIG_BASE/integrations" -name "*.zsh" | \
                xargs basename -a | sed 's/\.zsh$//' | \
                fzf --prompt="Integrations> " \
                    --header="Available Integrations" \
                    --preview='integration={}; bat --color=always '$ZSH_CONFIG_BASE'/integrations/{}.zsh 2>/dev/null || cat '$ZSH_CONFIG_BASE'/integrations/{}.zsh' \
                    --preview-window=right:65%:wrap
            ;;
    esac
}

# Function: doc-add
# Description: Add new documentation with template
# Usage: doc-add [category] [title]
doc-add() {
    local category="${1:-}"
    local title="${2:-}"
    local doc_path template

    # Select category if not provided
    if [[ -z "$category" ]]; then
        category=$(printf "%s\n" "${(k)ZSH_DOC_CATEGORIES[@]}" | \
            fzf --prompt="Select category> " \
                --header="Documentation Category")
        [[ -z "$category" ]] && return 1
    fi

    # Get title if not provided
    if [[ -z "$title" ]]; then
        echo -n "Document title: "
        read -r title
        [[ -z "$title" ]] && return 1
    fi

    # Sanitize title for filename
    local filename=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g').md
    doc_path="${ZSH_DOC_CATEGORIES[$category]}/$filename"

    # Create directory if needed
    mkdir -p "$(dirname "$doc_path")"

    # Create document with template
    cat > "$doc_path" << EOF
# $title

## Overview
[Brief description of the topic]

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Usage](#usage)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [References](#references)

## Prerequisites
- List any requirements
- Dependencies
- System requirements

## Configuration
Describe any configuration needed.

## Usage
Explain how to use this feature/tool.

## Examples
### Example 1: Basic Usage
\`\`\`bash
# Example command
\`\`\`

### Example 2: Advanced Usage
\`\`\`bash
# Advanced example
\`\`\`

## Troubleshooting
Common issues and solutions.

## References
- [Link to related documentation]()
- [External resources]()

---
*Created: $(date '+%Y-%m-%d')*
*Category: $category*
EOF

    echo "Created: $doc_path"
    $ZSH_DOC_EDITOR "$doc_path"
}

# Function: doc-edit
# Description: Edit existing documentation
# Usage: doc-edit [search_term]
doc-edit() {
    local search="${1:-}"
    local doc_file

    if [[ -n "$search" ]]; then
        # Search for specific file
        doc_file=$(find "$ZSH_DOC_BASE" -name "*$search*.md" 2>/dev/null | \
            fzf --prompt="Edit document> " \
                --header="Select document to edit" \
                --preview="bat --color=always --style=numbers,header {} 2>/dev/null || cat {}" \
                --preview-window=right:65%:wrap)
    else
        # Browse all documents
        doc_file=$(find "$ZSH_DOC_BASE" -name "*.md" 2>/dev/null | \
            fzf --prompt="Edit document> " \
                --header="Select document to edit" \
                --preview="bat --color=always --style=numbers,header {} 2>/dev/null || cat {}" \
                --preview-window=right:65%:wrap)
    fi

    [[ -n "$doc_file" ]] && $ZSH_DOC_EDITOR "$doc_file"
}

# Function: doc-generate
# Description: Generate documentation from code comments
# Usage: doc-generate <file> [output]
doc-generate() {
    local input_file="$1"
    local output_file="${2:-}"

    [[ ! -f "$input_file" ]] && { echo "File not found: $input_file" >&2; return 1; }

    # Determine output file
    if [[ -z "$output_file" ]]; then
        local basename=$(basename "$input_file" .zsh)
        output_file="$ZSH_DOC_ZSH/generated/${basename}.md"
        mkdir -p "$(dirname "$output_file")"
    fi

    # Extract documentation from file
    {
        echo "# Documentation: $(basename "$input_file")"
        echo
        echo "Generated from: \`$input_file\`"
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo
        echo "## Functions"
        echo

        # Extract function documentation
        grep -E "^# (Function|Widget):|^function |^[a-z_-]+\(\)" "$input_file" | \
        while IFS= read -r line; do
            if [[ "$line" =~ ^#.*(Function|Widget): ]]; then
                echo
                echo "### ${line#*: }"
            elif [[ "$line" =~ ^#.*Description: ]]; then
                echo "${line#*: }"
            elif [[ "$line" =~ ^#.*Usage: ]]; then
                echo
                echo "**Usage:** \`${line#*: }\`"
            elif [[ "$line" =~ ^#.*Dependencies: ]]; then
                echo
                echo "**Dependencies:** ${line#*: }"
            elif [[ "$line" =~ ^function ]] || [[ "$line" =~ .*\(\) ]]; then
                func_name=$(echo "$line" | sed -E 's/^function //; s/\(\).*//')
                if [[ "$func_name" != *"#"* ]]; then
                    echo
                    echo "#### \`$func_name\`"
                fi
            fi
        done

        echo
        echo "## Aliases"
        echo
        grep "^alias " "$input_file" | while IFS= read -r line; do
            echo "- \`$line\`"
        done

        echo
        echo "## Exports"
        echo
        grep "^export " "$input_file" | while IFS= read -r line; do
            echo "- \`$line\`"
        done

    } > "$output_file"

    echo "Generated documentation: $output_file"
    doc-view "$output_file"
}

# Function: doc-context
# Description: Show context-aware documentation based on current environment
# Usage: doc-context
doc-context() {
    local context docs=()

    # Detect context
    if git rev-parse --git-dir &>/dev/null; then
        docs+=("Git repository detected")
        docs+=("$ZSH_DOC_BASE/linux/git.md")
    fi

    if [[ -f "docker-compose.yml" || -f "Dockerfile" ]]; then
        docs+=("Docker environment detected")
        docs+=("$ZSH_DOC_BASE/system/docker")
    fi

    if [[ -f "package.json" ]]; then
        docs+=("Node.js project detected")
        docs+=("$ZSH_DOC_BASE/system/javascript.md")
    fi

    if [[ -f "Cargo.toml" ]]; then
        docs+=("Rust project detected")
        docs+=("$ZSH_DOC_BASE/linux/rust.md")
    fi

    if [[ -f "go.mod" ]]; then
        docs+=("Go project detected")
        docs+=("$ZSH_DOC_BASE/system/golang.md")
    fi

    if [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
        docs+=("Python project detected")
        docs+=("$ZSH_DOC_BASE/system/python.md")
    fi

    # Show context menu
    if [[ ${#docs[@]} -gt 0 ]]; then
        printf "%s\n" "${docs[@]}" | \
            fzf --prompt="Context documentation> " \
                --header="Relevant documentation for current context" \
                --preview='[[ -f {} ]] && bat --color=always {} 2>/dev/null || echo "Context: {}"' \
                --preview-window=right:65%:wrap | \
            xargs -r doc-view
    else
        echo "No specific context detected. Opening general documentation..."
        doc-browse
    fi
}

# Function: doc-menu
# Description: Main documentation menu hub
# Usage: doc-menu
doc-menu() {
    local choice

    choice=$(cat <<EOF | fzf --prompt="Documentation> " --header="Documentation System"
Browse Documentation
Search Documentation
Quick Reference
View Context Help
Add New Documentation
Edit Documentation
Generate from Code
Reorganize Documentation
View ZSH Config Docs
Open Documentation Index
EOF
)

    case "$choice" in
        "Browse Documentation") doc-browse ;;
        "Search Documentation") doc-search ;;
        "Quick Reference") doc-quick-ref ;;
        "View Context Help") doc-context ;;
        "Add New Documentation") doc-add ;;
        "Edit Documentation") doc-edit ;;
        "Generate from Code")
            local file=$(find "$ZSH_CONFIG_BASE" -name "*.zsh" | \
                fzf --prompt="Select file> " \
                    --preview="bat --color=always {}")
            [[ -n "$file" ]] && doc-generate "$file"
            ;;
        "Reorganize Documentation") doc-reorganize ;;
        "View ZSH Config Docs") doc-zsh-config ;;
        "Open Documentation Index") doc-index ;;
    esac
}

# Function: doc-reorganize
# Description: Reorganize documentation structure
# Usage: doc-reorganize
doc-reorganize() {
    echo "Reorganizing documentation structure..."

    # Create organized structure
    local dirs=(
        "$ZSH_DOC_BASE/zsh/core"
        "$ZSH_DOC_BASE/zsh/widgets"
        "$ZSH_DOC_BASE/zsh/functions"
        "$ZSH_DOC_BASE/zsh/integrations"
        "$ZSH_DOC_BASE/zsh/snippets"
        "$ZSH_DOC_BASE/zsh/keybindings"
        "$ZSH_DOC_BASE/zsh/generated"
        "$ZSH_DOC_BASE/tools/terminal"
        "$ZSH_DOC_BASE/tools/development"
        "$ZSH_DOC_BASE/tools/system"
        "$ZSH_DOC_BASE/workflows"
        "$ZSH_DOC_BASE/reference/quick"
        "$ZSH_DOC_BASE/reference/guides"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
    done

    echo "Documentation structure reorganized!"
    echo "New structure created at: $ZSH_DOC_BASE"
}

# Function: doc-zsh-config
# Description: View documentation for current ZSH configuration
# Usage: doc-zsh-config
doc-zsh-config() {
    local config_docs="$ZSH_DOC_ZSH/current-config.md"

    # Generate current configuration documentation
    {
        echo "# Current ZSH Configuration Documentation"
        echo
        echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo
        echo "## Configuration Files"
        echo
        find "$ZSH_CONFIG_BASE" -name "*.zsh" -type f | while read -r file; do
            echo "### $(basename "$file")"
            echo "Path: \`$file\`"
            echo
            # Extract first comment block
            sed -n '/^#/,/^[^#]/p' "$file" | head -20
            echo
        done

        echo "## Loaded Integrations"
        echo
        find "$ZSH_CONFIG_BASE/integrations" -name "*.zsh" | while read -r file; do
            echo "- $(basename "$file" .zsh)"
        done

        echo
        echo "## Available Widgets"
        echo
        zle -la | head -50

        echo
        echo "## Key Bindings Summary"
        echo
        bindkey | head -50

    } > "$config_docs"

    doc-view "$config_docs"
}

# Function: doc-index
# Description: Generate and view documentation index
# Usage: doc-index
doc-index() {
    local index_file="$ZSH_DOC_BASE/INDEX.md"

    {
        echo "# Documentation Index"
        echo
        echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo

        for category in "${(k)ZSH_DOC_CATEGORIES[@]}"; do
            echo "## $category"
            echo
            find "${ZSH_DOC_CATEGORIES[$category]}" -name "*.md" 2>/dev/null | \
                head -20 | while read -r file; do
                echo "- [$(basename "$file" .md)]($(realpath --relative-to="$ZSH_DOC_BASE" "$file"))"
            done
            echo
        done

    } > "$index_file"

    doc-view "$index_file"
}

# ============================================================================
# ZLE Widgets for Documentation
# ============================================================================

# Widget: _doc_help_widget
# Description: Context-aware help widget
# Keybinding suggestion: Alt-H
function _doc_help_widget() {
    local cmd="${LBUFFER##* }"

    if [[ -n "$cmd" ]]; then
        # Try to find documentation for the command
        if command -v "$cmd" &>/dev/null; then
            man "$cmd" 2>/dev/null || "$cmd" --help 2>/dev/null | less
        else
            doc-search "$cmd"
        fi
    else
        doc-menu
    fi
}
zle -N _doc_help_widget

# Widget: _doc_quick_ref_widget
# Description: Quick reference widget
# Keybinding suggestion: Alt-R
function _doc_quick_ref_widget() {
    doc-quick-ref
    zle reset-prompt
}
zle -N _doc_quick_ref_widget

# Widget: _doc_search_widget
# Description: Documentation search widget
# Keybinding suggestion: Alt-/
function _doc_search_widget() {
    doc-search
    zle reset-prompt
}
zle -N _doc_search_widget

# ============================================================================
# Initialization
# ============================================================================

# Create documentation structure if it doesn't exist
if [[ ! -d "$ZSH_DOC_BASE/zsh" ]]; then
    doc-reorganize
fi

# Set up aliases for quick access
alias docs='doc-menu'
alias docb='doc-browse'
alias docs='doc-search'
alias docq='doc-quick-ref'
alias doca='doc-add'
alias doce='doc-edit'
alias docg='doc-generate'
alias doch='doc-context'
alias doci='doc-index'

# Functions are automatically available in ZSH (no export needed)

# =============================================================================
# WIDGET WRAPPERS FOR KEYBINDINGS
# =============================================================================

# Widget: widget::doc-generate
# Description: Generate documentation from selected ZSH file
# Keybinding: Ctrl-X H
widget::doc-generate() {
    local file
    file=$(find "$ZSH_CONFIG_BASE" -name "*.zsh" | \
        fzf --prompt="Select file to generate docs> " \
            --preview="bat --color=always {}" \
            --preview-window="right:60%:wrap")

    if [[ -n "$file" ]]; then
        doc-generate "$file"
        echo "Documentation generated for: $file"
    fi
}

# Register widget wrappers with ZLE
zle -N widget::doc-generate
zle -N doc-menu

# Print loading message
# Startup message removed for faster shell initialization
# Type 'docs' to access the documentation system