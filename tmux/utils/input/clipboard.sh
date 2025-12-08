#!/bin/bash

SESSION_TYPE=${XDG_SESSION_TYPE:-$(loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type | cut -d= -f2)}

copy() {
    if [ "$SESSION_TYPE" = "wayland" ]; then
        wl-copy
    else
        xclip -selection clipboard
    fi
}

paste() {
    if [ "$SESSION_TYPE" = "wayland" ]; then
        wl-paste
    else
        xclip -selection clipboard -o
    fi
}

case "$1" in
copy)
    copy
    ;;
paste)
    paste
    ;;
*)
    echo "Usage: $0 {copy|paste}"
    exit 1
    ;;
esac
