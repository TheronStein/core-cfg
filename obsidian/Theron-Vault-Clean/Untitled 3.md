### 🔎 Confirm the script is properly installed (Wayland expects this):

Ensure your KWin script has the correct structure:

ruby

Copy code

`~/.local/share/kwin/scripts/activitymover/ ├── contents/ │   └── code/ │       └── main.js ├── metadata.desktop`

And inside `metadata.desktop`, you need at least:

ini

Copy code

```
[Desktop Entry] Name=Activity Mover Comment=Move windows between activities with shortcuts Type=Service X-KDE-PluginInfo-Author=YourName X-KDE-PluginInfo-Name=activitymover X-KDE-PluginInfo-Version=1.0 X-KDE-PluginInfo-EnabledByDefault=false X-Plasma-API=javascript X-Plasma-MainScript=code/main.js
```

### 📦 Want a dedicated script to reload safely?

bash

Copy code
```
#!/bin/bash PLUGIN="activitymover"  kwriteconfig6 --file kwinrc --group Plugins --key "${PLUGIN}Enabled" false qdbus org.kde.KWin /KWin reconfigure sleep 1 kwriteconfig6 --file kwinrc --group Plugins --key "${PLUGIN}Enabled" true qdbus org.kde.KWin /KWin reconfigure
```

You can bind this to a hotkey or script call for testing.

---

### 🧠 Summary for Wayland

- **Yes**, `qdbus` and `kwriteconfig6` still work on Wayland, but DBus may expose less than on X11.
    
- **Use `metadata.desktop`** to make sure Plasma properly recognizes your script.
    
- **Use `kwinrc` plugin keys** to toggle and reload safely.
    

Let me know if you want a watcher script to automatically reload on `main.js` changes or errors logged via KWin.