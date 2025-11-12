### ❌ Unsafe to Symlink (Even Locally)

|File or Dir|Why it's unsafe|
|---|---|
|`~/.config/plasmarc`, `plasmashellrc`|Manages widget state, runtime QML objects|
|`~/.local/share/plasmashell/`|Runtime state folder|
|`~/.local/share/plasma/`|Widget installations — can break widget loading|
|`~/.cache/plasma*`, `ksycoca*`|Plasma rebuilds these often|
|`~/.config/kwinoutputconfig.json`|Rewritten on monitor config changes|
|`~/.config/plasma-workspace/`|Manages shell plugins, QML and session layout|
|`~/.config/kded6rc`, `~/.local/share/kded6/`|