#!/usr/bin/env bash
# Script to create example workspace templates
# You can customize these to match your common workflows

TEMPLATE_DIR="$HOME/.core/.sys/configs/wezterm/.data/workspace-templates"
mkdir -p "$TEMPLATE_DIR"

# Template 1: Config Workspace - for editing configuration files
cat > "$TEMPLATE_DIR/config.json" <<'EOF'
{
  "name": "config",
  "icon": "󰒓",
  "saved_at": "2025-10-29 00:00:00",
  "tabs": [
    {
      "title": "WezTerm Config",
      "icon": "",
      "panes": [
        {
          "cwd": "$HOME/.core/.sys/configs/wezterm",
          "title": ""
        }
      ]
    },
    {
      "title": "Neovim Config",
      "icon": "",
      "panes": [
        {
          "cwd": "$HOME/.core/.sys/configs/nvim",
          "title": ""
        }
      ]
    },
    {
      "title": "Shell Config",
      "icon": "",
      "panes": [
        {
          "cwd": "$HOME/.core/.sys/configs/zsh",
          "title": ""
        }
      ]
    }
  ]
}
EOF

# Template 2: Dev Workspace - for development projects
cat > "$TEMPLATE_DIR/dev.json" <<'EOF'
{
  "name": "dev",
  "icon": "",
  "saved_at": "2025-10-29 00:00:00",
  "tabs": [
    {
      "title": "Editor",
      "icon": "",
      "panes": [
        {
          "cwd": "$HOME",
          "title": ""
        }
      ]
    },
    {
      "title": "Terminal",
      "icon": "",
      "panes": [
        {
          "cwd": "$HOME",
          "title": ""
        },
        {
          "cwd": "$HOME",
          "title": ""
        }
      ]
    },
    {
      "title": "Git",
      "icon": "󰊢",
      "panes": [
        {
          "cwd": "$HOME",
          "title": ""
        }
      ]
    }
  ]
}
EOF

# Template 3: Media Workspace - for media management
cat > "$TEMPLATE_DIR/media.json" <<'EOF'
{
  "name": "media",
  "icon": "󰝚",
  "saved_at": "2025-10-29 00:00:00",
  "tabs": [
    {
      "title": "Music",
      "icon": "󰎆",
      "panes": [
        {
          "cwd": "$HOME/.config/spotify-player",
          "title": ""
        }
      ]
    },
    {
      "title": "MPV Config",
      "icon": "󰐌",
      "panes": [
        {
          "cwd": "$HOME/.config/mpv",
          "title": ""
        }
      ]
    },
    {
      "title": "Files",
      "icon": "󰉋",
      "panes": [
        {
          "cwd": "$HOME",
          "title": ""
        }
      ]
    }
  ]
}
EOF

# Template 4: Dotfiles Workspace - for managing dotfiles
cat > "$TEMPLATE_DIR/dotfiles.json" <<'EOF'
{
  "name": "dotfiles",
  "icon": "󰚰",
  "saved_at": "2025-10-29 00:00:00",
  "tabs": [
    {
      "title": "Core Config",
      "icon": "󰒓",
      "panes": [
        {
          "cwd": "$HOME/.core/cfg",
          "title": ""
        }
      ]
    },
    {
      "title": "Scripts",
      "icon": "",
      "panes": [
        {
          "cwd": "$HOME/.core/cfg",
          "title": ""
        },
        {
          "cwd": "$HOME/.core/cfg",
          "title": ""
        }
      ]
    }
  ]
}
EOF

# Replace $HOME with actual home directory
sed -i "s|\$HOME|$HOME|g" "$TEMPLATE_DIR"/*.json

echo "✅ Created example workspace templates in $TEMPLATE_DIR"
echo ""
echo "Available templates:"
ls -1 "$TEMPLATE_DIR"/*.json | xargs -n1 basename | sed 's/.json$//'
echo ""
echo "You can load these with:"
echo "  LEADER + L  (Load workspace template)"
echo "  LEADER + w  (Workspace template menu)"
