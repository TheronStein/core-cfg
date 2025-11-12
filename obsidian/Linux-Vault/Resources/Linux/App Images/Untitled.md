#### Entry Template

`Obsidian Vault`
```
[Desktop Entry]
Name=Obsidian Custom URI Handler
Exec=obsidian "obsidian://open?vault=CareView-Vault&file=TicketView" --class=obsidian-careview
Type=Application
Terminal=false
Categories=Utility;
StartupWMClass=obsidian-careview
```
#### Update
`update-desktop-database ~/.local/share/applications`