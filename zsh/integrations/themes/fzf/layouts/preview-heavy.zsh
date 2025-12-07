# FZF Layout: Preview Heavy
# Large preview area for file browsing

FZF_LAYOUT_NAME="Preview Heavy"
FZF_LAYOUT_DESC="Large preview panel (70%) for file browsing"

FZF_LAYOUT_OPTS=(
    "--height=90%"
    "--layout=reverse"
    "--border=rounded"
    "--info=inline"
    "--margin=1"
    "--padding=1"
    "--preview-window=right:70%:wrap:border-left"
)

FZF_LAYOUT_PROMPT='> '
FZF_LAYOUT_POINTER='>'
FZF_LAYOUT_MARKER='*'
