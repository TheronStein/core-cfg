[uhs-robert/recycle-bin.yazi: 🗑️ recycle-bin.yazi is a Recycle Bin for Yazi with browse, restore, and cleanup capabilities. Give your files a second chance before they're garbage collected!](https://github.com/uhs-robert/recycle-bin.yazi)

# 🗑️ recycle-bin.yazi

[](https://github.com/uhs-robert/recycle-bin.yazi#️-recycle-binyazi)

[![License: MIT](https://camo.githubusercontent.com/0e46334f6de85981ecf0095ccdacded7efca9c4dce3dde71f93adc96988902f5/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f4c6963656e73652d4d49542d79656c6c6f772e7376673f7374796c653d666f722d7468652d6261646765)](https://opensource.org/licenses/MIT) [![Yazi](https://camo.githubusercontent.com/2657888fdde28d4df9f62a935f90f830fcf2ac56c1f8f36339e613f97eae24e9/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f59617a692d32352e352532422d626c75653f7374796c653d666f722d7468652d6261646765)](https://github.com/sxyazi/yazi) [![GitHub stars](https://camo.githubusercontent.com/9e7d6c066be11382ba75c3006ac40825077ac059508615d165ce3ac23fbbd0b1/68747470733a2f2f696d672e736869656c64732e696f2f6769746875622f73746172732f7568732d726f626572742f72656379636c652d62696e2e79617a693f7374796c653d666f722d7468652d6261646765)](https://github.com/uhs-robert/recycle-bin.yazi/stargazers) [![GitHub issues](https://camo.githubusercontent.com/17340ea7b0bb8c4d1448803c8b4273e82fda1d5d5542e517ca05dcdfb985a691/68747470733a2f2f696d672e736869656c64732e696f2f6769746875622f6973737565732d7261772f7568732d726f626572742f72656379636c652d62696e2e79617a693f7374796c653d666f722d7468652d6261646765)](https://github.com/uhs-robert/recycle-bin.yazi/issues)

A fast, minimal **Recycle Bin** for the [Yazi](https://github.com/sxyazi/yazi) terminal file‑manager.

Browse, restore, or permanently delete trashed files without leaving your terminal. Includes age-based cleanup and bulk actions.

recycle-bin-yazi-demo.mp4

Note

**Cross-Platform Support**

This plugin supports Linux and macOS systems.

## 🧠 What it does under the hood

[](https://github.com/uhs-robert/recycle-bin.yazi#-what-it-does-under-the-hood)

This plugin serves as a wrapper for the [trash-cli](https://github.com/andreafrancia/trash-cli) command, integrating it seamlessly with Yazi.

## ✨ Features

[](https://github.com/uhs-robert/recycle-bin.yazi#-features)

- **📂 Browse trash**: Navigate to trash directory directly in Yazi
- **🔄 Restore files**: Bulk restore selected files from trash to their original locations
    - **⚠️ Conflict resolution**: Intelligent handling when restored files already exist at destination
    - **🛡️ Safety dialogs**: Preview conflicts with skip/overwrite options before restoration
- **🗑️ Empty trash**: Clear entire trash with detailed file previews and confirmation dialog
- **📅 Empty by days**: Remove trash items older than specified number of days with size information
- **❌ Permanent delete**: Bulk delete selected files from trash permanently
- **🔧 Configurable**: Customize trash directory

## 📋 Requirements

[](https://github.com/uhs-robert/recycle-bin.yazi#-requirements)

| Software | Minimum | Notes |
| --- | --- | --- |
| Yazi | `>=25.5.31` | untested on 25.6+ |
| trash-cli | any | **Linux**: `sudo dnf/apt/pacman install trash-cli`  
**macOS**: `brew install trash-cli` |

The plugin uses the following trash-cli commands: `trash-list`, `trash-empty`, `trash-restore`, and `trash-rm`.

## 📦 Installation

[](https://github.com/uhs-robert/recycle-bin.yazi#-installation)

Install the plugin via Yazi's package manager:

# via Yazi’s package manager
ya pkg add uhs-robert/recycle-bin

Then add the following to your `~/.config/yazi/init.lua` to enable the plugin with default settings:

require("recycle-bin"):setup()

## ⚙️ Configuration

[](https://github.com/uhs-robert/recycle-bin.yazi#️-configuration)

The plugin automatically discovers your system's trash directories using `trash-list --trash-dirs`. If you need to customize the behavior, you can pass a config table to `setup()`:

require("recycle-bin"):setup({
  -- Optional: Override automatic trash directory discovery
  -- trash_dir = "~/.local/share/Trash/",  -- Uncomment to use specific directory
})

Note

The plugin supports multiple trash directories and will prompt you to choose which one to use if multiple are found.

## 🎹 Key Mapping

[](https://github.com/uhs-robert/recycle-bin.yazi#-key-mapping)

Add the following to your `~/.config/yazi/keymap.toml`. You can customize keybindings to your preference.

\[mgr\]
prepend_keymap = \[
  # Go to Trash directory
  { on = \[
    "g",
    "t",
  \], run = "plugin recycle-bin open", desc = "Go to Trash" },

  # Open the trash
  { on = \[
    "R",
    "o",
  \], run = "plugin recycle-bin open", desc = "Open Trash" },

  # Empty the trash
  { on = \[
    "R",
    "e",
  \], run = "plugin recycle-bin empty", desc = "Empty Trash" },

  # Delete selected items from trash
  { on = \[
    "R",
    "d",
  \], run = "plugin recycle-bin delete", desc = "Delete from Trash" },

  # Empty trash by days since deleted
  { on = \[
    "R",
    "D",
  \], run = "plugin recycle-bin emptyDays", desc = "Empty by days deleted" },

  # Restore selected items from trash
  { on = \[
    "R",
    "r",
  \], run = "plugin recycle-bin restore", desc = "Restore from Trash" },
\]

## 🚀 Usage

[](https://github.com/uhs-robert/recycle-bin.yazi#-usage)

### Basic Operations

[](https://github.com/uhs-robert/recycle-bin.yazi#basic-operations)

1. **Navigate to trash**: Press `gt` or `Ro` to go directly to the trash directory
2. **Restore files**: Select files in trash using Yazi's native selection and press `Rr` to restore them
    - The plugin automatically detects conflicts when files already exist at the original location
    - You'll be prompted to skip all or overwrite all conflicting files with detailed information
3. **Delete permanently**: Select files in trash and press `Rd` to delete them permanently
4. **Empty trash**: Press `Re` to empty the entire trash bin
    - Shows detailed file previews including names, sizes, and deletion dates before confirmation
5. **Empty by age**: Press `RD` to empty trash items older than specified days (defaults to 30 days)
    - Displays filtered list with file details and total size information

Tip

Use Yazi's visual selection (`v` or `V` followed by `ESC` to select items) or toggle select (press `Space` on individual files) to select multiple files from the Trash before restoring or deleting

The plugin will show a confirmation dialog for destructive operations

## 🛠️ Troubleshooting

[](https://github.com/uhs-robert/recycle-bin.yazi#️-troubleshooting)

### Common Issues

[](https://github.com/uhs-robert/recycle-bin.yazi#common-issues)

**"trashcli not found" error:**

- Ensure trash-cli is installed: `sudo dnf/apt/pacman install trash-cli`
- Verify installation: `trash-list --version`
- Check if trash-cli commands are in your PATH

**"Trash directory not found" error:**

- The plugin automatically discovers trash directories using `trash-list --trash-dirs`
- If no directories are found, create the standard location:
    - **Linux**: `mkdir -p ~/.local/share/Trash/{files,info}`
    - **macOS**: `mkdir -p ~/.Trash`
- You can also specify a custom path in your configuration

**"No files selected" warning:**

- Make sure you have files selected in Yazi before running restore/delete operations
- Use `Space` to select files or `v`/`V` for visual selection mode

## 💡 Recommendations

[](https://github.com/uhs-robert/recycle-bin.yazi#-recommendations)

### Companion Plugin

[](https://github.com/uhs-robert/recycle-bin.yazi#companion-plugin)

For an even better trash management experience, pair this plugin with:

**[restore.yazi](https://github.com/boydaihungst/restore.yazi)** \- Undo your delete history by your latest deleted files/folders

This companion plugin adds an "undo" feature that lets you press `u` to instantly restore the last deleted file. You can keep hitting `u` repeatedly to step through your entire delete history, making accidental deletions a thing of the past.

**Perfect combination:** Use `restore.yazi` for quick single-file undos and `recycle-bin.yazi` for comprehensive trash management and bulk operations.
