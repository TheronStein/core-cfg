```
#!/bin/bash

actid_design=119538676


#Define app -> activity mapping using WM_CLASS 

declare -A app_activity_map

app_types=[
"home",
"dev",
"games",
"work",
"design",
"planning",
"system"]

actId_Design="124e0e32-b38d-401c-b218-ba5b8eb812fa"
actId_Dev="b115986c-2711-4a92-9dbf-fa243f575b93"
actId_Home="27ee7d43-2328-401f-a3f1-8df7d9b3e88e"
actId_Games="bc7c7046-1cac-463e-89e1-f268def2ab3c "
actId_Plan="1eb552cd-ef10-4bb8-88ad-c842613b635e"
actId_Sys="b7a4f3b6-e594-454b-b664-aa54d5570e45"
actId_Work="e686fc25-e13e-48cf-87b3-0564fb076f64"

sepApps = [
"zen", 
"obsidian",
"",]

designApps = [
"GIMP",
"Blender",
"Photoshop",
"terminal-design",
"obsidian-design",
]

devApps = [
"windsurf",
"terminal-dev",
]

gamesApps = [
"Steam",
"Heroic Launcher",
"Discord",
""
]

workApps = [
"Slack",
"zen-work",
"obsidian-work",
"anydesk"
]

planApps = [
"zen-life"
"obsidian-life"
]

homeApps = [
"Spotify",
"zen",
"obs",
"obsidian"
]

sysApps = [
""
]

activity_ideas = [
"streaming",
"canavas/diagrams",
"network",
"resources"
]

portableApps = [
"Discord",
"Spotify",
"Terminal",
"Settings"
]

zen_map["zen-work"]="27ee7d43-2328-401f-a3f1-8df7d9b3e88e"

app_activity_map["zen-work"]="workactivity-UUID"
app_activity_map["firefox"]="browsing-UUID"
app_activity_map["code"]="coding-UUID"
```