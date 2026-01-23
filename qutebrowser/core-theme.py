def setup(c, options={}):
    # Theme palette - TokyoNight-inspired with vibrant aqua accents
    palette = {
        # Base colors (Catppuccin backgrounds)
        "background": "#1e1e2e",
        "surface": "#444267",
        "rust": "#313244",
        "mantle": "#013e4a",
        "crest": "#e0af68",
        # Text colors
        "foreground": "#c0caf5",
        "foreground2": "#a9a1e1",
        # Accent colors - your favorites
        "red": "#FF5370",
        "amber": "#f9e2af",
        "coral": "#FFB86C",
        "gold": "#FFD700",
        "yellow": "#f1fc79",
        "emerald": "#69FF94",
        "core": "#01F9C6",       # Your signature green
        "cyan": "#3de8f7",
        "teal": "#2ac3de",
        "aqua": "#027d95",
        "turquoise": "#0f857c",
        "blue": "#6698ff",
        "sapphire": "#4361EE",
        "cobalt": "#2b4b90",
        "navy": "#0b348c",
        "purple": "#8470FF",
        "indigo": "#5b4996",
        "violet": "#2d244b",
        # Utility colors
        "black": "#181920",
        "dark-gray": "#21242b",
        "medium-gray": "#3f444a",
        "light-gray": "#5b6268",
        "white": "#c0caf5",
        "bright-white": "#fefefe",
    }

    spacing = options.get("spacing", {"vertical": 5, "horizontal": 5})

    padding = options.get(
        "padding",
        {
            "top": spacing["vertical"],
            "right": spacing["horizontal"],
            "bottom": spacing["vertical"],
            "left": spacing["horizontal"],
        },
    )

    # Larger statusbar padding for better visibility
    statusbar_padding = {
        "top": 8,
        "right": spacing["horizontal"],
        "bottom": 8,
        "left": spacing["horizontal"],
    }

    # Tab padding
    c.tabs.padding = padding
    c.tabs.indicator.width = 3
    c.tabs.favicons.scale = 1

    # === COMPLETION WIDGET ===
    # Using surface/rust backgrounds with aqua/cyan accents
    c.colors.completion.category.bg = palette["surface"]
    c.colors.completion.category.border.bottom = palette["rust"]
    c.colors.completion.category.border.top = palette["rust"]
    c.colors.completion.category.fg = palette["aqua"]  # Your signature color
    c.colors.completion.even.bg = palette["background"]
    c.colors.completion.odd.bg = palette["rust"]
    c.colors.completion.fg = palette["foreground"]
    c.colors.completion.item.selected.bg = palette["surface"]
    c.colors.completion.item.selected.border.bottom = palette["surface"]
    c.colors.completion.item.selected.border.top = palette["surface"]
    c.colors.completion.item.selected.fg = palette["aqua"]
    c.colors.completion.item.selected.match.fg = palette["cyan"]
    c.colors.completion.match.fg = palette["emerald"]

    # Scrollbar
    c.colors.completion.scrollbar.fg = palette["core"]
    c.colors.completion.scrollbar.bg = palette["rust"]

    # === DOWNLOADS ===
    c.colors.downloads.bar.bg = palette["rust"]
    c.colors.downloads.error.bg = palette["red"]
    c.colors.downloads.error.fg = palette["bright-white"]
    c.colors.downloads.start.bg = palette["aqua"]
    c.colors.downloads.stop.bg = palette["emerald"]
    c.colors.downloads.start.fg = palette["black"]
    c.colors.downloads.stop.fg = palette["black"]
    c.colors.downloads.system.bg = "rgb"
    c.colors.downloads.system.fg = "rgb"

    # === HINTS ===
    c.colors.hints.bg = palette["aqua"]
    c.colors.hints.fg = palette["black"]
    c.hints.border = "1px solid " + palette["cyan"]
    c.colors.hints.match.fg = palette["emerald"]

    # === KEYHINTS ===
    c.colors.keyhint.bg = palette["coral"]
    c.colors.keyhint.fg = palette["black"]
    c.colors.keyhint.suffix.fg = palette["medium-gray"]

    # === MESSAGES ===
    c.colors.messages.error.bg = palette["rust"]
    c.colors.messages.error.border = palette["red"]
    c.colors.messages.error.fg = palette["red"]
    c.colors.messages.info.bg = palette["rust"]
    c.colors.messages.info.border = palette["sapphire"]
    c.colors.messages.info.fg = palette["sapphire"]
    c.colors.messages.warning.bg = palette["rust"]
    c.colors.messages.warning.border = palette["amber"]
    c.colors.messages.warning.fg = palette["yellow"]

    # === PROMPTS ===
    c.colors.prompts.bg = palette["background"]
    c.colors.prompts.border = "1px solid " + palette["aqua"]
    c.colors.prompts.fg = palette["core"]
    c.colors.prompts.selected.bg = palette["surface"]

    # === STATUSBAR ===
    # Each mode gets a distinct vibrant color
    c.colors.statusbar.caret.bg = palette["navy"]
    c.colors.statusbar.caret.fg = palette["white"]
    c.colors.statusbar.caret.selection.bg = palette["violet"]
    c.colors.statusbar.caret.selection.fg = palette["white"]
    
    c.colors.statusbar.command.bg = palette["rust"]
    c.colors.statusbar.command.fg = palette["cyan"]
    c.colors.statusbar.command.private.bg = palette["sapphire"]
    c.colors.statusbar.command.private.fg = palette["bright-white"]
    
    c.colors.statusbar.insert.bg = palette["sapphire"]
    c.colors.statusbar.insert.fg = palette["black"]
    
    c.colors.statusbar.normal.bg = palette["surface"]  # Your signature color
    c.colors.statusbar.normal.fg = palette["core"]
    
    c.colors.statusbar.passthrough.bg = palette["coral"]
    c.colors.statusbar.passthrough.fg = palette["black"]
    
    c.colors.statusbar.private.bg = palette["mantle"]
    c.colors.statusbar.private.fg = palette["amber"]
    
    c.colors.statusbar.progress.bg = palette["emerald"]

    # URL colors in statusbar
    c.colors.statusbar.url.error.fg = palette["red"]
    c.colors.statusbar.url.fg = palette["foreground"]
    c.colors.statusbar.url.hover.fg = palette["cyan"]
    c.colors.statusbar.url.success.http.fg = palette["aqua"]
    c.colors.statusbar.url.success.https.fg = palette["emerald"]
    c.colors.statusbar.url.warn.fg = palette["yellow"]

    c.statusbar.padding = statusbar_padding

    # === TABS ===
    # Using rust as tab bar background, aqua/cyan for accents
    c.colors.tabs.bar.bg = palette["rust"]
    
    c.colors.tabs.indicator.error = palette["red"]
    c.colors.tabs.indicator.start = palette["aqua"]
    c.colors.tabs.indicator.stop = palette["emerald"]
    c.colors.tabs.indicator.system = "rgb"

    # Regular tabs - alternating with cyan and teal
    c.colors.tabs.even.fg = palette["cyan"]
    c.colors.tabs.even.bg = palette["rust"]
    c.colors.tabs.odd.fg = palette["purple"]
    c.colors.tabs.odd.bg = palette["surface"]

    # Selected tabs - bright on dark background
    c.colors.tabs.selected.even.fg = palette["crest"]
    c.colors.tabs.selected.even.bg = palette["background"]
    c.colors.tabs.selected.odd.fg = palette["crest"]
    c.colors.tabs.selected.odd.bg = palette["background"]

    # Pinned tabs - use emerald to stand out
    c.colors.tabs.pinned.even.fg = palette["crest"]
    c.colors.tabs.pinned.even.bg = palette["foreground2"]
    c.colors.tabs.pinned.odd.fg = palette["mantle"]
    c.colors.tabs.pinned.odd.bg = palette["foreground"]

    # Pinned selected tabs
    c.colors.tabs.pinned.selected.even.fg = palette["gold"]
    c.colors.tabs.pinned.selected.even.bg = palette["foreground2"]
    c.colors.tabs.pinned.selected.odd.fg = palette["core"]
    c.colors.tabs.pinned.selected.odd.bg = palette["foreground"]
# Apply the theme
setup(c)
