[iynaix/time-travel.yazi: A yazi plugin for browsing backwards and forwards in time via BTRFS / ZFS snapshots.](https://github.com/iynaix/time-travel.yazi?tab=readme-ov-file#time-travelyazi)

# time-travel.yazi

[](https://github.com/iynaix/time-travel.yazi?tab=readme-ov-file#time-travelyazi)

A Yazi plugin for browsing backwards and forwards in time via BTRFS / ZFS snapshots.

zfs.yazi.mp4

## Installation

[](https://github.com/iynaix/time-travel.yazi?tab=readme-ov-file#installation)

ya pack -a iynaix/time-travel

Note

The minimum required yazi version is 25.2.7.

## Usage

[](https://github.com/iynaix/time-travel.yazi?tab=readme-ov-file#usage)

Add keymaps similar to the following to your `~/.config/yazi/keymap.toml`:

\[\[manager.prepend_keymap\]\]
on = \["z", "h"\]
run = "plugin time-travel --args=prev"
desc = "Go to previous snapshot"

\[\[manager.prepend_keymap\]\]
on = \["z", "l"\]
run = "plugin time-travel --args=next"
desc = "Go to next snapshot"

\[\[manager.prepend_keymap\]\]
on = \["z", "e"\]
run = "plugin time-travel --args=exit"
desc = "Exit browsing snapshots"

#### Note for BTRFS

[](https://github.com/iynaix/time-travel.yazi?tab=readme-ov-file#note-for-btrfs)`sudo` is required to run btrfs commands such as `btrfs subvolume list`, the plugin will drop into a terminal to prompt for the password.
