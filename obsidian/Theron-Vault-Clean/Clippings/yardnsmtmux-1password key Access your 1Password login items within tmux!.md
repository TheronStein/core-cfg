---
title: "yardnsm/tmux-1password: :key: Access your 1Password login items within tmux!"
source: "https://github.com/yardnsm/tmux-1password"
author:
  - "[[yardnsm]]"
published:
created: 2025-06-14
description: ":key: Access your 1Password login items within tmux! - yardnsm/tmux-1password"
tags:
  - "clippings"
---
**[tmux-1password](https://github.com/yardnsm/tmux-1password)** Public

🔑 Access your 1Password login items within tmux!

[MIT license](https://github.com/yardnsm/tmux-1password/blob/master/LICENSE)

[Open in github.dev](https://github.dev/) [Open in a new github.dev tab](https://github.dev/) [Open in codespace](https://github.com/codespaces/new/yardnsm/tmux-1password?resume=1)

## tmux-1password

> Access your 1Password login items within tmux!

tmux-1password-demo.mp4<video src="https://private-user-images.githubusercontent.com/11786506/159118616-9983fca2-edb5-4d0b-b827-43088e84d2c8.mp4?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDk4OTMxNDIsIm5iZiI6MTc0OTg5Mjg0MiwicGF0aCI6Ii8xMTc4NjUwNi8xNTkxMTg2MTYtOTk4M2ZjYTItZWRiNS00ZDBiLWI4MjctNDMwODhlODRkMmM4Lm1wND9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA2MTQlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNjE0VDA5MjA0MlomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWE1ZTYwNzA2ZmFmZGJlODg3MWM1ZjcyZTkyNzY0NDBkNzg1MTEwMzdjMDhlY2UwMDhmOGI4NmI1OTdmNjVhZmYmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.byXoSTrMxXRFIpBe0mSWtDlsHK1ljRqw2oZj5yXMrlI" controls="controls"></video>

This plugin allows you to access you 1Password items within tmux, using 1Password's CLI. It works for personal 1Password accounts, as well as teams accounts.

## Requirements

This plugin relies on the following:

- [1Password CLI](https://developer.1password.com/docs/cli) >= 2.0.0
- [fzf](https://github.com/junegunn/fzf)
- [jq](https://stedolan.github.io/jq/)

## Key bindings

In any tmux mode:

- `prefix + u` - list login items in a bottom pane.

## Install

1. Add plugin to the list of TPM plugins in `.tmux.conf`:
	```
	set -g @plugin 'yardnsm/tmux-1password'
	```
2. Hit `prefix + I` to fetch the plugin and source it. You should now be able to use the plugin.

### Manual Installation

1. Clone this repo:
	```
	$ git clone https://github.com/yardnsm/tmux-1password ~/some/path
	```
2. Source the plugin in your `.tmux.conf` by adding the following to the bottom of the file:
	```
	run-shell ~/some/path/plugin.tmux
	```
3. Reload the environment by running:
	```
	$ tmux source-file ~/.tmux.conf
	```

If you're using an older version of the CLI (`< 2.0`), you can use this plugin via the [`legacy`](https://github.com/yardnsm/tmux-1password/tree/legacy) branch. For example, using TPM:

```
set -g @plugin 'yardnsm/tmux-1password#legacy'
```

## Usage

Initiate the plugin by using the keybind (`prefix + u` by default). If you haven't added an account to the 1Password's CLI, the plugin will prompt you to add one. You can also manage your connected accounts manually using the [`op account` command](https://developer.1password.com/docs/cli/reference/management-commands/account).

Once you have an account, while initiating the plugin a new pane will be opened in the bottom, listing the appropriate login items. Press `<Enter>` to choose a login item, and its password will automatically be filled.

You can also press `Ctrl+u` while hovering an item to fill a [One-Time Password](https://support.1password.com/one-time-passwords/).

You may be required to perform a re-login (directly in the opened pane) since the 1Password CLI's sessions expires automatically after 30 minutes of inactivity.

### Biometric Unlock

For supported systems, you can enable [signing in with biometric unlock](https://developer.1password.com/docs/cli/about-biometric-unlock). When biometric unlock is enabled, you'll be prompted to authorize using it when then plugin is being initiated.

## Configuration

Customize this plugin by setting these options in your `.tmux.conf` file. Make sure to reload the environment afterwards.

```
set -g @1password-key 'x'
```

Default: `'u'`

1Password's CLI allows signing in with [multiple accounts](https://developer.1password.com/docs/cli/use-multiple-accounts/), while this plugin is able to work against a single one. You can specify which account to use using this option.

As per the [documentation](https://developer.1password.com/docs/cli/use-multiple-accounts/#find-an-account-shorthand-and-id), you can use the shorthand, sign-in address, or account ID to refer to a specific account.

```
set -g @1password-account 'acme'
```

Default: `'my'`

```
set -g @1password-vault 'work'
```

Default: `''` (all vaults)

By default, the plugin will use `send-keys` to send the selected password to the targeted pane. By setting the following, the password will be copied to the system's clipboard, which will be cleared after 30 seconds.

```
set -g @1password-copy-to-clipboard 'on'
```

Default: `'off'`

By default, all of the items will be shown. You can use this option (comma-separated) if you want to list items that has specific tags.

```
set -g @1password-filter-tags 'development,servers'
```

Default: `''` (no tag filtering)

#### Debug mode

If you're having any trouble with the plugin and would like to debug it's output in a more convenient way, this option will prevent the pane from being closed.

```
set -g @1password-debug 'on'

# Or running the following withing tmux:
tmux set-option -g @1password-debug "on"
```

## Prior art

Also see:

- [sudolikeaboss](https://github.com/ravenac95/sudolikeaboss)

---

## License

MIT © [Yarden Sod-Moriah](http://yardnsm.net/)

## Releases

No releases published

## Packages

No packages published  

## Languages

- [Shell 100.0%](https://github.com/yardnsm/tmux-1password/search?l=shell)