#!/bin/bash
# List all ProtonMail folders/labels from Bridge

echo "Connecting to ProtonMail Bridge to list folders..."
echo ""

# Get password
PASS=$(gpg --quiet --for-your-eyes-only --no-tty --decrypt ~/.config/neomutt/passwords/proton.gpg 2>/dev/null)

# Connect to IMAP and list folders
{
    echo "a LOGIN theron@chaoscore.org $PASS"
    sleep 1
    echo "b LSUB \"\" \"*\""
    sleep 1
    echo "c LIST \"\" \"*\""
    sleep 1
    echo "d LOGOUT"
    sleep 1
} | nc 127.0.0.1 1143 2>/dev/null | grep -E '^\* (LIST|LSUB)' | sed 's/.*"\(.*\)"$/\1/' | sort -u | while read folder; do
    echo "  - $folder"
done

echo ""
echo "These folders will automatically appear in your sidebar when you start neomutt!"
echo "Press F3 to switch to ProtonMail and you'll see them all."
