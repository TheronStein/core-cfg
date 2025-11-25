#!/usr/bin/env python3
"""Generate nerdfont browser data from WezTerm nerdfonts name list"""

import os
import json
import re
from pathlib import Path
from collections import defaultdict

# Paths
HOME = Path.home()
DATA_FILE = HOME / ".core/cfg/wezterm/.data/wezterm_nerdfont_names.txt"
CUSTOM_ICONS_FILE = HOME / ".core/cfg/wezterm/modules/custom_icons.lua"
OUTPUT_DIR = HOME / ".core/cfg/wezterm/scripts/nerdfont-browser/data"

# Category definitions with prefixes
CATEGORIES = {
    "cod_": {"name": "Codicons", "description": "VS Code icons", "color": "blue"},
    "custom_": {"name": "Custom", "description": "Custom programming icons", "color": "magenta"},
    "dev_": {"name": "Devicons", "description": "Developer and tech icons", "color": "green"},
    "fa_": {"name": "Font Awesome", "description": "Font Awesome 4.x icons", "color": "yellow"},
    "fae_": {"name": "FA Extension", "description": "Font Awesome Extension", "color": "bright_yellow"},
    "linux_": {"name": "Linux Logos", "description": "Linux distribution logos", "color": "bright_blue"},
    "md_": {"name": "Material Design", "description": "Material Design icons", "color": "cyan"},
    "oct_": {"name": "Octicons", "description": "GitHub Octicons", "color": "white"},
    "personal_": {"name": "Personal Icons", "description": "My personal icon definitions", "color": "bright_magenta"},
    "pl_": {"name": "Powerline", "description": "Powerline symbols", "color": "red"},
    "ple_": {"name": "Powerline Extra", "description": "Powerline Extra symbols", "color": "bright_red"},
    "pom_": {"name": "Pomicons", "description": "Pomicons set", "color": "bright_cyan"},
    "seti_": {"name": "Seti UI", "description": "Seti UI file icons", "color": "bright_green"},
    "weather_": {"name": "Weather", "description": "Weather icons", "color": "bright_magenta"},
}

def parse_custom_icons():
    """Parse custom_icons.lua to extract icon definitions"""
    if not CUSTOM_ICONS_FILE.exists():
        print(f"Warning: {CUSTOM_ICONS_FILE} not found, skipping personal icons")
        return []

    personal_icons = []
    with open(CUSTOM_ICONS_FILE) as f:
        content = f.read()
        # Match lines like: yazi = "icon", -- comment
        # or: md_flattr = wezterm.nerdfonts.md_cloud_download,
        pattern = r'^\s*(\w+)\s*=\s*(?:"[^"]*"|wezterm\.nerdfonts\.\w+)\s*,?\s*(?:--.*)?$'
        for line in content.split('\n'):
            match = re.match(pattern, line)
            if match and not line.strip().startswith('--'):
                icon_name = match.group(1)
                # Prefix with "personal_" for categorization
                personal_icons.append(f"personal_{icon_name}")

    return personal_icons

def main():
    # Read icon names
    if not DATA_FILE.exists():
        print(f"Error: {DATA_FILE} not found")
        print("Run: python3 ~/.core/cfg/wezterm/scripts/fetch-nerdfonts.py first")
        return 1

    with open(DATA_FILE) as f:
        icon_names = [line.strip() for line in f if line.strip()]

    # Add personal icons from custom_icons.lua
    personal_icons = parse_custom_icons()
    icon_names.extend(personal_icons)

    print(f"Loaded {len(icon_names)} icon names ({len(personal_icons)} personal)")

    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Categorize icons
    categorized = defaultdict(list)
    for name in icon_names:
        for prefix in CATEGORIES:
            if name.startswith(prefix):
                categorized[prefix].append(name)
                break

    # Write category files (just names, no glyphs since we can't render them here)
    total_written = 0
    categories_meta = []

    for prefix, cat_info in CATEGORIES.items():
        if prefix not in categorized or not categorized[prefix]:
            continue

        icons = sorted(categorized[prefix])
        filename = f"wezterm-{cat_info['name'].lower().replace(' ', '-')}.txt"
        filepath = OUTPUT_DIR / filename

        with open(filepath, 'w') as f:
            f.write(f"# {cat_info['name']} ({len(icons)} icons)\n")
            f.write(f"# Generated from WezTerm nerdfonts\n")
            f.write(f"# Format: icon_name (glyphs rendered by WezTerm picker)\n\n")

            for name in icons:
                # We'll just write the name, the WezTerm picker will render the actual glyph
                f.write(f"{name}\n")

        print(f"✓ Wrote {len(icons):4d} icons to {filename}")
        total_written += len(icons)

        # Get first icon name as sample
        sample_name = icons[0] if icons else ""

        categories_meta.append({
            "name": cat_info["name"],
            "file": filename,
            "description": f"{cat_info['description']} ({len(icons)} icons)",
            "color": cat_info["color"],
            "icon_name": sample_name,  # Store name instead of glyph
            "count": len(icons)
        })

    # Sort categories by name
    categories_meta.sort(key=lambda x: x["name"])

    # Write categories.json
    json_file = OUTPUT_DIR / "categories.json"
    with open(json_file, 'w') as f:
        json.dump({"categories": categories_meta}, f, indent=2)

    print(f"\n✓ Total: {total_written} icons across {len(categories_meta)} categories")
    print(f"✓ Wrote {json_file}")
    print(f"\nℹ️  Data files created in: {OUTPUT_DIR}")

if __name__ == "__main__":
    exit(main() or 0)
