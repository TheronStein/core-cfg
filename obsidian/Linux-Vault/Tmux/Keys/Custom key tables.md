---
topic: tmux
category: advanced
subject: key tables, keys, config, customization
url: https://github.com/tmux/tmux/wiki/Advanced-Use#user-options)
---

[](https://github.com/tmux/tmux/wiki/Advanced-Use#custom-key-tables)

A custom key table is one with a name other than the four default (`root`, `prefix`, `copy-mode` and `copy-mode-vi`). Binding a key in a table creates that table, for example this creates a key table called `mytable` with `list-keys` bound to `x`:

```
bind -Tmytable x list-keys
```

Each client has a current key table, which may be set to no key table. The way key processing works when a key is pressed is:

1. If the key matches the `prefix` or `prefix2` options, the client is switched into the `prefix` key table and tmux then waits for another key press.
    
2. If it doesn't match, the key is looked up in the client's key table. If the client has no key table, it is first switched into the key table given by the `key-table` option (or the `copy-mode` or `copy-mode-vi` key table if in copy mode).
    
3. If a key binding is found in the table, its command is executed. If no key binding is found, tmux looks for an `Any` key binding and if one is found executes its command instead.
    
4. If the key does not repeat, the client is reset to no key table and waits for the next key press. If it does repeat, the client is left with the key table where the key was found so the next key press will also try that table first.
    

The `switch-client` command's `-T` flag can be used to explicitly set the client's key table, so when the next key is pressed, it is looked up in that key table. This can be used to bind chains of commands or to have multiple prefixes with different commands. For example, to make pressing `C-x` then `x` execute `list-keys`, first create a key table with an `x` binding, then a root binding for `C-x` to switch to that key table:

```
bind -Tmytable x list-keys
bind -Troot C-x switch-client -Tmytable
```

To entirely change the `root` key table for a single session, the `key-table` option can be changed:

```
set -tmysession: key-table mytable
```