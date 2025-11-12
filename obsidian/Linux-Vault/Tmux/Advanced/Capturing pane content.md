---
topic: tmux
category: advanced
subjects: panes
url: https://github.com/tmux/tmux/wiki/Advanced-Use#capturing-pane-content
---

Existing pane content can be captured with the `capture-pane` command. This can save its output to a paste buffer or, more usefully, write it to `stdout` by giving the `-p` flag.

By default, `capture-pane` captures the entire visible pane content:

```
$ tmux capturep -pt%0
```

The `-S` and `-E` flags give the starting and ending line numbers. Zero is the first visible line and negative lines go into the history. The special value `-` means the start of the history or the end of the visible content. So to capture the entire pane including the history:

```
$ tmux capturep -p -S- -E-
```

A few additional flags control the format of the output:

- `-e` includes escape sequences for colour and attributes;
    
- `-C` escapes nonprintable characters as octal sequences;
    
- `-N` preserves trailing spaces at the end of lines;
    
- `-J` both preserves trailing spaces and joins any wrapped lines.