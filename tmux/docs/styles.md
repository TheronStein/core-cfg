## [STYLES](https://man.openbsd.org/tmux#STYLES)

`tmux` offers various options to specify the colour and attributes of aspects of the interface, for example `status-style` for the status line. In addition, embedded styles may be specified in format options, such as `status-left`, by enclosing them in ‘`#[`’ and ‘`]`’.

A style may be the single term ‘`default`’ to specify the default style (which may come from an option, for example `status-style` in the status line) or a space or comma separated list of the following:

[`fg=colour`](https://man.openbsd.org/tmux#fg=colour)

Set the foreground colour. The colour is one of: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`; if supported the bright variants `brightblack`, `brightred`, ...; `colour0` to `colour255` from the 256-colour set; `default` for the default colour; `terminal` for the terminal default colour; or a hexadecimal RGB string such as ‘`#ffffff`’.

[`bg=colour`](https://man.openbsd.org/tmux#bg=colour)

Set the background colour.

[`us=colour`](https://man.openbsd.org/tmux#us=colour)

Set the underscore colour.

[`none`](https://man.openbsd.org/tmux#none)

Set no attributes (turn off any active attributes).

[`acs`](https://man.openbsd.org/tmux#acs), `bright` (or `bold`), `dim`, `underscore`, `blink`, `reverse`, `hidden`, `italics`, `overline`, `strikethrough`, `double-underscore`, `curly-underscore`, `dotted-underscore`, `dashed-underscore`

Set an attribute. Any of the attributes may be prefixed with ‘`no`’ to unset. `acs` is the terminal alternate character set.

[`align=left`](https://man.openbsd.org/tmux#align=left) (or `noalign`), `align=centre`, `align=right`

Align text to the left, centre or right of the available space if appropriate.

[`fill=colour`](https://man.openbsd.org/tmux#fill=colour)

Fill the available space with a background colour if appropriate.

[`list=on`](https://man.openbsd.org/tmux#list=on), `list=focus`, `list=left-marker`, `list=right-marker`, `nolist`

Mark the position of the various window list components in the `status-format` option: `list=on` marks the start of the list; `list=focus` is the part of the list that should be kept in focus if the entire list won't fit in the available space (typically the current window); `list=left-marker` and `list=right-marker` mark the text to be used to mark that text has been trimmed from the left or right of the list if there is not enough space.

[`noattr`](https://man.openbsd.org/tmux#noattr)

Do not copy attributes from the default style.

[`push-default`](https://man.openbsd.org/tmux#push-default), `pop-default`

Store the current colours and attributes as the default or reset to the previous default. A `push-default` affects any subsequent use of the `default` term until a `pop-default`. Only one default may be pushed (each `push-default` replaces the previous saved default).

[`range=left`](https://man.openbsd.org/tmux#range=left), `range=right`, `range=session|X`, `range=window|X`, `range=pane|X`, `range=user|X`, `norange`

Mark a range for mouse events in the `status-format` option. When a mouse event occurs in the `range=left` or `range=right` range, the ‘`StatusLeft`’ and ‘`StatusRight`’ key bindings are triggered.

`range=session|X`, `range=window|X` and `range=pane|X` are ranges for a session, window or pane. These trigger the ‘`Status`’ mouse key with the target session, window or pane given by the ‘`X`’ argument. ‘`X`’ is a session ID, window index in the current session or a pane ID. For these, the `mouse_status_range` format variable will be set to ‘`session`’, ‘`window`’ or ‘`pane`’.

`range=user|X` is a user-defined range; it triggers the ‘`Status`’ mouse key. The argument ‘`X`’ will be available in the `mouse_status_range` format variable. ‘`X`’ must be at most 15 bytes in length.

[`set-default`](https://man.openbsd.org/tmux#set-default)

Set the current colours and attributes as the default, overwriting any previous default. The previous default cannot be restored.

Examples are:

fg=yellow bold underscore blink
bg=black,fg=default,noreverse

## [NAMES AND TITLES](https://man.openbsd.org/tmux#NAMES_AND_TITLES)

`tmux` distinguishes between names and titles. Windows and sessions have names, which may be used to specify them in targets and are displayed in the status line and various lists: the name is the `tmux` identifier for a window or session. Only panes have titles. A pane's title is typically set by the program running inside the pane using an escape sequence (like it would set the [xterm(1)](https://man.openbsd.org/xterm.1) window title in [X(7)](https://man.openbsd.org/X.7)). Windows themselves do not have titles - a window's title is the title of its active pane. `tmux` itself may set the title of the terminal in which the client is running, see the `set-titles` option.

A session's name is set with the `new-session` and `rename-session` commands. A window's name is set with one of:

1.  A command argument (such as `-n` for `new-window` or `new-session`).
2.  An escape sequence (if the `allow-rename` option is turned on):
    
    $ printf '\\033kWINDOW\_NAME\\033\\\\'
    
3.  Automatic renaming, which sets the name to the active command in the window's active pane. See the `automatic-rename` option.

When a pane is first created, its title is the hostname. A pane's title can be set via the title setting escape sequence, for example:

$ printf '\\033\]2;My Title\\033\\\\'

It can also be modified with the `select-pane` `-T` command.

## [GLOBAL AND SESSION ENVIRONMENT](https://man.openbsd.org/tmux#GLOBAL_AND_SESSION_ENVIRONMENT)

When the server is started, `tmux` copies the environment into the [_global environment_](https://man.openbsd.org/tmux#global); in addition, each session has a _session environment_. When a window is created, the session and global environments are merged. If a variable exists in both, the value from the session environment is used. The result is the initial environment passed to the new process.

The `update-environment` session option may be used to update the session environment from the client when a new session is created or an old reattached. `tmux` also initialises the `TMUX` variable with some internal information to allow commands to be executed from inside, and the `TERM` variable with the correct terminal setting of ‘`screen`’.

Variables in both session and global environments may be marked as hidden. Hidden variables are not passed into the environment of new processes and instead can only be used by tmux itself (for example in formats, see the [FORMATS](https://man.openbsd.org/tmux#FORMATS) section).

Commands to alter and view the environment are:

[`set-environment`](https://man.openbsd.org/tmux#set-environment) \[`-Fhgru`\] \[`-t` target-session\] variable \[value\]

(alias: `setenv`)

Set or unset an environment variable. If `-g` is used, the change is made in the global environment; otherwise, it is applied to the session environment for target-session. If `-F` is present, then value is expanded as a format. The `-u` flag unsets a variable. `-r` indicates the variable is to be removed from the environment before starting a new process. `-h` marks the variable as hidden.

[`show-environment`](https://man.openbsd.org/tmux#show-environment) \[`-hgs`\] \[`-t` target-session\] \[variable\]

(alias: `showenv`)

Display the environment for target-session or the global environment with `-g`. If variable is omitted, all variables are shown. Variables removed from the environment are prefixed with ‘`-`’. If `-s` is used, the output is formatted as a set of Bourne shell commands. `-h` shows hidden variables (omitted by default).
