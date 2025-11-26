[plugins/smart-filter.yazi at main · yazi-rs/plugins](https://github.com/yazi-rs/plugins/tree/main/smart-filter.yazi)

# smart-filter.yazi

[](https://github.com/yazi-rs/plugins/tree/main/smart-filter.yazi#smart-filteryazi)

A Yazi plugin that makes filters smarter: continuous filtering, automatically enter unique directory, open file on submitting.

screenshot-000464.mp4

## Installation

[](https://github.com/yazi-rs/plugins/tree/main/smart-filter.yazi#installation)

ya pkg add yazi-rs/plugins:smart-filter

## Usage

[](https://github.com/yazi-rs/plugins/tree/main/smart-filter.yazi#usage)

Add this to your `~/.config/yazi/keymap.toml`:

\[\[mgr.prepend_keymap\]\]
on   = "F"
run  = "plugin smart-filter"
desc = "Smart filter"

Make sure the F key is not used elsewhere.

## License

[](https://github.com/yazi-rs/plugins/tree/main/smart-filter.yazi#license)

This plugin is MIT-licensed. For more information check the [LICENSE](https://github.com/yazi-rs/plugins/blob/main/smart-filter.yazi/LICENSE) file.
