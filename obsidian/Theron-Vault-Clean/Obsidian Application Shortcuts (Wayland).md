### 🔥 The Problem (and How KDE Pins Apps)

On **Wayland**, KDE groups windows and pins based on:

- The **`StartupWMClass`** in the `.desktop` file _(if present and matched)_
    
- OR the **binary name** if no explicit app ID is set
    
- **Pinning only works properly** if the window that launches matches the `.desktop` entry
    

But **Obsidian from pacman**:

- Launches as `/usr/bin/obsidian`
    
- Doesn’t support `--class`, so every vault window has the **same app identity**
    
- KDE groups and pins them all under the same task icon unless we trick it
    

---

### ✅ Strategy: Create Per-Vault Launchers That KDE Can Recognize as Unique

We’ll do the following:

|Step|Description|
|---|---|
|1|Create a wrapper script per vault|
|2|Make a unique `.desktop` file for each vault|
|3|Use a fake `StartupWMClass` (trick KDE’s grouping logic)|
|4|Provide a matching icon with that class name|
|5|Launch from the `.desktop` file before pinning|

---

### ✅ 1. Create a Wrapper Script

bash

CopyEdit

`# ~/.local/bin/obsidian-zen-dev.sh #!/bin/bash /usr/bin/obsidian --vault "Zen Dev"`

Make it executable:

bash

CopyEdit

`chmod +x ~/.local/bin/obsidian-zen-dev.sh`

---

### ✅ 2. Create a Matching `.desktop` File

ini

CopyEdit

`# ~/.local/share/applications/obsidian-zen-dev.desktop [Desktop Entry] Name=Obsidian - Zen Dev Exec=/home/theron/.local/bin/obsidian-zen-dev.sh Icon=obsidian-zen-dev StartupWMClass=obsidian-zen-dev Type=Application Terminal=false Categories=Utility;Notes;`

---

### ✅ 3. Create a Matching Icon

bash

CopyEdit

`mkdir -p ~/.local/share/icons/hicolor/128x128/apps/ cp /path/to/your/icon.png ~/.local/share/icons/hicolor/128x128/apps/obsidian-zen-dev.png`

Update icon cache:

bash

CopyEdit

`gtk-update-icon-cache ~/.local/share/icons/hicolor`

Update KDE’s database:

bash

CopyEdit

`kbuildsycoca6`

---

### ✅ 4. Launch and Pin from the `.desktop` File

1. Press `Alt+Space` (KRunner), or use your app launcher.
    
2. Search `Obsidian - Zen Dev` and run it.
    
3. **Once the window opens**, right-click its icon in the task manager → **Pin to Task Manager**.
    

✅ KDE will now associate that pinned shortcut with your `.desktop` file, **not** with `/usr/share/applications/obsidian.desktop`.

Even though Obsidian can’t change its internal class, KDE **remembers the `.desktop` launcher used** and will keep vaults isolated as long as they’re launched through their own `.desktop` file.

---

### ⚠️ Important Tips

- **Always launch from your vault shortcut** (don’t reuse existing Obsidian windows when opening `.md` files from outside — they’ll group wrong).
    
- If KDE still groups them, go to:  
    `System Settings → Workspace Behavior → Task Manager → Behavior → Group tasks: [By program name or manually]`.
    

---

Let me know if you want a **script that auto-generates `.desktop` launchers and icons** for all your vaults.