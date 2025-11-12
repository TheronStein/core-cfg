
case "$1" in
"new")
tmux display-popup -E -w 90% -h 90% -b heavy             -T "Notes - New"             "$HOME/.core/cfg/tmux/scripts/notes-popup.sh"
;;
"rename")
tmux display-popup -E -w 50% -h 10% -b rounded             -T "Rename Notes Session"             "$HOME/.core/cfg/tmux/scripts/notes-rename-session.sh"
;;
"list")
tmux display-popup -E -w 60% -h 50% -b rounded             -T "Notes Windows"             "tmux list-windows -t notes -F \"1: nvim [160x38]\" | less"
;;
"help")
tmux display-message "Notes: C-Space n=new, C-Space r=rename, C-Space l=list, C-Space d=detach"
;;
*)

if [[ "$1" =~ ^[0-9]+$ ]]; then
tmux switch-client -t "notes:$1" 2>/dev/null ||                 tmux display-message "Window $1 not found in notes session"
fi
;;
esac
