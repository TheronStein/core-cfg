Here's a clean, **Wayland-compatible KDE (Plasma 6)** setup for switching **keybinding layouts or profiles** dynamically — **without causing caching issues**.

---

## 🧩 GOAL

Let you switch:

- Between different **shortcut profiles** (like a Dev profile vs Gaming profile)
    
- Using scripts or hotkeys
    
- Without breaking KDE cache or requiring a reboot
    

---

## ✅ WHAT YOU’LL USE

- `kwriteconfig6` — safely write to KDE config files
    
- `qdbus org.kde.KWin /KWin reconfigure` — reload KWin without restarting session
    
- `kglobalshortcutsrc` and `kwinrc` — where KDE stores keybinding settings
    

---

## 📁 EXAMPLE STRUCTURE

Let’s say you have two profiles:

arduino

CopyEdit

`~/.config/kde-keymaps/ ├── dev_shortcuts.conf ├── gaming_shortcuts.conf`

Each of these files will contain a copy of your `kglobalshortcutsrc` (or just the relevant `[KWin]` or `[plasmashell]` sections).

---

## 🔧 STEP 1: Export Your Current Profile (Manual Step)

bash

CopyEdit

`cp ~/.config/kglobalshortcutsrc ~/.config/kde-keymaps/dev_shortcuts.conf`

Then customize a second one manually or with the KDE shortcut GUI and save it as:

bash

CopyEdit

`cp ~/.config/kglobalshortcutsrc ~/.config/kde-keymaps/gaming_shortcuts.conf`

---

## 🌀 STEP 2: Create a Switcher Script

bash

CopyEdit

`#!/bin/bash  PROFILE="$1"  SOURCE="$HOME/.config/kde-keymaps/${PROFILE}_shortcuts.conf" DEST="$HOME/.config/kglobalshortcutsrc"  if [[ ! -f "$SOURCE" ]]; then   echo "Profile not found: $SOURCE"   exit 1 fi  cp "$SOURCE" "$DEST"  # Reload KWin and global shortcuts qdbus org.kde.KWin /KWin reconfigure qdbus org.kde.kglobalaccel /component/kglobalaccel org.kde.kglobalaccel.Component.reload  notify-send "Switched to KDE keybinding profile: $PROFILE"`

Call this `switch_kde_keys.sh`, make it executable:

bash

CopyEdit

`chmod +x ~/bin/switch_kde_keys.sh`

---

## ⚡ EXAMPLE USAGE

bash

CopyEdit

`~/bin/switch_kde_keys.sh dev ~/bin/switch_kde_keys.sh gaming`

---

## 🚀 OPTIONAL: Add a Global Shortcut to Switch

Use **KDE System Settings → Shortcuts → Custom Shortcuts** to bind a hotkey to something like:

bash

CopyEdit

`bash -c '~/bin/switch_kde_keys.sh dev'`

You could bind different hotkeys for different profiles (e.g., Meta+F1 → dev, Meta+F2 → gaming).

---

## ✅ RESULT

- Keybinding changes are **applied instantly**
    
- No logout/reboot
    
- No KDE cache corruption
    
- You can make **multiple profiles**, switch at will
    

---

## 🧠 BONUS: Want to extend this to more than keybindings?

You can use similar techniques to switch:

- `kwinrc` settings (tiling, borders, focus behavior)
    
- Workspace-specific rules (e.g., `~/.config/kwinrulesrc`)
    
- Panel layouts (`plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`)
    

All can be swapped and followed with `qdbus` reloads.

Let me know if you want a full **profile manager** scri