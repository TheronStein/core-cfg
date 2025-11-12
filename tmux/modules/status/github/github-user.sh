tmux_gh_icon=" "                                                                                                                   # nf-fa-github
uname="$(gh auth status | grep -B1 "Active account: true" | head -n 1 | awk '{for(i=1;i<=NF;i++) if($i=="account") print $(i+1)}')" # TODO: use json options when gh supports. Extract host info.
status_bg="#3094FF"

if [ -z "$uname" ]; then
  uname="Not logged in"
  status_bg="#FE4C25"
fi

echo -n "#[bold,fg="#313244",bg=${status_bg}] #[bold,fg="#cdd6f4",bg=${status_bg}]$tmux_gh_icon #[bold,fg="${status_bg}",bg="#292D3E"] #[bold,fg="#01F9C6",bg="#292D3E"]$uname "
