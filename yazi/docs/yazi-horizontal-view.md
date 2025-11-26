[Yazi file browser layout options - Claude](https://claude.ai/chat/60ce4c76-08db-4716-b36c-25454ae4dffd)

Is there a way to have the list of files in yazi to list out horizontally and vertically? Currently it only lists out vertically, if it were to list out files horizontally as well it would make it easier to see directories with a large amount of files/folders and easier navigate between them.

Yes, yazi does support different view modes including horizontal layouts! You can configure yazi to display files in multiple columns or even switch between different view modes.

Here are the main ways to achieve horizontal file listing in yazi:

## Multi-column View

You can enable a multi-column layout by modifying your yazi configuration. This will show files in multiple columns instead of a single vertical list.

**~/.config/yazi/yazi.toml** This is the main configuration file that controls yazi's behavior and appearance.

toml

```toml
[manager]
# Set the number of columns for file listing
# You can set this to a specific number or use "auto" to let yazi decide
columns = 3  # or try 2, 4, 5, etc. based on your preference

# Alternative: you can also use ratio-based layout
# layout = [1, 4, 3]  # left panel : center panel : right panel ratios
```

## Key Bindings for View Switching

You can also set up keybindings to quickly switch between different view modes:

**~/.config/yazi/keymap.toml** This file defines custom key bindings for yazi commands.

toml

```toml
[manager]
# Add keybindings to switch between view modes
prepend_keymap = [
    { on = [ "v", "1" ], run = "plugin --sync max-preview",  desc = "Maximize preview" },
    { on = [ "v", "2" ], run = "plugin --sync hide-preview", desc = "Hide preview" },
    { on = [ "v", "3" ], run = "plugin --sync multi-column", desc = "Multi-column view" },
]
```

## Miller Columns (Three-pane Layout)

Yazi uses a Miller column interface by default, but you can adjust the ratios:

**~/.config/yazi/yazi.toml**

toml

```toml
[manager]
# Adjust the three-pane layout ratios [left:center:right]
# Making the center pane wider gives more horizontal space for files
layout = [1, 5, 2]  # or try [1, 6, 1] for maximum center space
```

## Grid View Plugin

For a more traditional grid/icon view, you might want to look into community plugins that provide grid layouts, though this would require checking yazi's plugin ecosystem.

The multi-column approach in the center pane is probably your best bet for seeing more files horizontally while maintaining yazi's efficient navigation model. You can experiment with different column numbers and layout ratios to find what works best for your workflow and terminal size.
