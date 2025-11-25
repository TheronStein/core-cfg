# ~/.core/.sys/configs/zsh/zsh.d/90-help-system.zsh
# Interactive help system for Zsh configuration with colors

# Create help directory if it doesn't exist
export ZSH_HELP_DIR="${ZDOTDIR}/help"
[[ -d "$ZSH_HELP_DIR" ]] || mkdir -p "$ZSH_HELP_DIR"

# Color definitions
typeset -A HELP_COLORS=(
    header    $'\e[1;36m'   # Bold cyan
    section   $'\e[1;33m'   # Bold yellow
    key       $'\e[1;32m'   # Bold green
    desc      $'\e[0;37m'   # White
    cmd       $'\e[1;35m'   # Bold magenta
    reset     $'\e[0m'      # Reset
    dim       $'\e[2;37m'   # Dim white
    highlight $'\e[1;37;44m' # White on blue background
)

# Main help function with colorized FZF menu
function zsh-help() {
    local choice
    choice=$(cat <<EOF | fzf \
        --height=60% \
        --border=rounded \
        --margin=1 \
        --padding=1 \
        --header=$'╭─ 🚀 \e[1;36mZsh Help System\e[0m ─╮\nPress Enter to select, Esc to exit' \
        --header-first \
        --preview-window=hidden \
        --ansi \
        --color='header:cyan,border:blue,prompt:green,pointer:magenta' \
        --prompt='▶ ' \
        --pointer='→'
$'\e[1;36m📚 Keybindings\e[0m - View all keyboard shortcuts'
$'\e[1;32m🔧 Functions\e[0m - List available custom functions'
$'\e[1;33m🔌 Plugins\e[0m - Show loaded plugins and their features'
$'\e[1;35m🎨 Aliases\e[0m - Display all aliases'
$'\e[1;34m📖 Quick Reference\e[0m - Common commands cheatsheet'
$'\e[1;31m🔍 Search Help\e[0m - Search all documentation'
$'\e[1;37m⚡ Live Keybind Test\e[0m - Test keybindings interactively'
$'\e[1;32m💾 Generate Docs\e[0m - Export all help to markdown'
EOF
)
    
    case "$choice" in
        *Keybindings*) zsh-help-keys ;;
        *Functions*) zsh-help-functions ;;
        *Plugins*) zsh-help-plugins ;;
        *Aliases*) zsh-help-aliases ;;
        *Reference*) zsh-help-reference ;;
        *Search*) zsh-help-search ;;
        *Test*) zsh-keybind-test ;;
        *Generate*) zsh-help-generate-docs ;;
    esac
}

# Show all keybindings with colorized output
function zsh-help-keys() {
    {
        print -P "${HELP_COLORS[header]}╔════════════════════════════════════════╗"
        print -P "${HELP_COLORS[header]}║         Zsh Keybindings                ║"
        print -P "${HELP_COLORS[header]}╚════════════════════════════════════════╝${HELP_COLORS[reset]}"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ Navigation${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[key]}Ctrl+A${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Move to beginning of line"
        print -P "  ${HELP_COLORS[key]}Ctrl+E${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Move to end of line"
        print -P "  ${HELP_COLORS[key]}Ctrl+F${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Accept autosuggestion"
        print -P "  ${HELP_COLORS[key]}Alt+←/→${HELP_COLORS[reset]}     ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Move word backward/forward"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ Editing${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[key]}Ctrl+W${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Delete word backward"
        print -P "  ${HELP_COLORS[key]}Ctrl+K${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Delete from cursor to end"
        print -P "  ${HELP_COLORS[key]}Ctrl+U${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Delete from cursor to beginning"
        print -P "  ${HELP_COLORS[key]}Ctrl+Y${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Paste (yank)"
        print -P "  ${HELP_COLORS[key]}Ctrl+Z${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Undo"
        print -P "  ${HELP_COLORS[key]}Ctrl+X,E${HELP_COLORS[reset]}    ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Edit command in \$EDITOR"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ History${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[key]}Ctrl+R${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Search history with FZF"
        print -P "  ${HELP_COLORS[key]}Ctrl+P/N${HELP_COLORS[reset]}    ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Previous/Next command"
        print -P "  ${HELP_COLORS[key]}↑/↓${HELP_COLORS[reset]}         ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Browse history"
        print -P "  ${HELP_COLORS[key]}Ctrl+G${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Toggle per-directory history"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ FZF Navigation${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[key]}Ctrl+T${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Find files with FZF"
        print -P "  ${HELP_COLORS[key]}Alt+C${HELP_COLORS[reset]}       ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Change directory with FZF"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ Git Integration${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[key]}Ctrl+X,G${HELP_COLORS[reset]}    ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Git checkout branch"
        print -P "  ${HELP_COLORS[key]}Ctrl+X,B${HELP_COLORS[reset]}    ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Browse git branches"
        print -P "  ${HELP_COLORS[key]}Ctrl+X g${HELP_COLORS[reset]}    ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Git status"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ Custom Widgets${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[key]}Ctrl+?${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} ${HELP_COLORS[highlight]}This help menu${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[key]}Ctrl+X,S${HELP_COLORS[reset]}    ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Prepend sudo"
        print -P "  ${HELP_COLORS[key]}Ctrl+X,C${HELP_COLORS[reset]}    ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Copy command line"
        print -P "  ${HELP_COLORS[key]}Ctrl+L${HELP_COLORS[reset]}      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Clear screen"
        echo ""
        
        print -P "${HELP_COLORS[dim]}──────────────────────────────────────────${HELP_COLORS[reset]}"
        print -P "${HELP_COLORS[section]}All Active Bindings:${HELP_COLORS[reset]}"
        bindkey | sed 's/^/  /' | head -30
        print -P "${HELP_COLORS[dim]}(showing first 30, pipe to less for all)${HELP_COLORS[reset]}"
    } | ${PAGER:-less -R}
}

# List functions with colored categories
function zsh-help-functions() {
    {
        print -P "${HELP_COLORS[header]}╔════════════════════════════════════════╗"
        print -P "${HELP_COLORS[header]}║         Custom Functions               ║"
        print -P "${HELP_COLORS[header]}╚════════════════════════════════════════╝${HELP_COLORS[reset]}"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ File Operations${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[cmd]}mkcd${HELP_COLORS[reset]} <dir>        ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Create and enter directory"
        print -P "  ${HELP_COLORS[cmd]}bak${HELP_COLORS[reset]} <file>        ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Backup file (.bak)"
        print -P "  ${HELP_COLORS[cmd]}ex${HELP_COLORS[reset]} <archive>      ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Extract any archive"
        print -P "  ${HELP_COLORS[cmd]}compress${HELP_COLORS[reset]} <files>  ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Create archive"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ Navigation${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[cmd]}fcd${HELP_COLORS[reset]}               ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Fuzzy change directory"
        print -P "  ${HELP_COLORS[cmd]}fup${HELP_COLORS[reset]}               ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Go up with FZF"
        print -P "  ${HELP_COLORS[cmd]}grt${HELP_COLORS[reset]}               ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Go to git root"
        print -P "  ${HELP_COLORS[cmd]}d${HELP_COLORS[reset]}                 ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Directory stack"
        print -P "  ${HELP_COLORS[cmd]}1-9${HELP_COLORS[reset]}               ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Jump to stack position"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ Git Functions${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[cmd]}fco${HELP_COLORS[reset]}               ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Checkout branch (FZF)"
        print -P "  ${HELP_COLORS[cmd]}fbr${HELP_COLORS[reset]}               ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Browse branches"
        print -P "  ${HELP_COLORS[cmd]}gll${HELP_COLORS[reset]}               ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Pretty git log"
        print -P "  ${HELP_COLORS[cmd]}gcm${HELP_COLORS[reset]} <msg>         ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Quick commit"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ System${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[cmd]}sysinfo${HELP_COLORS[reset]}           ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} System information"
        print -P "  ${HELP_COLORS[cmd]}ports${HELP_COLORS[reset]}             ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Show listening ports"
        print -P "  ${HELP_COLORS[cmd]}topmem${HELP_COLORS[reset]} [n]        ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Top memory users"
        print -P "  ${HELP_COLORS[cmd]}weather${HELP_COLORS[reset]} [city]    ${HELP_COLORS[dim]}→${HELP_COLORS[reset]} Weather report"
        echo ""
        
        print -P "${HELP_COLORS[dim]}──────────────────────────────────────────${HELP_COLORS[reset]}"
        print -P "${HELP_COLORS[section]}All Available Functions:${HELP_COLORS[reset]}"
        print -l ${(ok)functions} | grep -v "^_" | column | head -20
        print -P "${HELP_COLORS[dim]}(showing first 20 functions)${HELP_COLORS[reset]}"
    } | ${PAGER:-less -R}
}

# Interactive keybind tester with colors
function zsh-keybind-test() {
    print -P "${HELP_COLORS[header]}╔════════════════════════════════════════╗"
    print -P "${HELP_COLORS[header]}║      Keybind Tester                    ║"
    print -P "${HELP_COLORS[header]}╚════════════════════════════════════════╝${HELP_COLORS[reset]}"
    print -P "${HELP_COLORS[dim]}Press keys to see their bindings (Ctrl+C to exit)${HELP_COLORS[reset]}"
    echo ""
    
    while true; do
        print -nP "${HELP_COLORS[section]}Press a key: ${HELP_COLORS[reset]}"
        read -k key
        echo ""
        
        local binding=$(bindkey "$key" 2>/dev/null)
        if [[ -n "$binding" ]]; then
            local widget=$(echo "$binding" | awk '{print $2}')
            print -P "  ${HELP_COLORS[key]}Key:${HELP_COLORS[reset]} $key"
            print -P "  ${HELP_COLORS[cmd]}Widget:${HELP_COLORS[reset]} $widget"
            
            # Show description if available
            case "$widget" in
                *fzf*) print -P "  ${HELP_COLORS[dim]}Type: FZF integration${HELP_COLORS[reset]}" ;;
                *autosuggest*) print -P "  ${HELP_COLORS[dim]}Type: Autosuggestion${HELP_COLORS[reset]}" ;;
                *history*) print -P "  ${HELP_COLORS[dim]}Type: History navigation${HELP_COLORS[reset]}" ;;
            esac
        else
            print -P "  ${HELP_COLORS[dim]}No binding for this key${HELP_COLORS[reset]}"
        fi
        echo ""
    done
}

# Colored quick reference
function zsh-help-reference() {
    {
        print -P "${HELP_COLORS[header]}╔════════════════════════════════════════╗"
        print -P "${HELP_COLORS[header]}║      Zsh Quick Reference               ║"
        print -P "${HELP_COLORS[header]}╚════════════════════════════════════════╝${HELP_COLORS[reset]}"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ Essential Keys${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[key]}Tab${HELP_COLORS[reset]}    Complete"
        print -P "  ${HELP_COLORS[key]}Ctrl+R${HELP_COLORS[reset]} Search history"
        print -P "  ${HELP_COLORS[key]}Ctrl+T${HELP_COLORS[reset]} Find files"
        print -P "  ${HELP_COLORS[key]}Alt+C${HELP_COLORS[reset]}  Change directory"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ History Tricks${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[cmd]}!!${HELP_COLORS[reset]}     Last command"
        print -P "  ${HELP_COLORS[cmd]}!\$${HELP_COLORS[reset]}     Last argument"
        print -P "  ${HELP_COLORS[cmd]}!*${HELP_COLORS[reset]}     All arguments"
        print -P "  ${HELP_COLORS[cmd]}^x^y${HELP_COLORS[reset]}   Replace x with y"
        echo ""
        
        print -P "${HELP_COLORS[section]}▶ Globbing${HELP_COLORS[reset]}"
        print -P "  ${HELP_COLORS[cmd]}**/*.txt${HELP_COLORS[reset]}  Recursive"
        print -P "  ${HELP_COLORS[cmd]}*(.)${HELP_COLORS[reset]}      Files only"
        print -P "  ${HELP_COLORS[cmd]}*(/)${HELP_COLORS[reset]}      Dirs only"
        print -P "  ${HELP_COLORS[cmd]}*(*)${HELP_COLORS[reset]}      Executables"
    } | ${PAGER:-less -R}
}

# Search with highlighted results
function zsh-help-search() {
    print -nP "${HELP_COLORS[section]}Search for: ${HELP_COLORS[reset]}"
    read query

    {
        print -P "${HELP_COLORS[header]}Search Results: ${HELP_COLORS[cmd]}$query${HELP_COLORS[reset]}"
        echo ""

        print -P "${HELP_COLORS[section]}▶ Functions${HELP_COLORS[reset]}"
        print -l ${(ok)functions} | grep --color=always -i "$query" | sed 's/^/  /'

        print -P "${HELP_COLORS[section]}▶ Aliases${HELP_COLORS[reset]}"
        alias | grep --color=always -i "$query" | sed 's/^/  /'

        print -P "${HELP_COLORS[section]}▶ Keybindings${HELP_COLORS[reset]}"
        bindkey | grep --color=always -i "$query" | sed 's/^/  /'
    } | ${PAGER:-less -R}
}

# Show all plugins
function zsh-help-plugins() {
    {
        print -P "${HELP_COLORS[header]}╔════════════════════════════════════════╗"
        print -P "${HELP_COLORS[header]}║         Loaded Plugins                 ║"
        print -P "${HELP_COLORS[header]}╚════════════════════════════════════════╝${HELP_COLORS[reset]}"
        echo ""

        if (( $+commands[zinit] )); then
            print -P "${HELP_COLORS[section]}▶ Zinit Plugins${HELP_COLORS[reset]}"
            zinit list
        else
            print -P "${HELP_COLORS[dim]}No plugin manager detected${HELP_COLORS[reset]}"
        fi
    } | ${PAGER:-less -R}
}

# Show all aliases
function zsh-help-aliases() {
    {
        print -P "${HELP_COLORS[header]}╔════════════════════════════════════════╗"
        print -P "${HELP_COLORS[header]}║         Aliases                        ║"
        print -P "${HELP_COLORS[header]}╚════════════════════════════════════════╝${HELP_COLORS[reset]}"
        echo ""

        print -P "${HELP_COLORS[section]}▶ All Aliases${HELP_COLORS[reset]}"
        alias | sed 's/^/  /'
    } | ${PAGER:-less -R}
}

# Generate documentation
function zsh-help-generate-docs() {
    local output_file="${ZSH_HELP_DIR}/zsh-config-docs.md"

    {
        echo "# Zsh Configuration Documentation"
        echo ""
        echo "Generated: $(date)"
        echo ""

        echo "## Keybindings"
        echo ""
        bindkey
        echo ""

        echo "## Functions"
        echo ""
        print -l ${(ok)functions} | grep -v "^_"
        echo ""

        echo "## Aliases"
        echo ""
        alias
        echo ""

        if (( $+commands[zinit] )); then
            echo "## Plugins"
            echo ""
            zinit list
        fi
    } > "$output_file"

    print -P "${HELP_COLORS[section]}Documentation generated: ${HELP_COLORS[cmd]}$output_file${HELP_COLORS[reset]}"
}

# Create widget and bindings
widget-help-menu() {
    zsh-help
    zle reset-prompt
}
zle -N widget-help-menu

# bindkey -s '^[OP' 'zsh-help\n'  # F1
# bindkey -s '^[[11~' 'zsh-help\n'  # F1 alternative

bindkey 'F1' widget-help-menu

# Main binding - Ctrl+? 
bindkey '^?' widget-help-menu

# Alternative bindings
bindkey '^_' widget-help-menu   # Ctrl+/
bindkey '^Xh' widget-help-menu  # Ctrl+X h

# Quick aliases
alias zh='zsh-help'
alias '?'='zsh-help'

print -P "${HELP_COLORS[dim]}Help system loaded. Press ${HELP_COLORS[key]}Ctrl+?${HELP_COLORS[dim]} for help${HELP_COLORS[reset]}"
