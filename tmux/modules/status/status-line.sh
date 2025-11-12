#!/bin/bash
# Main status line script that combines all monitors

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
    local component="$1"

    case "$component" in
        transfers)
            bash "$SCRIPT_DIR/transfer-monitor.sh"
            ;;
        storage)
            bash "$SCRIPT_DIR/storage-monitor.sh"
            ;;
        cloud)
            bash "$SCRIPT_DIR/cloud-storage-monitor.sh"
            ;;
        left)
            # Left side: local storage + cloud storage
            local storage=$(bash "$SCRIPT_DIR/storage-monitor.sh")
            local cloud=$(bash "$SCRIPT_DIR/cloud-storage-monitor.sh")
            echo "${storage}${cloud}"
            ;;
        right|center)
            # Right/center: transfer progress
            bash "$SCRIPT_DIR/transfer-monitor.sh"
            ;;
        *)
            echo "Usage: $0 {transfers|storage|cloud|left|right|center}"
            exit 1
            ;;
    esac
}

main "$@"
