[bulletmark/cdhist.yazi: Yazi plugin for cdhist to fuzzy select and navigate within Yazi from your directory history](https://github.com/bulletmark/cdhist.yazi)

# cdhist.yazi - Yazi plugin to use cdhist to select and navigate to a previous directory

[](https://github.com/bulletmark/cdhist.yazi#cdhistyazi---yazi-plugin-to-use-cdhist-to-select-and-navigate-to-a-previous-directory)

[Yazi](https://yazi-rs.github.io/) plugin to use [cdhist](http://github.com/bulletmark/cdhist) to fuzzy select and navigate from your directory history, within the [Yazi](https://yazi-rs.github.io/) terminal file manager.

## Installation

[](https://github.com/bulletmark/cdhist.yazi#installation)

Use the [yazi package manager](https://yazi-rs.github.io/docs/cli#package-manager) to install this plugin:

ya pack -a bulletmark/cdhist

Then add to your [`~/.config/yazi/keymap.toml`](https://yazi-rs.github.io/docs/configuration/keymap):

\[\[manager.prepend_keymap\]\]
on   = "&lt;A-c&gt;"
run  = "plugin cdhist -- _ --fuzzy=fzf"
desc = "Select a directory from history using cdhist"

Make sure you have [cdhist](http://github.com/bulletmark/cdhist) installed, and can be found in your `PATH`.

The above assigns `Alt-c` key mapping within yazi to bring up the fuzzy search because it is the standard key mapping for [opening fzf on directories](https://github.com/junegunn/fzf?tab=readme-ov-file#key-bindings-for-command-line) and for [using with cdhist](https://github.com/bulletmark/cdhist#fuzzy-finder-integration). However, you may prefer to remap the standard `z` key mapping in yazi to replace [`zoxide`](https://yazi-rs.github.io/docs/quick-start/#navigation), or use a spare key like the `C` key.

Note [`fzf`](https://github.com/junegunn/fzf) is preferred for cdhist fuzzy searching, but you can also use [`sk`](https://github.com/skim-rs/skim), or [`fzy`](https://github.com/jhawthorn/fzy) in the above configuration setting. Or leave the `--fuzzy` option out to use native simple [cdhist index selection](https://github.com/bulletmark/cdhist#example-usage).
