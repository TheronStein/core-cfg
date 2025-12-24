# FZF Layout: Preview Top
# Preview panel on top, list at bottom - ideal for directory browsing

FZF_LAYOUT_NAME="Preview Top"
FZF_LAYOUT_DESC="Preview on top (65%), compact list below"

FZF_LAYOUT_OPTS=(
    "--height=95%"
    "--layout=reverse"
    "--info=inline"
    "--preview-window=up:65%:wrap"
)
