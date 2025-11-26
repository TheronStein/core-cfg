[plugins/smart-enter.yazi at main · yazi-rs/plugins](https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi)

# smart-enter.yazi

[](https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi#smart-enteryazi)

[`Open`](https://yazi-rs.github.io/docs/configuration/keymap/#mgr.open) files or [`enter`](https://yazi-rs.github.io/docs/configuration/keymap/#mgr.enter) directories all in one key!

## Installation

[](https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi#installation)

ya pkg add yazi-rs/plugins:smart-enter

## Usage

[](https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi#usage)

Bind your l key to the plugin, in your `~/.config/yazi/keymap.toml`:

\[\[mgr.prepend_keymap\]\]
on   = "l"
run  = "plugin smart-enter"
desc = "Enter the child directory, or open the file"

## Advanced

[](https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi#advanced)

By default, `--hovered` is passed to the [`open`](https://yazi-rs.github.io/docs/configuration/keymap/#mgr.open) command, make the behavior consistent with [`enter`](https://yazi-rs.github.io/docs/configuration/keymap/#mgr.enter) avoiding accidental triggers, which means both will only target the currently hovered file.

If you still want `open` to target multiple selected files, add this to your `~/.config/yazi/init.lua`:

require("smart-enter"):setup {
	open_multi = true,
}

## License

[](https://github.com/yazi-rs/plugins/tree/main/smart-enter.yazi#license)This plugin is MIT-licensed. For more information check the [LICENSE](https://github.com/yazi-rs/plugins/blob/main/smart-enter.yazi/LICENSE) file.
