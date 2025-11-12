### Using Symlinks (Preferred)

- Find the icon you want to replace:
	`find ~/.icons/BaseTheme -name 'firefox.svg'`

- Symlink from another theme:

	`ln -s ~/.icons/OtherTheme/apps/scalable/firefox.svg ~/.icons/MyMixedTheme/apps/scalable/firefox.svg`

If you have multiple icon themes, you can batch symlink all icons from one to another:

    ln -s ~/.icons/OtherTheme/* ~/.icons/MyMixedTheme/

### Using a Script for Bulk Matching

If you want to mix multiple icon themes systematically, use a script:

```
#!/bin/bash
BASE_THEME=Papirus
ALT_THEME=Qogir
TARGET_THEME=MyMixedTheme
ICON_TYPES=("apps" "actions" "places" "devices" "mimetypes")

mkdir -p ~/.icons/$TARGET_THEME

for type in "${ICON_TYPES[@]}"; do
    mkdir -p ~/.icons/$TARGET_THEME/$type
    for icon in ~/.icons/$ALT_THEME/$type/*; do
        icon_name=$(basename "$icon")
        if [[ ! -e ~/.icons/$BASE_THEME/$type/$icon_name ]]; then
            ln -s "$icon" ~/.icons/$TARGET_THEME/$type/$icon_name
        fi
    done
done
```

This ensures that icons missing from the base theme get filled from an alternative theme.