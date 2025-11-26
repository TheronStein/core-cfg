[plugins/zoom.yazi at main · yazi-rs/plugins](https://github.com/yazi-rs/plugins/tree/main/zoom.yazi)

Note

The latest Yazi nightly build is required to use this plugin at the moment.

# zoom.yazi

[](https://github.com/yazi-rs/plugins/tree/main/zoom.yazi#zoomyazi)

Enlarge or shrink the preview image of a file, which is useful for magnifying small files for viewing.

Supported formats:

- Images - requires [ImageMagick](https://imagemagick.org/) (&gt;= 7.1.1)

Note that, the maximum size of enlarged images is limited by the [`max_width`](https://yazi-rs.github.io/docs/configuration/yazi#preview.max_width) and [`max_height`](https://yazi-rs.github.io/docs/configuration/yazi#preview.max_height) configuration options, so you may need to increase them as needed.

screenshot-003318.mp4

## Installation

[](https://github.com/yazi-rs/plugins/tree/main/zoom.yazi#installation)

ya pkg add yazi-rs/plugins:zoom

## Usage

[](https://github.com/yazi-rs/plugins/tree/main/zoom.yazi#usage)

# keymap.toml
\[\[mgr.prepend_keymap\]\]
on   = "+"
run  = "plugin zoom 1"
desc = "Zoom in hovered file"

\[\[mgr.prepend_keymap\]\]
on   = "-"
run  = "plugin zoom -1"
desc = "Zoom out hovered file"

## Advanced

[](https://github.com/yazi-rs/plugins/tree/main/zoom.yazi#advanced)

If you want to apply a default zoom parameter to image previews, you can specify it while setting this plugin up as a custom previewer, for example:

\[\[plugin.prepend_previewers\]\]
mime = "image/{jpeg,png,webp}"
run  = "zoom 5"

## TODO

[](https://github.com/yazi-rs/plugins/tree/main/zoom.yazi#todo)

- [ ]  Support more file types (e.g., videos, PDFs), PRs welcome!

## License

[](https://github.com/yazi-rs/plugins/tree/main/zoom.yazi#license)

This plugin is MIT-licensed. For more information check the [LICENSE](https://github.com/yazi-rs/plugins/blob/main/zoom.yazi/LICENSE) file.
