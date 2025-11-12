---
topic: tmux
category: advanced
subject: sockets
url: https://github.com/tmux/tmux/wiki/Advanced-Use#socket-and-multiple-servers
---
tmux creates a directory for the user in `/tmp` and the server then creates a socket in that directory. The default socket is called `default`, for example:

```
$ ls -l /tmp/tmux-1000/default
srw-rw----  1 nicholas  wheel     0B Mar  9 09:05 /tmp/tmux-1000/default=
```

Sometimes it is convenient to create separate tmux servers, perhaps to ensure an important process is completely isolated or to test a tmux configuration. This can be done by using the `-L` flag which creates a socket in `/tmp` but with a name other than `default`. To start a server with the name `test`:

```
$ tmux -Ltest new
```

Alternatively, tmux can be told to use a different socket file outside `/tmp` with the `-S` flag:

```
$ tmux -S/my/socket/file new
```

The socket used by a running server can be seen with the `socket_path` format. This can be printed using the `display-message` command with the `-p` flag:

```
$ tmux display -p '#{socket_path}'
/tmp/tmux-1000/default
```

If the socket is accidentally deleted, it can be recreated by sending the `USR1` signal to the tmux server:

```
$ pkill -USR1 tmux
```