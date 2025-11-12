tmux key bindings are changed using the `bind-key` and `unbind-key` commands. Each key binding in tmux belongs to a named key table. There are four default key tables:

- The `root` table contains key bindings for keys pressed without the prefix key.
    
- The `prefix` table contains key bindings for keys pressed after the prefix key, like those mentioned so far in this document.
    
- The `copy-mode` table contains key bindings for keys used in copy mode with _emacs(1)_-style keys.
    
- The `copy-mode-vi` table contains key bindings for keys used in copy mode with _vi(1)_-style keys.
    

All the key bindings or those for a single table can be listed with the `list-keys` command. By default, this shows the keys as a series of `bind-key` commands. The `-T` flag gives the key table to show and the `-N` flag shows the key help, like the `C-b ?` key binding.

For example to list only keys in the `prefix` table:

```
$ tmux lsk -Tprefix
bind-key    -T prefix C-b     send-prefix
bind-key    -T prefix C-o     rotate-window
...
```

Or:

```
$ tmux lsk -Tprefix -N
C-b     Send the prefix key
C-o     Rotate through the panes
...
```

`bind-key` commands can be used to set a key binding, either interactively or most commonly from the configuration file. Like `list-keys`, `bind-key` has a `-T` flag for the key table to use. If `-T` is not given, the key is put in the `prefix` table; the `-n` flag is a shorthand for `-Troot` to use the `root` table.

For example, the `list-keys` command shows that `C-b 9` changes to window 9 using the `select-window` command:

```
$ tmux lsk -Tprefix 9
bind-key -T prefix 9 select-window -t :=9
```

A similar key binding to make `C-b M-0` change to window 10 can be added like this:

```
bind M-0 selectw -t:=10
```

The `-t` flag to `select-window` specifies the target window. In this example, the `:` means the target is a window and `=` means the name must match `10` exactly. Targets are documented further in the [COMMANDS section of the manual page](https://man.openbsd.org/tmux#COMMANDS).

The `unbind-key` command removes a key binding. Like `bind-key` it has `-T` and `-n` flags for the key table. It is not necessary to remove a key binding before binding it again, `bind-key` will replace any existing key binding. `unbind-key` is necessary only to completely remove a key binding:

```
unbind M-0
```