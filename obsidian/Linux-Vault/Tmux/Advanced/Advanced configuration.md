---
topic: tmux
category: advanced
subjects: configuration, sourcing
url: https://github.com/tmux/tmux/wiki/Advanced-Use#advanced-configuration
---

#### Checking configuration files

[](https://github.com/tmux/tmux/wiki/Advanced-Use#checking-configuration-files)

The `source-file` command has two flags to help working with configuration files:

- `-n` parses the file but does not execute any of the commands.
    
- `-v` prints the parsed form of each command to `stdout`.
    

These can be useful to locate problems in a configuration file, for example by starting tmux without `.tmux.conf` and then loading it manually:

```
$ tmux -f/dev/null new -d
$ tmux source -v ~/.tmux.conf
/home/nicholas/.tmux.conf:1: set-option -g mouse on
/home/nicholas/.tmux.conf:8: unknown command: foobar
```