#!/usr/bin/env bash
# Unmount all fuse-archive mounts

mount | grep 'type fuse.fuse-archive' | awk '{print $3}' | while read -r mountpoint; do
    echo "Unmounting: $mountpoint"
    umount "$mountpoint" 2>/dev/null && echo "  ✓ Unmounted" || echo "  ✗ Failed"
done

# Clean up empty directories
if [ -d "$HOME/.local/state/yazi/fuse-archive" ]; then
    find "$HOME/.local/state/yazi/fuse-archive" -type d -empty -delete 2>/dev/null
fi

if [ -d "$HOME/mnt/archives" ]; then
    find "$HOME/mnt/archives" -type d -empty -delete 2>/dev/null
fi

echo "Archive cleanup complete"
