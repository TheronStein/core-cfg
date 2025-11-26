[macydnah/office.yazi: Office documents previewer plugin for Yazi, using libreoffice (compatible with .docx, .xlsx, .pptx, .odt, .ods, .odp; and other file formats supported by the Office Open XML and OpenDocument standards)](https://github.com/macydnah/office.yazi)

# office.yazi

 [![preview test](https://github.com/macydnah/office.yazi/raw/assets/preview_test.gif)](https://github.com/macydnah/office.yazi/blob/assets/preview_test.gif) [![preview test](https://github.com/macydnah/office.yazi/raw/assets/preview_test.gif)

](https://github.com/macydnah/office.yazi/blob/assets/preview_test.gif)[](https://github.com/macydnah/office.yazi/blob/assets/preview_test.gif)

## Installation

[](https://github.com/macydnah/office.yazi#installation)

Tip

Installing this plugin with `ya` will conveniently clone the plugin from GitHub, copy it to your plugins directory, and update the `package.toml` to lock its version [1](https://github.com/macydnah/office.yazi#user-content-fn-1-5668d058cba740a103ea2db21e66781f).

To install it with `ya` run:

ya pkg add macydnah/office

Or if you prefer a manual approach:

#\# For linux and MacOS
git clone https://github.com/macydnah/office.yazi.git ~/.config/yazi/plugins/office.yazi

#\# For Windows
git clone https://github.com/macydnah/office.yazi.git %AppData%\\yazi\\config\\plugins\\office.yazi

## Usage

[](https://github.com/macydnah/office.yazi#usage)

In your `yazi.toml` add rules to preloaders[2](https://github.com/macydnah/office.yazi#user-content-fn-2-5668d058cba740a103ea2db21e66781f) and previewers[3](https://github.com/macydnah/office.yazi#user-content-fn-3-5668d058cba740a103ea2db21e66781f) to run `office` plugin with office documents.

Note

Your config may be different depending if you're _appending_, _prepending_ or _overriding_ default rules. If unsure, take a look at [Configuration](https://yazi-rs.github.io/docs/configuration/overview)[4](https://github.com/macydnah/office.yazi#user-content-fn-4-5668d058cba740a103ea2db21e66781f) and [Configuration mixing](https://yazi-rs.github.io/docs/configuration/overview#mixing)[5](https://github.com/macydnah/office.yazi#user-content-fn-5-5668d058cba740a103ea2db21e66781f)

For a general usecase, you may use the following rules

\[plugin\]

prepend_preloaders = \[
    # Office Documents
    { mime = "application/openxmlformats-officedocument.*", run = "office" },
    { mime = "application/oasis.opendocument.*", run = "office" },
    { mime = "application/ms-*", run = "office" },
    { mime = "application/msword", run = "office" },
    { name = "*.docx", run = "office" },
\]

prepend_previewers = \[
    # Office Documents
    { mime = "application/openxmlformats-officedocument.*", run = "office" },
    { mime = "application/oasis.opendocument.*", run = "office" },
    { mime = "application/ms-*", run = "office" },
    { mime = "application/msword", run = "office" },
    { name = "*.docx", run = "office" },
\]

## Dependencies

[](https://github.com/macydnah/office.yazi#dependencies)

Important

Make sure that these commands are installed in your system and can be found in `PATH`:

- `libreoffice`
- `pdftoppm`

## License

[](https://github.com/macydnah/office.yazi#license)

office.yazi is licensed under the terms of the [MIT License](https://github.com/macydnah/office.yazi/blob/main/LICENSE)

## Footnotes

1. [The official package manager for Yazi](https://yazi-rs.github.io/docs/cli) [↩](https://github.com/macydnah/office.yazi#user-content-fnref-1-5668d058cba740a103ea2db21e66781f)
    
2. [Preloaders rules](https://yazi-rs.github.io/docs/configuration/yazi#plugin.preloaders) [↩](https://github.com/macydnah/office.yazi#user-content-fnref-2-5668d058cba740a103ea2db21e66781f)
    
3. [Previewers rules](https://yazi-rs.github.io/docs/configuration/yazi#plugin.previewers) [↩](https://github.com/macydnah/office.yazi#user-content-fnref-3-5668d058cba740a103ea2db21e66781f)
    
4. [Configuration](https://yazi-rs.github.io/docs/configuration/overview) [↩](https://github.com/macydnah/office.yazi#user-content-fnref-4-5668d058cba740a103ea2db21e66781f)
    
5. [Configuration mixing](https://yazi-rs.github.io/docs/configuration/overview#mixing) [↩](https://github.com/macydnah/office.yazi#user-content-fnref-5-5668d058cba740a103ea2db21e66781f)
