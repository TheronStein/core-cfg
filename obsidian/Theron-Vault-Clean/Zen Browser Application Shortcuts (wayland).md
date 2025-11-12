I need to fix my zen-browser shortcuts on wayland, it's all opening under one shortcut and when i try to open links it doesnt properly handle them. here are my three zen.desktop configurations and i removed the main one under /usr/share/applications [Desktop Entry] Categories=Network;WebBrowser; Comment[en_US]=Experience tranquillity while browsing the web without people tracking you! Comment=Experience tranquillity while browsing the web without people tracking you! Exec=/opt/zen-browser-bin/zen -P ros --class=rose StartupWMClass=ZenRose GenericName[en_US]= GenericName= Icon=/home/theron/.local/share/icons/hicolor/zen-indigo.svg Keywords=Internet;WWW;Browser;Web;Explorer MimeType= Name[en_US]=Zen Browser Name=Zen Browser Path= PrefersNonDefaultGPU=false StartupNotify=true Terminal=false TerminalOptions= Type=Application X-KDE-SubstituteUID=false X-KDE-Username= [Desktop Entry] Categories=Network;WebBrowser; Comment[en_US]=Experience tranquillity while browsing the web without people tracking you! Comment=Experience tranquillity while browsing the web without people tracking you! Exec=/opt/zen-browser-bin/zen -P Careview --class=careview StartupWMClass=ZenCareview GenericName[en_US]= GenericName= Icon=/home/theron/.local/share/icons/hicolor/zen-blue.svg Keywords=Internet;WWW;Browser;Web;Explorer MimeType= Name[en_US]=Zen Careview Name=Zen Careview Path= PrefersNonDefaultGPU=false StartupNotify=true Terminal=false TerminalOptions= Type=Application X-KDE-SubstituteUID=false X-KDE-Username= [Desktop Entry] Name=Zen Browser Comment=Experience tranquillity while browsing the web without people tracking you! Exec=/opt/zen-browser-bin/zen -P Theron --class=zen-theron StartupWMClass=ZenTheron Icon=/home/theron/.local/share/icons/hicolor/zen-turquoise.svg Type=Application MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;application/x-xpinstall;application/pdf;application/json; Categories=Network;WebBrowser; Name[en_US]=Zen Browser Name=Zen Browser Path= PrefersNonDefaultGPU=false StartupNotify=true Terminal=false TerminalOptions= Type=Application X-KDE-SubstituteUID=false X-KDE-Username=Theron StartupNotify=true Terminal=false X-MultipleArgs=false Keywords=Internet;WWW;Browser;Web;Explorer; Actions=new-window;new-private-window;profilemanager;

###### ChatGPT said:

Thanks for sharing your `.desktop` entries. The issue you're facing on **Wayland** is likely caused by the **StartupWMClass**, `--class`, and possibly missing unique `MimeType` handlers or `DBusActivatable` properties — which are important for applications launched via URI schemes (like when opening a link from another app).

### 🚨 Main Problems:

1. **Shared `Name` / `StartupWMClass` issues**: Some of your entries reuse `Name=Zen Browser`, which can cause confusion in launchers and window tracking.
    
2. **Lack of proper `MimeType` + `DBusActivatable` in alternate profiles**: Only your last entry has `MimeType`, making it the default handler.
    
3. **Missing `SingleInstance` isolation**: All profiles likely launch as one window or override each other due to class name and WM integration issues.
    
4. **Wayland ignores `StartupWMClass` more often than X11**, relying on `--class` or `XDG_SESSION_CLASS`.
    

---

### ✅ Goals:

- Properly separate each profile/window under its own icon and shortcut.
    
- Allow opening links (URIs) into the _default_ browser profile (`zen-theron`).
    
- Prevent all links from being forced into one instance.
    
- Enable Wayland compatibility and proper registration.
    

---

### ✅ Fix Instructions

#### 1. **Ensure unique names per profile**

Update `Name`, `StartupWMClass`, and `--class` values to be consistent and **distinct**.

For example, update the first two like this:

---

**`zen-rose.desktop`**

ini

CopyEdit

`[Desktop Entry] Name=Zen Rose Exec=/opt/zen-browser-bin/zen -P ros --class=zen-rose StartupWMClass=zen-rose Icon=/home/theron/.local/share/icons/hicolor/zen-indigo.svg Type=Application Categories=Network;WebBrowser; StartupNotify=true Terminal=false Keywords=Internet;WWW;Browser;Web;Explorer;`

**`zen-careview.desktop`**

ini

CopyEdit

`[Desktop Entry] Name=Zen Careview Exec=/opt/zen-browser-bin/zen -P Careview --class=zen-careview StartupWMClass=zen-careview Icon=/home/theron/.local/share/icons/hicolor/zen-blue.svg Type=Application Categories=Network;WebBrowser; StartupNotify=true Terminal=false Keywords=Internet;WWW;Browser;Web;Explorer;`

**Important: Don't reuse `Zen Browser` for the other entries' `Name`. That name will be associated with your default `x-scheme-handler/http` profile.**

---

#### 2. **Default browser desktop entry (handle links)**

Use this for your main profile (`zen-theron.desktop`), adding proper `MimeType` + URI handler:

ini

CopyEdit

`[Desktop Entry] Name=Zen Browser Exec=/opt/zen-browser-bin/zen -P Theron --class=zen-theron %u StartupWMClass=zen-theron Icon=/home/theron/.local/share/icons/hicolor/zen-turquoise.svg Type=Application Categories=Network;WebBrowser; MimeType=x-scheme-handler/http;x-scheme-handler/https;text/html;application/xhtml+xml; StartupNotify=true Terminal=false Keywords=Internet;WWW;Browser;Web;Explorer; Actions=new-window;new-private-window;`

---

#### 3. **Register the default properly**

Run this to set the default browser to the correct `.desktop`:

bash

CopyEdit

`xdg-settings set default-web-browser zen-theron.desktop`

---

#### 4. **Optional: Isolate D-Bus Instances**

You could add this to the non-default profiles to avoid registering URI handlers:

ini

CopyEdit

`DBusActivatable=false`

---

#### 5. **Refresh desktop entries**

If your shortcuts aren't updating:

bash

CopyEdit

`update-desktop-database ~/.local/share/applications kbuildsycoca6`

---

### ✅ Verify Everything

- Launch each shortcut: they should open in their own window/class.
    
- Test opening a link from another app: it should launch **Zen Browser (Theron)**.
    
- Use `xprop | grep WM_CLASS` to confirm unique `--class` values are honored.
    

---

Let me know if you want to create `.desktop` actions like “Open in Rose Profile” from your main launcher or auto-route specific links to specific profiles.

##### You said:

how do i make the icon for the shortcut override with the one provided to it, so it's not showing up with a wayland icon everytime

###### ChatGPT said:

On **Wayland**, the desktop environment (especially KDE Plasma or GNOME) **often ignores the `Icon=` in `.desktop` files unless everything lines up perfectly** — including `StartupWMClass`, `--class`, and `app_id`. Sometimes it will fall back to a default icon (like a Wayland "W" icon or the generic one) if those don’t match.

Here’s how to make **your custom icon show properly** for each shortcut:

---

### ✅ Steps to Force Your Custom Icon in Wayland (KDE/Plasma, GNOME)

#### 1. **Use a unique `--class` and match it with `StartupWMClass`**

You’re already doing this. Make sure:

- `--class=zen-rose` (passed to the binary)
    
- `StartupWMClass=zen-rose` (in `.desktop` file)
    

These **must exactly match**, and Wayland must report that same class name.

To check if it’s working:

bash

CopyEdit

`xprop | grep WM_CLASS # or under Wayland: wezterm ls --class`

> If you’re using KDE, try `qdbus org.kde.KWin /KWin org.kde.KWin.getWindowInfo` on the window.

---

#### 2. **Use a full path to the icon**

You're already doing this:

ini

CopyEdit

`Icon=/home/theron/.local/share/icons/hicolor/zen-indigo.svg`

✅ That’s good, but Wayland/Plasma sometimes expects icons to live in an icon theme directory.

To make it more robust:

- Place the icon in:
    
    bash
    
    CopyEdit
    
    `~/.local/share/icons/hicolor/128x128/apps/zen-rose.png`
    
- Then in your `.desktop` file:
    
    ini
    
    CopyEdit
    
    `Icon=zen-rose`
    

After placing it, update the icon cache:

bash

CopyEdit

`gtk-update-icon-cache ~/.local/share/icons/hicolor`

---

#### 3. **Force Plasma to reload icon and application cache**

bash

CopyEdit

`kbuildsycoca6`

This clears the icon and `.desktop` entry cache.

---

#### 4. **Remove `~/.cache/icon-cache.kcache` (Plasma-specific)**

If KDE Plasma keeps showing the wrong icon:

bash

CopyEdit

`rm ~/.cache/icon-cache.kcache kbuildsycoca6`

Then log out and back in (or restart plasmashell):

bash

CopyEdit

`killall plasmashell && kstart5 plasmashell`

---

#### 5. **Final `.desktop` File Example (zen-rose)**

ini

CopyEdit

`[Desktop Entry] Name=Zen Rose Exec=/opt/zen-browser-bin/zen -P ros --class=zen-rose StartupWMClass=zen-rose Icon=zen-rose Type=Application Categories=Network;WebBrowser; StartupNotify=true Terminal=false Keywords=Internet;WWW;Browser;Web;Explorer;`

With icon file located at:

swift

CopyEdit

`~/.local/share/icons/hicolor/128x128/apps/zen-rose.png`

---

Let me know if you're on KDE or GNOME so I can tailor more specific fixes — the workaround for GNOME (which uses `app_id` detection) is different from KDE (which looks at `StartupWMClass` more).

##### You said:

I mean on the toolbar at the top of the application

###### ChatGPT said:

Ah — you're talking about **the window icon in the titlebar** (top of the application window), **not** the icon in the application launcher or taskbar. On **Wayland**, this is a bit more complicated than X11, because:

> **Under Wayland, the window icon is not set by `.desktop` entries.**

Instead, it's usually controlled **by the application itself** via the **`--class`** (or Wayland `app_id`) and **the window manager (like KWin)**.

---

### 🧠 Why It Happens

On **Wayland**, applications don't have the same window property system as X11 (`WM_CLASS`, `WM_ICON_NAME`, etc.). Instead:

- They are identified by **Wayland `app_id`**, which is usually set by `--class` or hardcoded by the app.
    
- The **window icon** shown in the titlebar (or overview/task switcher) is resolved by looking up that `app_id` in installed icon themes.
    

If the `app_id` (`--class`) is **not associated with an icon in the icon theme**, Wayland compositors (like KDE’s KWin) fall back to a generic Wayland icon.

---

### ✅ How to Fix It (Show Your Custom Icon in the Titlebar on Wayland)

#### 1. ✅ Use `--class=yourappname` and `StartupWMClass=yourappname`

Which you already do:

bash

CopyEdit

`Exec=/opt/zen-browser-bin/zen -P ros --class=zen-rose StartupWMClass=zen-rose`

But now you need to provide an icon named `zen-rose` in your icon theme.

---

#### 2. ✅ Create and Install Icon to Match the Class Name

- Place your icon file (must be `.png`, not `.svg` for this part) here:
    

bash

CopyEdit

`mkdir -p ~/.local/share/icons/hicolor/128x128/apps/ cp /home/theron/.local/share/icons/hicolor/zen-indigo.svg ~/.local/share/icons/hicolor/128x128/apps/zen-rose.png`

- You **must name the file** after your class/app ID:  
    `zen-rose.png` ← matches `--class=zen-rose`
    
- Then update the icon cache:
    

bash

CopyEdit

`gtk-update-icon-cache ~/.local/share/icons/hicolor`

---

#### 3. 🔄 Refresh KDE/Plasma Icon and App Cache

bash

CopyEdit

`kbuildsycoca6`

Then **restart the app**, or log out and back in if needed.

---

### ✅ Summary

To set the **titlebar icon** on Wayland:

| Requirement             | Value                                                    |
| ----------------------- | -------------------------------------------------------- |
| `--class`               | `zen-rose`                                               |
| Icon path               | `~/.local/share/icons/hicolor/128x128/apps/zen-rose.png` |
| Icon name               | Must match the class name (`zen-rose`)                   |
| `gtk-update-icon-cache` | Required after placing icon                              |
| `kbuildsycoca6`         | Refresh KDE’s cache                                      |

---

Let me know if you're using **KWin (Plasma)** or **GNOME**, and I’ll give you compositor-specific debugging tips.