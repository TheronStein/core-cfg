# FZF Theme: ChaosCore
# Tokyo Night base with ChaosCore color overrides
# Custom palette for CORE system

FZF_THEME_NAME="ChaosCore"
FZF_THEME_CATEGORY="dark"

# Color definitions - ChaosCore palette
FZF_THEME_COLORS=(
    "bg:#1e1e2e"
    "bg+:#444267"
    "fg:#c0caf5"
    "fg+:#c0caf5"
    "hl:#01F9C6"
    "hl+:#69FF94"
    "info:#6698ff"
    "marker:#01F9C6"
    "pointer:#8470FF"
    "prompt:#3de8f7"
    "spinner:#6A5ACD"
    "header:#FFD700"
    "border:#2ac3de"
    "label:#6698ff"
    "query:#c0caf5"
    "gutter:#1e1e2e"
    "separator:#24283B"
    "scrollbar:#2ac3de"
    "preview-bg:#1e1e2e"
    "preview-fg:#c0caf5"
    "preview-border:#444267"
)

# Layout settings (inherits CORE global defaults)
FZF_THEME_LAYOUT=(
    "--height=80%"
    "--layout=reverse"
    "--info=inline"
    "--margin=1"
    "--padding=1"
)

# Prompt and marker characters
FZF_THEME_PROMPT='❯ '
FZF_THEME_POINTER='▶'
FZF_THEME_MARKER='▪'

# Header configuration
FZF_THEME_HEADER_FIRST=true
