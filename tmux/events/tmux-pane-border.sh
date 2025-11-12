#!/bin/zsh

CACHE_FILE="/tmp/tmux-git-cache-$(echo $1 | sed 's/\//_/g')"
CACHE_TTL=2  # seconds

if [[ -f $CACHE_FILE ]] && [[ $(($(date +%s) - $(stat -c %Y $CACHE_FILE 2>/dev/null || stat -f %m $CACHE_FILE))) -lt $CACHE_TTL ]]; then
    cat $CACHE_FILE
    exit 0
fi

if git_status=$(cd $1 && git status 2>/dev/null ); then
	git_branch="$(echo $git_status| awk 'NR==1 {print $3}')"
	case $git_status in
		*Changes\ not\ staged* ) state="#[fg=neonred]*#[default]" ;;
		*Changes\ to\ be\ committed* ) state="#[fg=neonamber]+#[default]" ;;
		* ) state="#[fg=neonforest] / #[default]" ;;
	esac
	if [[ $git_branch = "master" || $git_branch = "main" ]]; then
		git_info="#[underscore]#[bg=deepaqua,fg=icecyan](${git_branch}#[default]|${state})"
	else
		git_info="#[underscore]#[bg=deepaqua,fg=iceyellow](${git_branch}#[default]|${state})"
	fi
else
	git_info=""
fi

directory="#[underscore]#[bg=black,fg=cyan]$1#[default]"
 echo "$directory$git_info" | tee $CACHE_FILE

#echo "$directory$git_info"
echo "$directory"
