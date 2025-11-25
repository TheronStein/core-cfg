#!/usr/bin/env bash

set -euo pipefail

# Get the domain name from the first argument to start/stop/restart
COMMAND="${1:-}"
DOMAIN="${2:-}"

# Set up environment
export HOME="${HOME:-$(eval echo ~$USER)}"
export MUX_DOMAIN="${DOMAIN}"
export WEZTERM_MUX_SERVER="${DOMAIN}"
export MUX_RUNTIME_DIR="${MUX_RUNTIME_DIR:-$HOME/.mux}"
export CORE_WEZTERM_DIR="${CORE_WEZTERM_DIR:-$HOME/.core/.sys/configs/wezterm}"
export WEZTERM_CONFIG_FILE="${WEZTERM_CONFIG_FILE:-$HOME/.core/.sys/configs/wezterm/mux/mux.lua}"

SOCKET_PATH="${MUX_RUNTIME_DIR}/${DOMAIN}.sock"
PID_FILE="${MUX_RUNTIME_DIR}/${DOMAIN}.pid"
LOG_FILE="${MUX_RUNTIME_DIR}/${DOMAIN}.log"

# Ensure runtime directory exists
mkdir -p "${MUX_RUNTIME_DIR}"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [${DOMAIN}] $*" | tee -a "${LOG_FILE}"
}

check_running() {
    if [[ -f "${PID_FILE}" ]]; then
        local pid
        pid=$(cat "${PID_FILE}")
        if kill -0 "${pid}" 2>/dev/null; then
            return 0
        else
            log "Stale PID file found, cleaning up"
            rm -f "${PID_FILE}"
            return 1
        fi
    fi
    return 1
}

start_server() {
    if check_running; then
        log "Mux server already running (PID: $(cat "${PID_FILE}"))"
        return 0
    fi

    log "Starting mux server for domain: ${DOMAIN}"
    log "Socket path: ${SOCKET_PATH}"
    log "Config file: ${WEZTERM_CONFIG_FILE}"

    # Remove stale socket if it exists
    rm -f "${SOCKET_PATH}"

    # Start wezterm mux server
    wezterm start \
        --daemonize \
        --always-new-process \
        2>&1 | tee -a "${LOG_FILE}" &

    local wezterm_pid=$!
    
    # Wait a moment for the process to start
    sleep 1

    # Verify the process is still running
    if kill -0 "${wezterm_pid}" 2>/dev/null; then
        echo "${wezterm_pid}" > "${PID_FILE}"
        log "Mux server started successfully (PID: ${wezterm_pid})"
        
        # Wait for socket to be created
        local timeout=10
        local count=0
        while [[ ! -S "${SOCKET_PATH}" ]] && [[ ${count} -lt ${timeout} ]]; do
            sleep 1
            ((count++))
        done
        
        if [[ -S "${SOCKET_PATH}" ]]; then
            log "Socket created successfully"
            return 0
        else
            log "ERROR: Socket not created within ${timeout} seconds"
            return 1
        fi
    else
        log "ERROR: WezTerm process failed to start"
        return 1
    fi
}

stop_server() {
    if ! check_running; then
        log "Mux server not running"
        # Clean up socket file if it exists
        rm -f "${SOCKET_PATH}"
        return 0
    fi

    local pid
    pid=$(cat "${PID_FILE}")
    log "Stopping mux server (PID: ${pid})"

    # Try graceful shutdown first
    if kill -TERM "${pid}" 2>/dev/null; then
        # Wait for process to exit
        local timeout=10
        local count=0
        while kill -0 "${pid}" 2>/dev/null && [[ ${count} -lt ${timeout} ]]; do
            sleep 1
            ((count++))
        done

        # Force kill if still running
        if kill -0 "${pid}" 2>/dev/null; then
            log "Process didn't exit gracefully, forcing shutdown"
            kill -KILL "${pid}" 2>/dev/null || true
        fi
    fi

    # Clean up
    rm -f "${PID_FILE}" "${SOCKET_PATH}"
    log "Mux server stopped"
}

restart_server() {
    log "Restarting mux server"
    stop_server
    sleep 2
    start_server
}

status_server() {
    if check_running; then
        local pid
        pid=$(cat "${PID_FILE}")
        log "Mux server is running (PID: ${pid})"
        
        if [[ -S "${SOCKET_PATH}" ]]; then
            log "Socket exists: ${SOCKET_PATH}"
        else
            log "WARNING: Socket not found: ${SOCKET_PATH}"
        fi
        return 0
    else
        log "Mux server is not running"
        return 1
    fi
}

# Main command handler
case "${COMMAND}" in
    start)
        [[ -z "${DOMAIN}" ]] && { echo "Error: Domain name required"; exit 1; }
        start_server
        ;;
    stop)
        [[ -z "${DOMAIN}" ]] && { echo "Error: Domain name required"; exit 1; }
        stop_server
        ;;
    restart)
        [[ -z "${DOMAIN}" ]] && { echo "Error: Domain name required"; exit 1; }
        restart_server
        ;;
    status)
        [[ -z "${DOMAIN}" ]] && { echo "Error: Domain name required"; exit 1; }
        status_server
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status} <domain>"
        exit 1
        ;;
esac
