[DDS | Yazi](https://yazi-rs.github.io/docs/next/dds)

Version: nightly

On this page

# DDS

DDS (Data Distribution Service) is designed to achieve communication and state synchronization between multiple Yazi instances, as well as state persistence. It is built on a client-server architecture but does not require running additional server processes.

It deeply integrates with a publish-subscribe model based on the Lua API.

## Concept

- Local: the current instance, that is, the current Yazi process.
- Remote: instances other than the current instance.
- Static message: A message with a kind that starts with `@` will be persistently stored and automatically restored when a new instance starts. To un-persist, send `nil` to that kind.

## Usage

The DDS has three usage:

- [Plugin API](https://yazi-rs.github.io/docs/plugins/utils#ps): Using Lua-based publish-subscribe model as the message carrier.
- [`ya pub` and `ya pub-to`](https://yazi-rs.github.io/docs/next/dds#ya-pub): Using [`ya` CLI tool](https://yazi-rs.github.io/docs/cli) as the message carrier.
- [`ya emit` and `ya emit-to`](https://yazi-rs.github.io/docs/next/dds#ya-emit): Using [`ya` CLI tool](https://yazi-rs.github.io/docs/cli) as the command carrier.
- [Real-time `stdout` reporting](https://yazi-rs.github.io/docs/next/dds#stdout-reporting): Using `stdout` as the carrier.

### `ya pub` and `ya pub-to`

If you're in a Yazi subshell where the `$YAZI_ID` environment variable is set, you can send a message to the current instance using `ya pub`. It requires a `kind` argument, which is consistent with [`ps.pub()`](https://yazi-rs.github.io/docs/plugins/utils#ps.pub):

```
ya pub <kind> --str "string body"ya pub <kind> --list "a" "b" "c"ya pub <kind> --json '{"key":"json body"}'# For example, request the current instance to extract `a.zip` and `b.7z`ya pub extract --list "/root/a.zip" "/root/b.7z"
```

You can also send a message to a specified remote instance(s) using `ya pub-to`, with the required `receiver` and `kind` arguments, consistent with [`ps.pub_to()`](https://yazi-rs.github.io/docs/plugins/utils#ps.pub_to):

```
ya pub-to <receiver> <kind> --str "string body"ya pub-to <receiver> <kind> --list "a" "b" "c"ya pub-to <receiver> <kind> --json '{"key":"json body"}'# If you're in a Yazi subshell,# you can obtain the ID of the current instance through `$YAZI_ID`.ya pub-to "$YAZI_ID" my-event --str "Hello world!"# If you are not in a Yazi subshell, i.e., communicating with Yazi externally,# you can start with `yazi --client-id <globally-unique-id>`, and pass that ID to `ya pub-to`.MY_UNIQUE_ID="$(date +%s)$RANDOM"yazi --client-id "$MY_UNIQUE_ID"ya pub-to "$MY_UNIQUE_ID" my-event --str "Hello world!"
```

For greater convenience in integrating within the command-line environment, they support two body formats:

- String: a straightforward format, suitable for most scenarios, without the need for additional tools for encoding
- List: An array of strings, it is useful for carrying a file list to the message
- JSON: for advanced needs, support for types and more complex data can be represented through the JSON format

### `ya emit` and `ya emit-to`

If you're in a Yazi subshell where the `$YAZI_ID` environment variable is set, you can use `ya emit` to send a command to the current instance for execution.

The command format is the same as what you'd write in the [`keymap.toml`](https://yazi-rs.github.io/docs/configuration/keymap):

```
ya emit <command> <args>
```

For example:

```
ya emit cd /tmpya emit reveal /tmp/foo
```

You can also send commands to a specific remote instance using `ya emit-to`:

```
ya emit-to <receiver> <command> <args>
```

For example:

```
ya emit-to "$YAZI_ID" cd /tmp
```

Real-time `stdout` reporting

You can specify the `--local-events` and `--remote-events` options when starting Yazi:

```
# Local eventsyazi --local-events=kind1,kind2# Remote eventsyazi --remote-events=kind1,kind2# Both local and remote eventsyazi --local-events=kind1,kind2 --remote-events=kind1,kind2
```

When an event of the specified kind is received, it will be output to `stdout`:

```
hover,0,200,{"tab":0,"url":"/root/Downloads"}cd,0,100,{"tab":0,"url":"/root/Downloads"}
```

One payload per line, each payload contains the following fields separated by commas:

| Field    | Description                                                                                       |
| -------- | ------------------------------------------------------------------------------------------------- |
| kind     | The kind of the message                                                                           |
| receiver | The remote instance ID that receives the message; if it's `0`, broadcasts to all remote instances |
| sender   | The sender of the message                                                                         |
| body     | The body of the message, which is a JSON string                                                   |

This provides the ability to report Yazi's internal events in real-time, which is useful for external tool integration (such as Neovim), as they will be able to subscribe to the events triggered by the user behavior.

## Builtin kinds

`cd` \- change directory

`sub()` callback body:

```
{	tab = 0}
```

`sub_remote()` callback body:

```
{	tab = 0,	url = Url("/root/Downloads")}
```

`--local-events` stdout payload:

```
cd,1711957542289249,1711957542289249,{"tab":0,"url":"/root/Downloads"}
```

`--remote-events` stdout payload:

```
cd,0,100,{"tab":0,"url":"/root/Downloads"}
```

`hover` \- hover on a file

`sub()` callback body:

```
{	tab = 0}
```

`sub_remote()` callback body:

```
{	tab = 0,	url = Url("/root/foo.txt")}
```

`--local-events` stdout payload:

```
hover,1711957283332834,1711957283332834,{"tab":0,"url":"/root/foo.txt"}
```

`--remote-events` stdout payload:

```
hover,0,200,{"tab":0,"url":"/root/foo.txt"}
```

`rename` \- rename a file

`sub()` / `sub_remote()` callback body:

```
{  tab = 0,  from = Url("/root/foo.txt"),  to = Url("/root/bar.txt"),}
```

`--local-events` stdout payload:

```
rename,1711957878076791,1711957878076791,{"tab":0,"from":"/root/foo.txt","to":"/root/bar.txt"}
```

`--remote-events` stdout payload:

```
rename,0,1711957878076791,{"tab":0,"from":"/root/foo.txt","to":"/root/bar.txt"}
```

`bulk` \- bulk rename files

`sub()` / `sub_remote()` callback body:

```
-- Since `Iterator` implementing `__pairs()`,-- you can iterate over all URL pairs using `pairs(body)`Iterator {	__len = function(self)		-- Returns the number of files changed	end,	__pairs = function(self)		-- Returns (Url("/path/from.txt"), Url("/path/to.txt"))	end}
```

`--local-events` stdout payload:

```
bulk,1711957542289249,1711957542289249,{"changes":{"/path/from.txt":"/path/to.txt"}}
```

`--remote-events` stdout payload:

```
bulk,0,1711957542289249,{"changes":{"/path/from.txt":"/path/to.txt"}}
```

`yank` \- yank files

`sub()` callback body:

```
{}
```

`sub_remote()` callback body:

```
-- The `Iterator` implements `__pairs()`, so you can iterate over all URLs with `pairs()`Iterator {	cut = false,	__len = function(self)		-- Returns the number of URLs yanked	end,	__pairs = function(self)		-- Returns next URL	end}
```

`--local-events` stdout payload:

```
yank,1711960311454247,1711960311454247,{"cut":false,"urls":["/root/foo.txt","/root/bar.txt"]}
```

`--remote-events` stdout payload:

```
yank,0,300,{"cut":false,"urls":["/root/foo.txt","/root/bar.txt"]}
```

`move` \- move files

`sub()` callback body:

```
{	items = {		{ from = Url("/root/foo.txt"), to = Url("/root/bar.txt") },		-- ...	}}
```

`sub_remote()` callback body:

```
{	items = {		{ from = Url("/root/foo.txt"), to = Url("/root/bar.txt") },		-- ...	}}
```

`--local-events` stdout payload:

```
move,1711957542289249,1711957542289249,{"items":[{"from":"/root/foo.txt","to":"/root/bar.txt"}]}
```

`--remote-events` stdout payload:

```
move,0,1711957542289249,{"items":[{"from":"/root/foo.txt","to":"/root/bar.txt"}]}
```

`trash` \- trash files

`sub()` callback body:

```
{	urls = {		Url("/root/foo.txt"),		-- ...	}}
```

`sub_remote()` callback body:

```
{	urls = {		Url("/root/foo.txt"),		-- ...	}}
```

`--local-events` stdout payload:

```
trash,1711957542289249,1711957542289249,{"urls":["/root/foo.txt"]}
```

`--remote-events` stdout payload:

```
trash,0,1711957542289249,{"urls":["/root/foo.txt"]}
```

`delete` \- delete files

`sub()` callback body:

```
{	urls = {		Url("/root/foo.txt"),		-- ...	}}
```

`sub_remote()` callback body:

```
{	urls = {		Url("/root/foo.txt"),		-- ...	}}
```

`--local-events` stdout payload:

```
delete,1711957542289249,1711957542289249,{"urls":["/root/foo.txt"]}
```

`--remote-events` stdout payload:

```
delete,0,1711957542289249,{"urls":["/root/foo.txt"]}
```

`hi` \- client handshake

System reserves kind.

### `hey` \- server handshake

System reserves kind.

### `bye`

System reserves kind.

## Builtin plugins

`dds.lua`

This plugin provides a `dds-emit` event kind, which is used for the implementation of the `ya emit` subcommand — `ya emit` is a shorthand for `ya pub`, and the emitted command will be converted into an equivalent `ya pub` event message.

With `ya emit`, you can implement many interesting features, such as synchronizing the CWD of the current Yazi instance when exiting from a subshell:

- Zsh
- Fish
- Nushell

```
# Change Yazi's CWD to PWD on subshell exitif [[ -n "$YAZI_ID" ]]; then	function _yazi_cd() {		ya emit cd "$PWD"	}	add-zsh-hook zshexit _yazi_cdfi
```

```
# Change Yazi's CWD to PWD on subshell exitif [ -n "$YAZI_ID" ]	trap 'ya emit cd "$PWD"' EXITend
```

```
# Please raise a PR if you have a nushell version
```

Source code: [https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/plugins/dds.lua](https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/plugins/dds.lua)

### `session.lua`

This plugin provides cross-instance yank ability, which means you can yank files in one instance, and then paste them in another instance.

To enable it, add these lines to your `init.lua`, then restart **all** Yazi instances to apply the changes:

```
require("session"):setup {	sync_yanked = true,}
```

Source code: [https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/plugins/session.lua](https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/plugins/session.lua)

### `extract.lua`

This plugin provides an `extract` event kind for archive extraction, which accepts an array of file URL. You can bind it as [the opener](https://yazi-rs.github.io/docs/configuration/yazi#opener) for archives:

```
# ~/.config/yazi/yazi.toml[opener]extract = [	{ run = "ya pub extract --list %s", desc = "Extract here" },]
```

Source code: [https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/plugins/extract.lua](https://github.com/sxyazi/yazi/blob/main/yazi-plugin/preset/plugins/extract.lua)
