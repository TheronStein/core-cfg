# Collection of utility functions

# URL encode/decode
function urlencode() {
    python3 -c "import urllib.parse; print(urllib.parse.quote('$*'))"
}

function urldecode() {
    python3 -c "import urllib.parse; print(urllib.parse.unquote('$*'))"
}

# JSON utilities
function json-pretty() {
    if [[ -f "$1" ]]; then
        jq '.' "$1"
    else
        echo "$1" | jq '.'
    fi
}

function json-keys() {
    if [[ -f "$1" ]]; then
        jq 'keys' "$1"
    else
        echo "$1" | jq 'keys'
    fi
}

# Base64 encode/decode
function b64encode() {
    if [[ -f "$1" ]]; then
        base64 < "$1"
    else
        echo -n "$*" | base64
    fi
}

function b64decode() {
    if [[ -f "$1" ]]; then
        base64 -d < "$1"
    else
        echo "$*" | base64 -d
    fi
}

# Generate random strings
function random-string() {
    local length="${1:-32}"
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
    echo
}

function random-password() {
    local length="${1:-16}"
    tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' < /dev/urandom | head -c "$length"
    echo
}

# Timestamps
function timestamp() {
    date +%s
}

function timestamp-to-date() {
    date -d "@${1:?Timestamp required}"
}

# IP utilities
function myip() {
    curl -s ifconfig.me
}

function localip() {
    ip route get 1 | awk '{print $NF;exit}' 2>/dev/null || \
    ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -v 127.0.0.1 | awk '{print $2}'
}
