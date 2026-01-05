#!/usr/bin/env zsh
# compile-config.zsh - Compile stable ZSH files to .zwc for faster loading
#
# Usage: ./compile-config.zsh [--force] [--clean] [--status]
#
# Options:
#   --force   Recompile all files regardless of timestamps
#   --clean   Remove all .zwc files
#   --status  Show compilation status of files

setopt extendedglob

ZSH_CORE="${ZSH_CORE:-$HOME/.core/.sys/cfg/zsh}"

# Files that are stable and benefit from compilation
# Add files here only when they're not being actively modified
typeset -a STABLE_FILES=(
    # Integration modules (rarely changed)
    "$ZSH_CORE/integrations/zoxide.zsh"
    "$ZSH_CORE/integrations/kubernetes.zsh"
    "$ZSH_CORE/integrations/ansible.zsh"
    "$ZSH_CORE/integrations/systemd.zsh"
    "$ZSH_CORE/integrations/pacman.zsh"
    "$ZSH_CORE/integrations/ssh.zsh"

    # Core config files (after stabilization)
    # "$ZSH_CORE/00-options.zsh"
    # "$ZSH_CORE/01-environment.zsh"
)

# Directories to compile all .zsh files within
typeset -a STABLE_DIRS=(
    "$ZSH_CORE/completions"
)

#=============================================================================
# FUNCTIONS
#=============================================================================

compile_file() {
    local file="$1"
    local force="${2:-0}"
    local zwc="${file}.zwc"

    if [[ ! -f "$file" ]]; then
        print -P "%F{red}[SKIP]%f $file (not found)"
        return 1
    fi

    # Check if recompilation needed
    if [[ $force -eq 0 && -f "$zwc" && "$zwc" -nt "$file" ]]; then
        print -P "%F{blue}[OK]%f   $file (up to date)"
        return 0
    fi

    if zcompile "$file" 2>/dev/null; then
        print -P "%F{green}[COMPILED]%f $file"
        return 0
    else
        print -P "%F{red}[FAILED]%f $file"
        return 1
    fi
}

clean_file() {
    local file="$1"
    local zwc="${file}.zwc"

    if [[ -f "$zwc" ]]; then
        rm -f "$zwc"
        print -P "%F{yellow}[REMOVED]%f $zwc"
    fi
}

status_file() {
    local file="$1"
    local zwc="${file}.zwc"

    if [[ ! -f "$file" ]]; then
        print -P "%F{red}[MISSING]%f $file"
    elif [[ ! -f "$zwc" ]]; then
        print -P "%F{yellow}[UNCOMPILED]%f $file"
    elif [[ "$file" -nt "$zwc" ]]; then
        print -P "%F{yellow}[STALE]%f $file"
    else
        print -P "%F{green}[COMPILED]%f $file"
    fi
}

#=============================================================================
# MAIN
#=============================================================================

main() {
    local mode="compile"
    local force=0

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --force) force=1 ;;
            --clean) mode="clean" ;;
            --status) mode="status" ;;
            --help|-h)
                print "Usage: $0 [--force] [--clean] [--status]"
                print ""
                print "Options:"
                print "  --force   Recompile all files regardless of timestamps"
                print "  --clean   Remove all .zwc files"
                print "  --status  Show compilation status of files"
                return 0
                ;;
        esac
    done

    print -P "%F{cyan}=== ZSH Config Compilation ===%f"
    print ""

    # Process individual files
    print -P "%F{cyan}Stable Files:%f"
    for file in "${STABLE_FILES[@]}"; do
        case "$mode" in
            compile) compile_file "$file" "$force" ;;
            clean)   clean_file "$file" ;;
            status)  status_file "$file" ;;
        esac
    done

    # Process directories
    print ""
    print -P "%F{cyan}Stable Directories:%f"
    for dir in "${STABLE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            for file in "$dir"/*.zsh(N); do
                case "$mode" in
                    compile) compile_file "$file" "$force" ;;
                    clean)   clean_file "$file" ;;
                    status)  status_file "$file" ;;
                esac
            done
        else
            print -P "%F{yellow}[SKIP]%f $dir (directory not found)"
        fi
    done

    print ""
    print -P "%F{cyan}Done.%f"
}

main "$@"
