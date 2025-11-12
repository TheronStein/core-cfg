#### The configuration file

[](https://github.com/tmux/tmux/wiki/Getting-Started#the-configuration-file)

When the tmux server is started, tmux runs a file called `.tmux.conf` in the user's home directory. This file contains a list of tmux commands which are executed in order. It is important to note that `.tmux.conf` is _only_ run when the server is started, not when a new session is created.

A different configuration file may be run from `.tmux.conf` or from a running tmux server using the `source-file` command, for example to run `.tmux.conf` again from a running server using the command prompt:

```
:source ~/.tmux.conf
```

Commands in a configuration file appear one per line. Any lines starting with `#` are comments and are ignored:

```
# This is a comment - the command below turns the status line off
set -g status off
```

Lines in the configuration file are processed similar to the shell, for example:

- Arguments may be enclosed in `'` or `"` to include spaces, or spaces may be escaped. These four lines do the same thing:
    
    ```
    set -g status-left "hello word"
    set -g status-left "hello\ word"
    set -g status-left 'hello word'
    set -g status-left hello\ word
    ```
    

- But escaping doesn't happen inside `'`s. The string here is `hello\ world` not `hello world`:
    
    ```
    set -g status-left 'hello\ word'
    ```
    
- `~` is expanded to the home directory (except inside `'`s):
    
    ```
    source ~/myfile
    ```
    

Environment variables can be set and are also expanded (but not inside `'`s):

```
MYFILE=myfile
source "~/$MYFILE"
```

- Any variables set in the configuration file will be passed on to new panes created inside tmux.
    
- A few special characters like `\n` (newline) and `\t` (tab) are replaced. A literal `\` must be given as `\\`.
    

Although tmux configuration files have some features similar to the shell, they are not shell scripts and cannot use shell constructs like `$()`.