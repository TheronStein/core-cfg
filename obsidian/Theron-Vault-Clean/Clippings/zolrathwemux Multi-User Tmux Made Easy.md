---
title: "zolrath/wemux: Multi-User Tmux Made Easy"
source: "https://github.com/zolrath/wemux"
author:
  - "[[zolrath]]"
published:
created: 2025-06-14
description: "Multi-User Tmux Made Easy. Contribute to zolrath/wemux development by creating an account on GitHub."
tags:
  - "clippings"
---
**[wemux](https://github.com/zolrath/wemux)** Public

Multi-User Tmux Made Easy

[MIT license](https://github.com/zolrath/wemux/blob/master/MIT-LICENSE)

[Open in github.dev](https://github.dev/) [Open in a new github.dev tab](https://github.dev/) [Open in codespace](https://github.com/codespaces/new/zolrath/wemux?resume=1)

<table><thead><tr><th colspan="2"><span>Name</span></th><th colspan="1"><span>Name</span></th><th><p><span>Last commit message</span></p></th><th colspan="1"><p><span>Last commit date</span></p></th></tr></thead><tbody><tr><td colspan="3"><p><span><a href="https://github.com/zolrath/wemux/commit/01c6541f8deceff372711241db2a13f21c4b210c">Merge pull request</a> <a href="https://github.com/zolrath/wemux/pull/47">#47</a> <a href="https://github.com/zolrath/wemux/commit/01c6541f8deceff372711241db2a13f21c4b210c">from nilbus/exit-status</a></span></p><p><span><a href="https://github.com/zolrath/wemux/commit/01c6541f8deceff372711241db2a13f21c4b210c">01c6541</a> ·</span></p><p><a href="https://github.com/zolrath/wemux/commits/master/"><span><span><span>142 Commits</span></span></span></a></p></td></tr><tr><td colspan="2"><p><a href="https://github.com/zolrath/wemux/tree/master/man">man</a></p></td><td colspan="1"><p><a href="https://github.com/zolrath/wemux/tree/master/man">man</a></p></td><td><p><a href="https://github.com/zolrath/wemux/commit/414b4c250899b35f97e0caa67d0f786123db8e5f">Document 'join' with no argument</a></p></td><td></td></tr><tr><td colspan="2"><p><a href="https://github.com/zolrath/wemux/blob/master/MIT-LICENSE">MIT-LICENSE</a></p></td><td colspan="1"><p><a href="https://github.com/zolrath/wemux/blob/master/MIT-LICENSE">MIT-LICENSE</a></p></td><td><p><a href="https://github.com/zolrath/wemux/commit/403fb7362a2165f3497a681dedf2da7d5ac1a546">Add MIT License</a></p></td><td></td></tr><tr><td colspan="2"><p><a href="https://github.com/zolrath/wemux/blob/master/README.md">README.md</a></p></td><td colspan="1"><p><a href="https://github.com/zolrath/wemux/blob/master/README.md">README.md</a></p></td><td><p><a href="https://github.com/zolrath/wemux/commit/ac7e82f7acbdbb5cbb708f878f6d5e00f7a0fad9">Merge pull request</a> <a href="https://github.com/zolrath/wemux/pull/48">#48</a> <a href="https://github.com/zolrath/wemux/commit/ac7e82f7acbdbb5cbb708f878f6d5e00f7a0fad9">from dzogrim/patch-1</a></p></td><td></td></tr><tr><td colspan="2"><p><a href="https://github.com/zolrath/wemux/blob/master/wemux">wemux</a></p></td><td colspan="1"><p><a href="https://github.com/zolrath/wemux/blob/master/wemux">wemux</a></p></td><td><p><a href="https://github.com/zolrath/wemux/commit/01c6541f8deceff372711241db2a13f21c4b210c">Merge pull request</a> <a href="https://github.com/zolrath/wemux/pull/47">#47</a> <a href="https://github.com/zolrath/wemux/commit/01c6541f8deceff372711241db2a13f21c4b210c">from nilbus/exit-status</a></p></td><td></td></tr><tr><td colspan="2"><p><a href="https://github.com/zolrath/wemux/blob/master/wemux.conf.example">wemux.conf.example</a></p></td><td colspan="1"><p><a href="https://github.com/zolrath/wemux/blob/master/wemux.conf.example">wemux.conf.example</a></p></td><td><p><a href="https://github.com/zolrath/wemux/commit/c3e4b164f1ede05f54ce47f1257f828f91492ec5">Added ability to specify groups of users who are hosts</a></p></td><td></td></tr><tr><td colspan="3"></td></tr></tbody></table>

[![wemux: Multi-User Tmux Sessions Made Easy](https://camo.githubusercontent.com/531a26652835bd734d7ff414c64e1485e2147c097532e169ed186798ab6dbd68/687474703a2f2f692e696d6775722e636f6d2f694f6a637a2e706e67)](https://camo.githubusercontent.com/531a26652835bd734d7ff414c64e1485e2147c097532e169ed186798ab6dbd68/687474703a2f2f692e696d6775722e636f6d2f694f6a637a2e706e67)

---

wemux enhances tmux to make multi-user terminal multiplexing both easier and more powerful. It allows users to host a wemux server and have clients join in either:

**Mirror Mode** gives clients (another SSH user on your machine) read-only access to the session, allowing them to see you work, or

**Pair Mode** allows the client and yourself to work in the same terminal (shared cursor)

**Rogue Mode** allows the client to pair or work independently in another window (separate cursors) in the same tmux session.

It features multi-server support as well as user listing and notifications when users attach/detach.

**IMPORTANT**: Wemux requires tmux version >= 1.6

If you have [MacPorts](https://www.macports.org/) installed you can install wemux with a very simple:

```
sudo port install wemux
```

If you have [Homebrew](http://mxcl.github.com/homebrew/) installed you can install wemux with a fairly simple:

```
brew install wemux
```

The user that installed wemux will automatically be added to the wemux host list. To change the host or add more hosts, edit `/usr/local/etc/wemux.conf` and add the username to the host\_list array.

Users in the host\_list will be able to start new wemux servers, all other users will be wemux clients and join these servers.

```
$ vim /usr/local/etc/wemux.conf
     OR
$ wemux conf

host_list=(zolrath brocksamson)
```

### Manual Installation

The rest of this readme will operate under the assumption you'll place wemux in `wemux/` in your `/usr/local/share` directory. To make wemux available for all users, perform the following steps, using sudo as required:

Git clone this repo.

```
git clone git://github.com/zolrath/wemux.git /usr/local/share/wemux
```

Symlink the `wemux` file into your $PATH via `/usr/local/bin/`, being sure to use the full path.

```
ln -s /usr/local/share/wemux/wemux /usr/local/bin/wemux
```

**IMPORTANT**: Copy the `wemux.conf.example` file to `/usr/local/etc/wemux.conf`

```
cp /usr/local/share/wemux/wemux.conf.example /usr/local/etc/wemux.conf
```

Then set a user to be a wemux host by adding their username to the host\_list in `/usr/local/etc/wemux.conf`. Users in the host\_list will be able to start new wemux servers, all other users will be wemux clients and join these servers.

```
vim /usr/local/etc/wemux.conf
host_list=(zolrath brocksamson)
```

To upgrade to a new version of wemux return to the `/usr/local/share/wemux` directory and perform a `git pull`

## Host Commands

#### wemux start

Use `wemux start` to start a wemux server, chmod /tmp/wemux-wemux to 1777 so that other users may connect to it, and attach to it. If a wemux server already exists, it will attach to it instead.

#### wemux attach

Use `wemux attach` to attach to an existing wemux server.

#### wemux stop

Use `wemux stop` to kill the wemux server and remove the /tmp/wemux-wemux socket.

Use `wemux kick <username>` to kick an SSH user from the server and remove their wemux rogue sessions.

#### wemux config

Use `wemux config` to open `/usr/local/etc/wemux.conf` in your $EDITOR. Note this only works if you have the environment variable EDITOR configured.

#### wemux

When `wemux` is run without any arguments in host mode, it is just like running wemux start. It will reattach to an existing wemux server if it exists, otherwise it will start a new server.

## Client Commands

#### wemux mirror

Use `wemux mirror` to attach to server in read-only mode.

#### wemux pair

Use `wemux pair` to attach to server in pair mode, allowing the client to control the terminal as well.

#### wemux rogue

Use `wemux rogue` to attach to server in rogue mode, which allows both editing with the host and switching to windows independently from the host.

#### wemux logout

Use `wemux logout` to remove your rogue mode session.

#### wemux

When `wemux` is run without any arguments in client mode, its behavior attempts to intelligently select mirror, pair, or rogue:

- If the client does not have an existing rogue session it will attach to the wemux server in pair mode.
- If the client has already started a wemux rogue session, it will reattach to the server in rogue mode.
- If both rogue and pair mode are disabled, it will attach in mirror mode.
- By setting `default_client_mode="rogue"` in `wemux.conf` this can be changed to always join in rogue mode, even if a rogue session doesn't already exist.

#### Other Commands

wemux passes commands it doesn't understand through to tmux with the correct socket setting.

`wemux list-sessions` is equivalent to entering `tmux -S /tmp/wemux-wemux list-sessions`

## User List

wemux can display a list of connected users, indicating users in mirror mode with \[m\] at the end of their name.

If you'd like to see a list of all users currently connected to the wemux server, you have three options:

### wemux users

Enter `wemux users` in the terminal to display a list of all currently connected wemux users.

```
$ wemux users
Users connected to 'wemux':
  1. zolrath
  2. csagan[m]
```

### Status Bar

You can add the user list to your status bar by adding #(wemux status\_users) where you see fit by editing your `~/tmux.conf` file.

```
set -g status-right "#(wemux status_users)"
```

### Display Message

If you'd rather display users on command via a tmux message, similar to the user attachment/detachment messages, you can do so by editing your `~/tmux.conf` file. Pick whatever key you'd like to bind the displaying the message to. Using t as an example:

```
unbind t
bind t run-shell 'wemux display_users'
```

Note that the tmux prefix should be pressed before t to activate the command.

User listing can be disabled by setting `allow_user_list="false"` in `wemux.conf`

### Short-form Commands

All commands have a short form. s for start, a for attach, p for pair etc. For a complete list, type `wemux help` (or `wemux h`)

## Multi-Host Capabilities

---

wemux supports specifying the joining different wemux servers via `wemux join <server>`. This allows multiple hosts on the same machine to host their own independent wemux servers with their own clients. By default this option is disabled.

wemux will remember the last server specified to in order to make reconnecting to the same server easy. `wemux help` will output the currently specified server along with the wemux command list.

Changing servers can be enabled by setting `allow_server_change="true"` in `/usr/local/etc/wemux.conf`

To change the wemux server run `wemux join <server>`. The name will be sanitized to contain no spaces or uppercase letters.

```
$ wemux join Project X
Changed wemux server from 'wemux' to 'project-x'
$ wemux
$ wemux stop
$ wemux reset
Changed wemux server from 'project-x' to 'wemux'
```

Join wemux server with specified name.

```
$ wemux join rails
Changed wemux server from 'wemux' to 'rails'
```

Alternatively, enter the server number displayed next to the server name in `wemux list`.

```
$ wemux j 1
Changed wemux server from 'rails' to 'project-x'
```

#### wemux join

Join with no argument simply displays the current wemux server, if you're into that.

```
$ wemux join
Current wemux server: wemux
```

In order to easily return to the default server you can run `wemux reset`

#### wemux reset

Joins the default wemux server: wemux (or value of default\_server\_name in wemux.conf)

```
$ wemux reset
Changed wemux server from 'project-x' to 'wemux'
```

To list the name of all currently running wemux servers run `wemux list`

#### wemux list

List all currently active wemux servers.

```
$ wemux list
Currently active wemux servers:
  1. project-x
  2. rails
  3. wemux    <- current server
```

`wemux join` and `wemux stop` both accept either the name of a server or the number indicated next to the name in `wemux list`.

Listing servers can be disabled by setting `allow_server_list="false"` in `/usr/local/etc/wemux.conf`

## Configuration

---

There are a number of additional options that be configured in `/usr/local/etc/wemux.conf`. In most cases the only option that must be changed is the `host_list` array. To open your wemux configuration file, you can either open `/usr/local/etc/wemux.conf` manually or run `wemux config`

### Host Mode

To have an account act as host, ensure that you have added their username to the `/usr/local/etc/wemux.conf` file's `host_list` array.

```
host_list=(zolrath hostusername brocksamson)
```

### Pair Mode

Pair mode can be disabled, only allowing clients to attach to the server in mirror mode by setting `allow_pair_mode="false"`

### Rogue Mode

Rogue mode can be disabled, only allowing clients to attach to the server in mirror or pair mode by setting `allow_rogue_mode="false"`

When clients enter 'wemux' with no arguments by default it will first attempt to join an existing rogue mode session. If there is no rogue session it will start in pair mode. By setting default\_client\_mode to "rogue", 'wemux' with no arguments will always join a rogue mode session, even if it has to create it.

This can be changed by setting `default_client_mode="rogue"`

The default wemux server name will be used with `wemux reset` and when `allow_server_name` is not enabled in `wemux.conf`.

This can be changed by setting `default_server_name="customname"`

### Changing Servers

The ability to change servers can be enabled by setting `allow_server_change="true"`

### Listing Servers

Listing servers can be disabled by setting `allow_server_list="false"`

### Listing Users

Listing users can be disabled by setting `allow_user_list="false"` in `wemux.conf`

Kicking SSH users from the server can be disabled by setting `allow_kick_user="false"` in `wemux.conf`

### Announcements

When a user joins a server in either mirror, pair, or rogue mode, a message is displayed to all currently attached users:

```
csagan has attached in mirror mode.
csagan has detached.
```

This can be disabled by setting `announce_attach="false"`

In addition, when a user switches from one server to another via the `wemux join <servername>` command, their movement is displayed similarly to the attach messages.

If csagan enters `wemux join applepie` the users on the default server `wemux` will see:

```
csagan has switched to server: applepie
```

If csagan returns to default server with: `wemux reset` users on `wemux` will see:

```
csagan has joined this server.
```

This can be disabled by setting `announce_server_change="false"`

To make an SSHed user start in a wemux mode automatically, add one of the following lines to the users `.bash_profile` or `.zshrc`

**Option 1**: Automatically log the client into mirror mode upon login, disconnect them from the server when they detach.

```
wemux mirror; exit
```

**Option 2**: Automatically start the client in mirror mode but allow them to detach.

```
wemux mirror
```

**Option 3**: Automatically start the client in pair mode but allow them to detach.

```
wemux pair
```

**Option 4**: Automatically start the client in rogue mode but allow them to detach.

```
wemux rogue
```

**Option 5**: Only display the connection commands, don't automatically start any modes.

```
wemux help
```

Please note that this does not ensure a logged in user will not be able to exit tmux and access their shell. If the user is not trusted, you must perform any security measures one would normally perform for a remote user.

## Releases 1

## Languages

- [Shell 100.0%](https://github.com/zolrath/wemux/search?l=shell)