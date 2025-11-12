#!/bin/bash
# Backup zinit installation and prepare for fresh bootstrap

cd /home/theron/.core/cfg/zsh || exit 1

# Create backup with timestamp
backup_name="zinit.backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup: $backup_name"
mv zinit "$backup_name"

echo "Backup complete!"
echo "Now restart your shell - zinit will bootstrap itself automatically"
echo ""
echo "To restore if needed: mv $backup_name zinit"
