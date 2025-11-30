#!/usr/bin/env zsh
# =============================================================================
# Widget Registry System
# =============================================================================
# Description: Automatically registers all custom widgets with ZLE and
#              configures them for zsh-syntax-highlighting compatibility
#
# This module solves the "unhandled ZLE widget" warnings from zsh-syntax-highlighting
# by ensuring all custom widgets are properly registered and marked.
#
# Dependencies: None (but should be loaded before zsh-syntax-highlighting)
# =============================================================================

# Function: register-all-widgets
# Description: Discovers and registers all custom widget functions with ZLE
# Usage: register-all-widgets [--verbose]
# Returns: 0 on success
register-all-widgets() {
    local verbose=0
    [[ "$1" == "--verbose" ]] && verbose=1

    local widget_count=0
    local registered_count=0
    local -a all_widgets=()
    local -a unregistered_widgets=()

    # Discover all widget functions in the current environment
    # Pattern 1: Functions starting with widget::
    for func in ${(k)functions[(I)widget::*]}; do
        all_widgets+=($func)
    done

    # Pattern 2: Functions starting with _doc_ and ending with _widget
    for func in ${(k)functions[(I)_doc_*_widget]}; do
        all_widgets+=($func)
    done

    # Pattern 3: FZF git widgets
    for func in ${(k)functions[(I)fzf-git-*]}; do
        all_widgets+=($func)
    done

    # Pattern 4: Other known widget patterns
    local -a known_widgets=(
        doc-menu
        magic-enter
        magic-space
        expand-snippet
        wezterm-copy-cmd
        up-line-or-beginning-search
        down-line-or-beginning-search
    )

    for widget in $known_widgets; do
        if (( ${+functions[$widget]} )); then
            all_widgets+=($widget)
        fi
    done

    # Remove duplicates
    all_widgets=(${(u)all_widgets})

    # Check which widgets are not registered with ZLE
    for widget in $all_widgets; do
        widget_count=$((widget_count + 1))
        if ! zle -l | grep -q "^${widget}$"; then
            unregistered_widgets+=($widget)
            # Register the widget with ZLE
            zle -N $widget
            registered_count=$((registered_count + 1))
        fi
    done

    # Only report if verbose mode is enabled or if running interactively with new widgets
    if [[ $verbose -eq 1 ]]; then
        if [[ ${#unregistered_widgets[@]} -gt 0 ]]; then
            echo "Widget Registry: Registered ${registered_count} new widgets:"
            for widget in $unregistered_widgets; do
                echo "  - $widget"
            done
        fi
        echo "Widget Registry: Total ${widget_count} custom widgets active"
    elif [[ $registered_count -gt 0 ]]; then
        # Silent mode - only show a brief summary if new widgets were registered
        echo "Widget Registry: ${widget_count} widgets active (+${registered_count} new)"
    fi

    # Export widget list for zsh-syntax-highlighting
    export ZSH_HIGHLIGHT_WIDGETS=($all_widgets)

    return 0
}

# Function: configure-zsh-highlight-widgets
# Description: Configures zsh-syntax-highlighting to recognize custom widgets
# Usage: configure-zsh-highlight-widgets
# Returns: 0 on success
configure-zsh-highlight-widgets() {
    # This function sets up the widget wrapping for zsh-syntax-highlighting
    # It should be called AFTER zsh-syntax-highlighting is loaded

    if (( ! ${+_zsh_highlight} )); then
        # zsh-syntax-highlighting not loaded yet
        return 1
    fi

    # Get all custom widgets
    local -a custom_widgets=()

    # Pattern 1: widget:: namespace
    for func in ${(k)functions[(I)widget::*]}; do
        custom_widgets+=($func)
    done

    # Pattern 2: _doc_*_widget
    for func in ${(k)functions[(I)_doc_*_widget]}; do
        custom_widgets+=($func)
    done

    # Pattern 3: fzf-git-*
    for func in ${(k)functions[(I)fzf-git-*]}; do
        custom_widgets+=($func)
    done

    # Pattern 4: Other known widgets
    local -a known_widgets=(
        doc-menu
        magic-enter
        magic-space
        expand-snippet
        wezterm-copy-cmd
        up-line-or-beginning-search
        down-line-or-beginning-search
    )

    for widget in $known_widgets; do
        if (( ${+functions[$widget]} )); then
            custom_widgets+=($widget)
        fi
    done

    # Remove duplicates
    custom_widgets=(${(u)custom_widgets})

    # For each custom widget, wrap it for zsh-syntax-highlighting
    for widget in $custom_widgets; do
        # Check if widget exists in ZLE
        if zle -l | grep -q "^${widget}$"; then
            # Create wrapper function if not already wrapped
            if [[ ${widgets[$widget]:-} != user:_zsh_highlight_widget_* ]]; then
                # Save the original widget implementation
                eval "_zsh_highlight_widget_orig_${widget}() { zle .${widget} -- \"\$@\" }"

                # Create the wrapper
                eval "_zsh_highlight_widget_${widget}() {
                    _zsh_highlight
                    _zsh_highlight_widget_orig_${widget} \"\$@\"
                }"

                # Register the wrapper
                zle -N $widget _zsh_highlight_widget_${widget}
            fi
        fi
    done

    return 0
}

# Function: widget-registry-report
# Description: Provides a detailed report of all registered widgets
# Usage: widget-registry-report
widget-registry-report() {
    local -a all_widgets=()
    local -a registered_widgets=()
    local -a unregistered_widgets=()

    # Collect all widget functions
    for func in ${(k)functions[(I)widget::*]} ${(k)functions[(I)_doc_*_widget]} ${(k)functions[(I)fzf-git-*]}; do
        all_widgets+=($func)
    done

    # Add known widgets
    local -a known_widgets=(doc-menu magic-enter magic-space expand-snippet wezterm-copy-cmd)
    for widget in $known_widgets; do
        if (( ${+functions[$widget]} )); then
            all_widgets+=($widget)
        fi
    done

    # Remove duplicates and sort
    all_widgets=(${(ou)all_widgets})

    echo "═══════════════════════════════════════════════════════════════════"
    echo "                    WIDGET REGISTRY REPORT                         "
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo "Total Widget Functions Found: ${#all_widgets}"
    echo ""

    # Check registration status
    for widget in $all_widgets; do
        if zle -l | grep -q "^${widget}$"; then
            registered_widgets+=($widget)
        else
            unregistered_widgets+=($widget)
        fi
    done

    echo "Registered with ZLE: ${#registered_widgets}"
    if [[ ${#registered_widgets} -gt 0 ]]; then
        echo "─────────────────────────────────────────────────────────────"
        for widget in $registered_widgets; do
            # Check if it has a keybinding
            local binding=$(bindkey | grep " ${widget}$" | head -1 | awk '{print $1}')
            if [[ -n "$binding" ]]; then
                printf "  ✓ %-40s [%s]\n" "$widget" "$binding"
            else
                printf "  ✓ %-40s\n" "$widget"
            fi
        done
    fi

    echo ""
    echo "Not Registered: ${#unregistered_widgets}"
    if [[ ${#unregistered_widgets} -gt 0 ]]; then
        echo "─────────────────────────────────────────────────────────────"
        for widget in $unregistered_widgets; do
            echo "  ✗ $widget"
        done
    fi

    # Check zsh-syntax-highlighting status
    echo ""
    echo "ZSH Syntax Highlighting Status:"
    echo "─────────────────────────────────────────────────────────────"
    if (( ${+_zsh_highlight} )); then
        echo "  ✓ zsh-syntax-highlighting is loaded"
        if (( ${+ZSH_HIGHLIGHT_WIDGETS} )); then
            echo "  ✓ Custom widgets exported: ${#ZSH_HIGHLIGHT_WIDGETS}"
        else
            echo "  ✗ Custom widgets not exported to ZSH_HIGHLIGHT_WIDGETS"
        fi
    else
        echo "  ✗ zsh-syntax-highlighting not loaded"
    fi

    echo "═══════════════════════════════════════════════════════════════════"
}

# Function: fix-widget-registration
# Description: Fixes registration for specific problematic widgets
# Usage: fix-widget-registration [--verbose]
fix-widget-registration() {
    local verbose=0
    [[ "$1" == "--verbose" ]] && verbose=1

    local -a problem_widgets=(
        widget::doc-generate
        doc-menu
        fzf-git-add
        _doc_quick_ref_widget
        _doc_search_widget
        _doc_help_widget
    )

    [[ $verbose -eq 1 ]] && echo "Fixing widget registration for known problematic widgets..."

    for widget in $problem_widgets; do
        # Check if function exists
        if (( ${+functions[$widget]} )); then
            # Register with ZLE if not already registered
            if ! zle -l | grep -q "^${widget}$"; then
                zle -N $widget
                [[ $verbose -eq 1 ]] && echo "  ✓ Registered: $widget"
            else
                [[ $verbose -eq 1 ]] && echo "  • Already registered: $widget"
            fi
        else
            # Widget function doesn't exist, check if it's bound to a key
            if bindkey | grep -q " ${widget}$"; then
                [[ $verbose -eq 1 ]] && echo "  ⚠ Warning: $widget is bound but function doesn't exist"

                # Create a placeholder function if needed
                case $widget in
                    widget::doc-generate)
                        # Create wrapper for doc-generate
                        eval "widget::doc-generate() {
                            if (( \${+functions[doc-generate]} )); then
                                doc-generate \"\$@\"
                            else
                                echo 'Documentation generation not available'
                            fi
                        }"
                        zle -N widget::doc-generate
                        [[ $verbose -eq 1 ]] && echo "    → Created wrapper for widget::doc-generate"
                        ;;
                    doc-menu)
                        # This should exist in documentation.zsh
                        if (( ${+functions[doc-menu]} )); then
                            zle -N doc-menu
                            [[ $verbose -eq 1 ]] && echo "    → Registered existing doc-menu function"
                        fi
                        ;;
                esac
            fi
        fi
    done
}

# Initialization function - runs ONCE when module is sourced
# This ensures widgets are registered before any other modules that might use them
_widget_registry_init() {
    # Check if already initialized in this session
    if [[ -n "${_WIDGET_REGISTRY_INITIALIZED}" ]]; then
        return 0
    fi

    # Mark as initialized
    export _WIDGET_REGISTRY_INITIALIZED=1

    # Register all widgets silently
    register-all-widgets

    # Fix specific problematic widgets silently
    fix-widget-registration

    # If zsh-syntax-highlighting is loaded, configure it
    if (( ${+_zsh_highlight} )); then
        configure-zsh-highlight-widgets
    else
        # Set up a ONE-TIME hook to configure when it loads
        _widget_registry_syntax_highlight_hook() {
            if (( ${+_zsh_highlight} )); then
                configure-zsh-highlight-widgets
                # Remove this hook after it runs
                precmd_functions=(${precmd_functions:#_widget_registry_syntax_highlight_hook})
            fi
        }
        # Only add if not already in precmd_functions
        if [[ ! " ${precmd_functions[*]} " =~ " _widget_registry_syntax_highlight_hook " ]]; then
            precmd_functions+=(_widget_registry_syntax_highlight_hook)
        fi
    fi
}

# Run initialization immediately when this module is sourced
# This happens ONCE during shell startup, not on every command
_widget_registry_init

# Make functions available for manual use if needed
# Usage: widget-registry-report  (for debugging)
#        register-all-widgets --verbose  (for manual re-registration with output)