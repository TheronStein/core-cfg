#!/usr/bin/env bash
exec "$(dirname "$0")/popup-handler.sh" "python3 $CORE_PROJ/kdesms-tui/main.py"
