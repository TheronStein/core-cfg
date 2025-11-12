#!/bin/bash
# Sync ProtonMail folders from Bridge to neomutt config
# Run this whenever you create new labels/folders in ProtonMail

SCRIPT_DIR="$(dirname "$0")"
CONFIG_FILE="$SCRIPT_DIR/proton.muttrc"
TEMP_SCRIPT="/tmp/list_imap_folders.py"

echo "Fetching folders from ProtonMail Bridge..."

# Create Python script to list folders
cat > "$TEMP_SCRIPT" << 'ENDPY'
#!/usr/bin/env python3
import imaplib
import subprocess
import sys

try:
    password = subprocess.check_output(
        ['gpg', '--quiet', '--for-your-eyes-only', '--no-tty', '--decrypt',
         '/home/theron/.config/neomutt/passwords/proton.gpg'],
        stderr=subprocess.DEVNULL
    ).decode().strip()

    mail = imaplib.IMAP4('127.0.0.1', 1143)
    mail.login('theron@chaoscore.org', password)
    status, folders = mail.list()

    if status == 'OK':
        # Organize folders by type
        main_folders = []
        labels = []
        regular_folders = []

        for folder in folders:
            parts = folder.decode().split('"')
            if len(parts) >= 3:
                folder_name = parts[-2]

                # Categorize folders
                if folder_name in ['INBOX', 'Sent', 'Drafts', 'Trash', 'Spam', 'Archive', 'All Mail', 'Starred']:
                    main_folders.append(folder_name)
                elif folder_name.startswith('Labels/'):
                    labels.append(folder_name)
                elif folder_name not in ['Labels', 'Folders']:
                    regular_folders.append(folder_name)

        # Sort each category
        labels.sort()
        regular_folders.sort()

        # Print mailboxes config
        print("# All ProtonMail Folders/Labels - Auto-generated from Bridge")
        print("unmailboxes *\n")

        print("# Main folders first")
        if main_folders:
            print('mailboxes ' + ' '.join([f'"+{f}"' for f in main_folders]))

        if labels:
            print("\n# Labels")
            # Group labels into lines of 5 for readability
            for i in range(0, len(labels), 5):
                chunk = labels[i:i+5]
                print('mailboxes ' + ' '.join([f'"+{f}"' for f in chunk]))

        if regular_folders:
            print("\n# Folders")
            for folder in regular_folders:
                if '/' in folder:  # Nested folders
                    print(f'mailboxes "+{folder}"')
                else:
                    print(f'mailboxes "+{folder}"')

    mail.logout()

except Exception as e:
    print(f"# Error: {e}", file=sys.stderr)
    sys.exit(1)
ENDPY

chmod +x "$TEMP_SCRIPT"

# Generate new mailboxes section
NEW_MAILBOXES=$(python3 "$TEMP_SCRIPT" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$NEW_MAILBOXES" ]; then
    echo "Found folders. Updating $CONFIG_FILE..."

    # Backup original
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"

    # Replace mailboxes section
    # Extract everything before "# All ProtonMail Folders"
    sed -n '1,/# All ProtonMail Folders/p' "$CONFIG_FILE" | head -n -1 > "$CONFIG_FILE.tmp"

    # Add new mailboxes
    echo "$NEW_MAILBOXES" >> "$CONFIG_FILE.tmp"

    # Add everything after the old mailboxes section
    sed -n '/# Label\/Folder Management Macros/,$p' "$CONFIG_FILE" >> "$CONFIG_FILE.tmp"

    # Replace original
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    echo "✓ Updated successfully!"
    echo "  Backup saved to: $CONFIG_FILE.backup"
    echo ""
    echo "Restart neomutt to see the changes."
else
    echo "✗ Error fetching folders from ProtonMail Bridge"
    echo "  Make sure the bridge is running and you're logged in."
fi

# Cleanup
rm -f "$TEMP_SCRIPT"
