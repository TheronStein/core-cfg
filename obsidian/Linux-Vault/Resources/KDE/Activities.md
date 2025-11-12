
### Listing UUIDs
`qdbus org.kde.ActivityManager /ActivityManager/Activities ListActivities`

### Launch window to activity

`qdbus org.kde.KWin /KWin setWindowToActivity <WID> <Activity-ID>`

- `<WID>` is the **window ID** of the app
- `<Activity-ID>` is the **UUID of the target activity**

Find the App’s Window ID Run:

`xdotool search --onlyvisible --class "firefox"`

Example output:

`41943049`

Move the Window to the Activity

`qdbus org.kde.KWin /KWin setWindowToActivity 41943049 96a1b431-5896-4f2f-b19b-8d582bdefb0a`

(Replace the WID and Activity ID with your actual values.)

### App `.desktop` Template

Edit or Create a Custom Launcher

nano ~/.local/share/applications/firefox-activity.desktop

Add the following:

```
[Desktop Entry]
Name=Firefox (Activity)
Exec=bash -c 'firefox & sleep 1 && qdbus org.kde.KWin /KWin setWindowToActivity $(xdotool search --onlyvisible --class "firefox" | head -n1) 96a1b431-5896-4f2f-b19b-8d582bdefb0a'
Icon=firefox
Type=Application
StartupNotify=true
```

Save and run:

`update-desktop-database ~/.local/share/applications`

Now, when you launch "Firefox (Activity)", it will always open in the specified KDE Activity.