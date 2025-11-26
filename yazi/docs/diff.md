[plugins/diff.yazi at main · yazi-rs/plugins](https://github.com/yazi-rs/plugins/tree/main/diff.yazi)

# diff.yazi

[](https://github.com/yazi-rs/plugins/tree/main/diff.yazi#diffyazi)

Diff the selected file with the hovered file, create a living patch, and copy it to the clipboard.

screenshot-000982.mp4

## Installation

[](https://github.com/yazi-rs/plugins/tree/main/diff.yazi#installation)

ya pkg add yazi-rs/plugins:diff

## Usage

[](https://github.com/yazi-rs/plugins/tree/main/diff.yazi#usage)

Add this to your `~/.config/yazi/keymap.toml`:

\[\[mgr.prepend_keymap\]\]
on   = "&lt;C-d&gt;"
run  = "plugin diff"
desc = "Diff the selected with the hovered file"

Make sure the C \+ d key is not used elsewhere.

## License

[](https://github.com/yazi-rs/plugins/tree/main/diff.yazi#license)

This plugin is MIT-licensed. For more information check the [LICENSE](https://github.com/yazi-rs/plugins/blob/main/diff.yazi/LICENSE) file.
