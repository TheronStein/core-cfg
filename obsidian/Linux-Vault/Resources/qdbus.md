
## List Activites

`qdbus org.kde.ActivityManager /ActivityManager/Activities ListActivities`

```
qdbus org.kde.ActivityManager /ActivityManager/Activities ListActivities | while read uuid; do
    name=$(qdbus org.kde.ActivityManager /ActivityManager/Activities ActivityName "$uuid")
    echo "$uuid - $name"
done
```

```
b7a4f3b6-e594-454b-b664-aa54d5570e45 - Computer
124e0e32-b38d-401c-b218-ba5b8eb812fa - Design
b115986c-2711-4a92-9dbf-fa243f575b93 - Dev
bc7c7046-1cac-463e-89e1-f268def2ab3c - Games
27ee7d43-2328-401f-a3f1-8df7d9b3e88e - Home
1eb552cd-ef10-4bb8-88ad-c842613b635e - Organize
e686fc25-e13e-48cf-87b3-0564fb076f64 - Work
```

## setWindowToActivity

qdbus org.kde.KWin /KWin setWindowToActivity <WID> <Activity-ID>

`qdbus org.kde.KWin /KWin setWindowToActivity $(xdotool search --onlyvisible --class "firefox" | head -n1) 96a1b431-5896-4f2f-b19b-8d582bdefb0a`