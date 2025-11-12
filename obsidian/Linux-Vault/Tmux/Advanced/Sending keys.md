---
topic: tmux
category: advanced
subject: keys, commands
url: https://github.com/tmux/tmux/wiki/Advanced-Use#sending-keys
---

The `send-keys` command can be used to send key presses to a pane as if they had been pressed. It takes multiple arguments. tmux checks if each argument is the name of a key and if so the appropriate escape sequence is sent for that key; if the argument does not match a key, it is sent as it is. For example:

![](https://github.com/tmux/tmux/wiki/images/tmux_send_keys.png)

```
send hello Enter
```

Sends the five characters in `hello`, followed by an Enter key press (a newline character). Or this:

```
send F1 C-F2
```

Sends the escape sequences for the `F1` and `C-F2` keys.

The `-l` flag tells tmux not to look for arguments as keys but instead send every one literally, so this will send the literal text `Enter`:

```
send -l Enter
```