local tmux_gh_icon=" " # nf-fa-github

local uname="$(gh auth status | grep -B1 "Active account: true" | head -n 1 | awk '{for(i=1;i<=NF;i++) if($i=="account") print $(i+1)}')" # TODO: use json options when gh supports. Extract host info.

if [ -z "$uname" ]; then
  uname="Not logged in"
fi

echo -n "$tmux_gh_icon $uname"
