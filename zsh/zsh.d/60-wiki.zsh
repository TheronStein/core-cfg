# Wiki/documentation management

# Wiki locations (from their config)
export WIKI_DIR="${HOME}/Documents/wiki/vimwiki"
export WIKI_MAIN="${WIKI_DIR}/_index.md"

# Quick wiki access functions
function vw() {
    ${EDITOR:-nvim} "${WIKI_MAIN}"
}

function vwz() {
    ${EDITOR:-nvim} "${WIKI_DIR}/code/languages/zsh/_index.md"
}

function vwsearch() {
    local pattern="${1:?Search pattern required}"
    rg -i "$pattern" "$WIKI_DIR" --type md
}

# Quick note taking
function note() {
    local title="${1:-quick-note}"
    local date=$(date +%Y-%m-%d)
    local file="${WIKI_DIR}/daily/${date}-${title}.md"
    [[ -n "${WIKI_DIR}" ]] && mkdir -p "${WIKI_DIR}/daily"
    ${EDITOR:-nvim} "$file"
}

# Cheatsheet system
CHEAT_DIR="${HOME}/.config/cheat"

function cheat() {
    local topic="${1:?Topic required}"
    local file="${CHEAT_DIR}/${topic}.md"
    
    if [[ -f "$file" ]]; then
        bat --style=plain "$file"
    else
        echo "Cheatsheet not found. Available:"
        ls "${CHEAT_DIR}"/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//'
    fi
}

function cheat-edit() {
    local topic="${1:?Topic required}"
    local file="${CHEAT_DIR}/${topic}.md"
    [[ -n "${CHEAT_DIR}" ]] && mkdir -p "${CHEAT_DIR}"
    ${EDITOR:-nvim} "$file"
}

# Quick reference via FZF
if (( $+commands[fzf] )); then
    function cheat-fzf() {
        local file
        file=$(ls "${CHEAT_DIR}"/*.md 2>/dev/null | fzf --preview 'bat --style=plain {}')
        [[ -n "$file" ]] && bat --style=plain "$file"
    }
fi
