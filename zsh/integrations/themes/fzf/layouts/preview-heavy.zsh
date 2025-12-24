# FZF Layout: Preview Heavy
# Large preview area for file browsing

FZF_LAYOUT_NAME="Preview Heavy"
FZF_LAYOUT_DESC="90% height with 70% right preview"

FZF_LAYOUT_OPTS=(
    "--height=90%"
    "--layout=reverse"
    "--info=inline"
    "--margin=1"
    "--padding=1"
    "--preview-window=right:70%:wrap:border-left"
)

# Uses global defaults for styling
