[mikavilpas/easyjump.yazi: A Yazi plugin for quickly jumping to files](https://github.com/mikavilpas/easyjump.yazi)

# easyjump.yazi

[](https://github.com/mikavilpas/easyjump.yazi#easyjumpyazi)

A yazi plugin for quickly jumping to the visible files.

A bit like [hop.nvim](https://github.com/smoka7/hop.nvim) in Neovim but for yazi.

Tested on yazi stable ([25.5.28](https://github.com/sxyazi/yazi/releases/tag/v25.5.28)) and yazi nightly.

## Usage

[](https://github.com/mikavilpas/easyjump.yazi#usage)

Install the plugin. Choose your installation method:

Install with \`ya pkg\`

The documentation for `ya pkg` is at [https://yazi-rs.github.io/docs/cli/#pm](https://yazi-rs.github.io/docs/cli/#pm)

ya pkg add mikavilpas/easyjump.yazi:easyjump

* * *

Install with yazi.nvim

These instructions assume you are using [https://github.com/mikavilpas/yazi.nvim/blob/main/documentation/plugin-management.md](https://github.com/mikavilpas/yazi.nvim/blob/main/documentation/plugin-management.md)

return {
  name = "easyjump.yazi",
  url = "https://github.com/mikavilpas/easyjump.yazi",
  lazy = true,
  build = function(plugin)
    require("yazi.plugin").build_plugin(plugin, { sub_dir = "easyjump.yazi" })
  end,
}

* * *

## Configuration

[](https://github.com/mikavilpas/easyjump.yazi#configuration)

Initialize the plugin

-- ~/.config/yazi/init.lua

-- use the default settings
require("easyjump"):setup()

-- or customize the settings
require("easyjump"):setup({
  icon_fg = "#94e2d5",
  first\_key\_fg = "#45475a",
})

Set a shortcut key to toggle easyjump mode. For example, set `i`:

# ~/.config/yazi/keymap.toml
\[\[manager.prepend_keymap\]\]
on   = \[ "i" \]
run  = "plugin easyjump"
desc = "easyjump"

When you see a character (single or double) on the left side of the entry. Press the key of the character to jump to the corresponding entry.

## Acknowledgements 🙏🏻

[](https://github.com/mikavilpas/easyjump.yazi#acknowledgements-)

Originally developed by DreamMaoMao. The original version is hosted at [https://gitee.com/DreamMaoMao/easyjump.yazi](https://gitee.com/DreamMaoMao/easyjump.yazi). I liked this plugin so much that I wanted to add tests and maintain it.
