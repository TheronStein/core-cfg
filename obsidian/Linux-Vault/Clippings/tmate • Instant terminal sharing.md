---
title: "tmate • Instant terminal sharing"
source: "https://tmate.io/"
author:
published:
created: 2025-06-14
description:
tags:
  - "clippings"
---
[![Fork me on GitHub](https://tmate.io/img/fork-me-on-github-right-orange@2x.png)](https://github.com/tmate-io/tmate) ![](https://tmate.io/img/logo.png)

## tmate

## Instant terminal sharing

---

## Installation

tmate is a fork of [tmux](https://tmux.github.io/). tmate and tmux can coexist on the same system.

```
brew install tmate
```

Note: [Homebrew](https://brew.sh/) is required as a prerequisite.

```
sudo apt-get install tmate
```

```
sudo dnf install tmate
```

The Fedora packages are maintained by [Andreas Schneider](https://admin.fedoraproject.org/pkgdb/packager/asn/).

```
sudo zypper install tmate
```

[Package](https://software.opensuse.org/package/tmate) available on openSUSE Tumbleweed and Leap. On SUSE Linux Enterprise, you need to [activate the Package Hub](https://packagehub.suse.com/#use) Extension first.

```
pkg install tmate
```

The FreeBSD packages are maintained by [Steve Wills](https://github.com/swills).

```
pkg_add tmate
```

The OpenBSD packages are maintained by [Wesley Mouedine Assaby](https://github.com/wesley974).

```
emerge -a app-misc/tmate
```

Package information: [https://packages.gentoo.org/packages/app-misc/tmate](https://packages.gentoo.org/packages/app-misc/tmate).

```
pacman -S tmate
```

The ArchLinux package is maintained by [Christian Hesse](https://github.com/eworm-de).

```
opkg install tmate
```

The OpenWrt package is maintained by [Tianling Shen](https://github.com/1715173329).

We provide i386, x86\_64, arm32v6, arm32v7, and arm64v8 linux static builds for convenience.

Binaries can be found on the [GitHub release page](https://github.com/tmate-io/tmate/releases/latest). The binaries are built using the `build_static_release.sh` script in the tmate source directory.

Sources are on GitHub: [https://github.com/tmate-io/tmate](https://github.com/nviennot/tmate)

Download, compile, and install with the following steps:

```
git clone https://github.com/tmate-io/tmate.git
cd tmate
./autogen.sh
./configure
make
make install
```

A few dependencies are required. The Ubuntu package names are:  
git-core build-essential pkg-config libtool libevent-dev libncurses-dev zlib1g-dev automake libssh-dev libmsgpack-dev

---

## Usage

- Once installed, launch tmate with `tmate`. You should see something like `ssh PMhmes4XeKQyBR2JtvnQt6BJw@nyc1.tmate.io` appearing. This allows others to join your terminal session. All users see the same terminal content at all time. This is useful for pair programming where two people share the same screen, but have different keyboards.
- tmate is useful as it goes through NATs and tolerate host IP changes. Accessing a terminal session is transparent to clients as they go through the tmate.io servers, acting as a proxy. No authentication setup is required, like setting up ssh keys.
- Run `tmate show-messages` in your shell to see tmate's log messages, including the ssh connection string.
- tmate also allow you to share a read-only view of your terminal. The read-only connection string can be retrieved with `tmate show-messages`.
- tmate uses `~/.tmate.conf` as configuration file. It uses the same tmux syntax. In order to load the `~/.tmux.conf` configuration file, add `source-file ~/.tmux.conf` in the tmate configuration file.

---

## Remote access

When tmate is used for remote access only (as opposed to pair programming), it is useful to launch tmate in foreground mode with `tmate -F`. This does two things:

- It only starts the server side of tmate and outputs its log on stdout (as opposed to showing the session shell, useful for pair programming). This makes it easy to integrate into a service manager like systemd or kubernetes.
- It ensure the session never dies, by respawning a shell when it exits.

If you wish to specify the program to run as a shell, run `tmate -F new-session [command...]`. For example, to have a rails console (it's a popular web framework) accessible with a named session (see next section), one can run:

```
tmate -F -n web new-session rails console
```

You can think of tmate as a reverse ssh tunnel accessible from anywhere.

---

## Named sessions

Typically, tmate generates random connection strings which are not stable across restarts, like `ssh vbBK63dtemNN2ppDUqSvYNqbD@nyc1.tmate.io`. This can be a problem for accessing remote machines. One way to deal with connection string instability is to use [tmate Webhooks](https://github.com/tmate-io/tmate/wiki/Webhooks), but this requires some effort to integrate.

Another way is to use named sessions: by specifying a session name, the connection string becomes `ssh username/session-name@nyc1.tmate.io` which is deterministic. The username is specified when registering for an API key (see below) and the session name is specified as follows:

- From the CLI:
	```
	tmate -k API_KEY -n session-name
	```
- Or from the `~/.tmate.conf` file:
	```
	set tmate-api-key "API_KEY"
	set tmate-session-name "session-name"
	```

It is possible put the API key in the tmate configuration file, and specify the session name on the CLI.

To specify the read-only session name, you may use the CLI option `-r`, or the configuration option `tmate-session-name-ro`.

If you get the error `illegal option -- n`, ensure you are running tmate greater than **2.4.0**. You can check what tmate version you have by running: `tmate -V`. If your tmate version is too old, scroll up to the installation section.

**Warning: access control must be considered when using named sessions, see next section.**

Fill the following form to get an API key and start naming your sessions

---

## Access control

When using named sessions, access control is a concern as session names can be easy to guess if one is not careful. There are two ways to do access control:

- Use hard to guess session names. For example *machine1-3V6txGYUgglA*. This makes the session name hard to guess, like a password.
- Only allow SSH clients with specific public keys to connect to the session. To do so, create an `authorized_keys` file containing public keys that are allowed to connect. In this example, we'll reuse the one sshd uses, namely `~/.ssh/authorized_keys`. Then, specify the authorized keys file via the tmate CLI using `-a` as such:
	```
	tmate -a ~/.ssh/authorized_keys
	```
	The authorized keys file can also be specified in the `~/.tmate.conf` configuration file with:
	```
	set tmate-authorized-keys "~/.ssh/authorized_keys"
	```
Note that specifying an authorized keys file will disable web access.

---

## Host your own tmate servers

You can use the following docker image [tmate/tmate-ssh-server](https://hub.docker.com/r/tmate/tmate-ssh-server). Note that you will need to create SSH keys using `create_keys.sh` (see below).

Alternatively, you can compile the ssh server from source located at [https://github.com/tmate-io/tmate-ssh-server](https://github.com/tmate-io/tmate-ssh-server).

tmate also depends on a couple of packages. On Ubuntu, the packages are:  
git-core build-essential pkg-config libtool libevent-dev libncurses-dev zlib1g-dev automake libssh-dev cmake ruby

Once all the prerequisites are satisfied, you can install tmate-ssh-server with:

```
git clone https://github.com/tmate-io/tmate-ssh-server.git && cd tmate-ssh-server
./create_keys.sh # This generates SSH keys
./autogen.sh && ./configure && make
sudo ./tmate-ssh-server
```

Once your server is running, you must configure the clients to use your custom server.  
You may specify your custom options in the `~/.tmate.conf` file. Here are the default options:

```
set -g tmate-server-host "ssh.tmate.io"
set -g tmate-server-port 22
set -g tmate-server-rsa-fingerprint     "SHA256:Hthk2T/M/Ivqfk1YYUn5ijC2Att3+UPzD7Rn72P5VWs"
set -g tmate-server-ed25519-fingerprint "SHA256:jfttvoypkHiQYUqUCwKeqd9d1fJj/ZiQlFOHVl6E9sI"
```

If you are interested in fault tolerance, you should setup the `tmate-server-host` host to resolve to multiple IPs.  
The tmate client will try them all, and keep to the most responsive one.  
`ssh.tmate.io` resolves to servers located in San Francisco, New York, London, and Singapore.

To support named sessions, at this moment you must self-host the websocket server as well. This is because the session unix sockets must be renamed, but the jail make it difficult. You may follow the kubernetes configuration used for tmate.io at [github.com/tmate-io/tmate-kube/prod](https://github.com/tmate-io/tmate-kube/tree/master/prod).

---

## Development environment

To faciliate developing, we run all the various tmate services with [tilt](https://tilt.build/). It's a tool like docker compose, but with features like live update. When a source file changes, it is immediately copied into the corresponding container and recompiled on the fly. This feature is very useful for developing.

Here at the steps to setup the tmate dev environment:

```
# macOS specific. On linux you can use microk8 instead of minikube
brew install minikube tilt
minikube start

# Install sources
git clone https://github.com/tmate-io/tmate-ssh-server.git
git clone https://github.com/tmate-io/tmate-websocket.git
git clone https://github.com/tmate-io/tmate-master.git
git clone https://github.com/tmate-io/tmate-kube.git

# Compile and run the tmate servers in a local kubernetes environment
cd tmate-kube/dev
eval $(minikube docker-env)
tilt up

# Create the postgres database and do database migrations
kubectl exec -it deploy/master mix do ecto.create, ecto.migrate

# Finally, configure tmate to use the local dev environment 
cat >> ~/.tmate.conf <<-EOF
set tmate-server-host localhost
set tmate-server-port 2200
set -g tmate-server-rsa-fingerprint     "SHA256:pj6jMtCIgg26eJtHUro6KEmVOkVGmLdclArInW9LyLg"
set -g tmate-server-ed25519-fingerprint "SHA256:ltQuqZqoF1GHYrrAVd99jW8W7vj/1gwoBwBF/FC9iuU"
EOF
```

At this point you should be able to navigate to [http://localhost:4000](http://localhost:4000/) and see the tmate homepage. You should also be able to run `tmate` and a local connection string should appear.

---

## Technical Details

**Warning: this information is outdated.** A more up to date technical draft can be found [here \[PDF\]](https://viennot.com/tmate.pdf), but is still outdated. Sorry:(

#### Connection process

When launching tmate, an ssh connection is established to tmate.io (or your own server) in the background through [libssh](https://www.libssh.org/). The server ssh key signatures are specified upfront and are verified during the DH exchange to prevent [man in the middle attacks](https://en.wikipedia.org/wiki/Man-in-the-middle_attack).

When a connection is established, a 150 bits session token is generated, then a tmux server is spawned in a jail with no file system, with its own [PID namespace](https://lwn.net/Articles/531114/#series_index) to isolate the server from other processes, and no user privileges. To allow this, all files required during the tmux server execution are opened before getting jailed. These measures are in place to limit the usefulness of possible exploits targeting the tmux server. The attacker would not be able to access other sessions, ensuring confidentiality.

When an ssh client connects to tmate.io (or your own server), the tmux unix socket is looked up on the file system. On lookup failures, a random sleep is performed to prevent [timing attacks](https://en.wikipedia.org/wiki/Timing_attack), otherwise a tmux client is spawned and connected to the remote tmux server.

#### Protocol

The local and remote tmux servers communicate with a protocol on top of [msgpack](https://msgpack.org/), which is gzipped over ssh for network bandwidth efficiency as vim scrolling can generate massive amounts of data.

In order to keep the remote tmux server in sync with the local tmux server, PTY window pane's raw outputs are streamed individually as opposed to synchronizing the entire tmux window. Furthermore, window layouts, status bar changes, and copy mode state are also replicated. Finally, most of the tmux commands (like bind-key) are replicated. This ensures that the key bindings are the same on both side.

The remote client's keystrokes are parsed and the outcome is sent to the local tmux server. This includes tmux commands such as split-window, window pane keystrokes, or window size information.

#### Future work

This project can take many interesting directions.  
Here is what I have on the roadmap:

- Improve the headless experience. This is useful for managing a fleet of devices.
- Make the user experience top notch. Please [submit bug reports](https://github.com/tmate-io/tmate/issues) when you see issues.
- Tolerate network failures. Dealing with reconnections and roaming (IP changes) similarly to what [Mosh](https://mosh.mit.edu/) offers.
- ~~Support for read-only clients. This would be easy to do by providing another session token, distinct from the read-write access one.~~
- ~~Getting low latencies for everyone requires having nodes spread out all over the globe.~~

---

## Get in touch

If you'd like to get in touch, here are your options:

- Submit bug reports on GitHub: [https://github.com/tmate-io/tmate/issues](https://github.com/tmate-io/tmate/issues).
- Post a message on Google Groups: [https://groups.google.com/group/tmate-io](https://groups.google.com/group/tmate-io).
- Or send an email to [tmate-io@googlegroups.com](https://tmate.io/).
- You can also send me a personal email at [nico@tmate.io](https://tmate.io/).

Enjoy,  
Nico