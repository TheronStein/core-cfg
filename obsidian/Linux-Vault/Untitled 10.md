```
# DESIGN TWEAKS

# don't do anything when a 'bell' rings
set -g visual-activity off
set -g visual-bell off
set -g visual-silence off
setw -g monitor-activity off
set -g bell-action none

# clock mode
setw -g clock-mode-colour yellow

# copy mode
setw -g mode-style 'fg=black bg=red bold'

# panes
set -g pane-border-style 'fg=red'
set -g pane-active-border-style 'fg=yellow'

# statusbar
set -g status-position bottom
set -g status-justify left
set -g status-style 'fg=red'

set -g status-left ''
set -g status-left-length 10

set -g status-right-style 'fg=black bg=yellow'
set -g status-right '%Y-%m-%d %H:%M '
set -g status-right-length 50

setw -g window-status-current-style 'fg=black bg=red'
setw -g window-status-current-format ' #I #W #F '

setw -g window-status-style 'fg=red bg=black'
setw -g window-status-format ' #I #[fg=white]#W #[fg=yellow]#F '

setw -g window-status-bell-style 'fg=yellow bg=red bold'

# messages
set -g message-style 'fg=yellow bg=red bold'
```

status on
status-interval 15
status-justify left
status-keys vi
status-left "[#S] "
status-left-length 10
status-left-style default
status-position bottom
status-right " "#{=21:pane_title}" %H:%M %d-%b-%y"
status-right-length 40
status-right-style default
status-style fg=black,bg=green

The color and attributes of the status line may be configured, the entire status line using the **`status-style`** session option and individual windows using the **`window-status-style`** window option. The status line is automatically refreshed at interval if it has changed, the interval may be controlled with the **`status-interval`** session option.

> The _colors_ available to tmux are:

- `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`.
- bright colors, such as `brightred`, `brightgreen`, `brightyellow`, `brightblue`, `brightmagenta`, `brightcyan`.
- `colour0` through `colour255` from the [256-color set](https://jonasjacek.github.io/colors/).
- `default`
- hexadecimal RGB code like `#000000`, `#FFFFFF`, similar to HTML colors.

You can use **`[bg=color]`** and **`[fg=color]`** to adjust the text color and background within for status line text. This works on **`status-left`** and **`status-right`**. For example:

```
$ tmux set-option status-style fg=white,bg=black
```

> Shell Command Output

You can call the output of applications or shell command in tmux. For example, let’s assume you want to display the system uptime into the tmux status line. The shell command to accomplish this (in number of days) is:

```
$ uptime | cut -f 4-5 -d ' ' | cut -f 1 -d ','
```

To add the output of this command to right section of the tmux status line, we would run this command:

$ tmux set-option -ag status-right "#[fg=red,dim,bg=default]#(uptime | cut -f 4-5 -d ' ' | cut -f 1 -d ',') "

Or, add this line to ~/.tmux.conf:

set-option -ag status-right "#[fg=red,dim,bg=default]#(uptime | cut -f 4-5 -d ' ' | cut -f 1 -d ',') "

tmux allows you to call applications and output shell commands to your tmux status bar. In the next sections we will cover a couple of examples that demonstrate how you can style your tmux bar to fit your preferences and your workflow. The two examples we will use are: [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load) and [powerline](https://leanpub.com/the-tao-of-tmux/read#powerline).

Example: Integrating tmux-mem-cpu-load into tmux status line

# tmux-mem-cpu-load

[tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load) is a simple, lightweight program provided for system monitoring in the _status_ line of tmux. It monitors CPU, RAM, and system Load. An example output is:

Example output:

2885/7987MB [|||||     ]  51.2% 2.11 2.35 2.44

 ^    ^          ^         ^     ^    ^    ^
 |    |          |         |     |    |    |
 1    2          3         4     5    6    7

1. Currently used memory.
2. Available memory.
3. CPU usage bar graph.
4. CPU usage percentage.
5. Load average for the past minute.
6. Load average for the past 5 minutes.
7. Load average for the past 15 minutes.

Once [installed](https://github.com/thewtex/tmux-mem-cpu-load), you can add the following lines to your ~/.tmux.config:

set -g status-interval 2
set -g status-left "#S #[fg=green,bg=black]#(tmux-mem-cpu-load --colors --interval 2)#[default]"
set -g status-left-length 60

Putting the lines below in ~/.tmux.conf , will produce the tmux status line in the screenshot below.

set-option -g status on  
set-option -g status-interval 1  
set-option -g status-justify centre  
set-option -g status-keys vi  
set-option -g status-position bottom  
set-option -g status-style fg=colour136,bg=colour235  
set-option -g status-left-length 20  
set-option -g status-left-style default  
set-option -g status-left "#[fg=green]#H #[fg=black]• #[fg=green,bright]#(uname -r)#[default]"  
set-option -g status-right-length 140  
set-option -g status-right-style default  
set-option -g status-right "#[fg=green,bg=default,bright]#(tmux-mem-cpu-load) "  
set-option -ag status-right "#[fg=red,dim,bg=default]#(uptime | cut -f 4-5 -d ' ' | cut -f 1 -d ',') "  
set-option -ag status-right " #[fg=white,bg=default]%a%l:%M:%S %p#[default] #[fg=blue]%Y-%m-%d"  
set-window-option -g window-status-style fg=colour244  
set-window-option -g window-status-style bg=default  
set-window-option -g window-status-current-style fg=colour166  
set-window-option -g window-status-current-style bg=default

![](https://arcolinux.com/wp-content/uploads/2020/02/tmux-status-03.png)

Example: Integrating Powerline into tmux status line

[Powerline](https://github.com/powerline/powerline) is a statusline plugin for vim, and provides statuslines and prompts for several other applications, including zsh, bash, fish, tmux, IPython, Awesome, i3 and Qtile. Powerline has extensive documentation on integrating powerline into tmux. The easiest way to install powerline in Archlinux is to install the following packages using pacman.

![](https://arcolinux.com/wp-content/uploads/2020/02/tmux-powerline.png)

To enable the powerline plugin for tmux, simply add the following line to your ~/.tmux.conf and launch tmux. 

source "/usr/lib/python3.8/site-packages/powerline/bindings/tmux/powerline.conf"

_**Important**: the plugin path above may be different on your system, as python version changes. At the time of authoring this article, python 3.8 is the latest. You can always check the powerline package info to find the location of the tmux plugin._

If everything is configured correctly, the powerline status line will look like the screenshot below.

![](https://arcolinux.com/wp-content/uploads/2020/02/tmux-powerline-01.png)