#!/usr/bin/env bash
exec "$(dirname "$0")/popup-handler.sh" "python3 $CORE_PROJ/environment/kdesms-tui-fixes/main.py"
