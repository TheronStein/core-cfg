# Qutebrowser Configuration
# Documentation: https://qutebrowser.org/doc/help/settings.html

import os
from qutebrowser.api import interceptor

# ============================================================================
# BASIC SETTINGS
# ============================================================================

# Start page and default page
c.url.start_pages = ["https://github.com"]
c.url.default_page = "https://github.com"

# Search engines - use :open <shortcut> <query>
c.url.searchengines = {
    "DEFAULT": "https://google.com/search?q={}",
    "ddg": "https://duckduckgo.com/?q={}",
    "g": "https://google.com/search?q={}",
    "gh": "https://github.com/search?q={}",
    "r": "https://reddit.com/search?q={}"   "w": "https://en.wikipedia.org/wiki/{}",
    "yt": "https://youtube.com/results?search_query={}",
    "aw": "https://wiki.archlinux.org/?search={}",
}

# Downloads
c.downloads.location.directory = "~/Downloads"
c.downloads.location.prompt = True
c.downloads.remove_finished = 10000  # Remove after 10 seconds

# ============================================================================
# APPEARANCE
# ============================================================================

# Font settings
c.fonts.default_family = ["JetBrains Mono", "DejaVu Sans Mono", "monospace"]
c.fonts.default_size = "11pt"
c.fonts.web.family.standard = "Liberation Sans"
c.fonts.web.family.fixed = "JetBrains Mono"
c.fonts.web.size.default = 16

# Tab appearance
c.tabs.position = "top"  # top, bottom, left, right
c.tabs.width = "15%"
c.tabs.indicator.width = 3
c.tabs.favicons.show = "always"  # always, never, pinned
c.tabs.last_close = "close"  # close, blank, startpage, default-page
c.tabs.new_position.unrelated = "next"  # prev, next, first, last
c.tabs.title.format = "{audio}{index}: {current_title}"
c.tabs.title.format_pinned = "{index}"

# Status bar
c.statusbar.show = "always"  # always, never, in-mode
c.statusbar.widgets = ["keypress", "url", "scroll", "history", "tabs", "progress"]

# Scrollbar
c.scrolling.bar = "always"  # always, never, when-searching, overlay
c.scrolling.smooth = True

# ============================================================================
# BEHAVIOR
# ============================================================================

# General
c.auto_save.session = True
c.backend = "webengine"  # webengine or webkit
c.confirm_quit = ["downloads"]  # always, multiple-tabs, downloads, never

# Content settings
c.content.javascript.enabled = True
c.content.images = True
c.content.cookies.accept = "all"  # all, no-3rdparty, no-unknown-3rdparty, never
c.content.autoplay = False  # Don't autoplay videos
c.content.notifications.enabled = True  # Ask for notification permission
c.content.geolocation = "ask"  # Allow websites to request location
c.content.media.audio_capture = "ask"
c.content.media.video_capture = "ask"
c.content.media.audio_video_capture = "ask"

# Privacy
c.content.webrtc_ip_handling_policy = "default-public-interface-only"
c.content.cookies.store = True
c.content.blocking.enabled = True
c.content.blocking.method = "both"  # adblock and hosts

# Hints
c.hints.mode = "letter"  # letter, number, word
c.hints.chars = "asdfghjkl"
c.hints.min_chars = 1
c.hints.uppercase = False

# Input
c.input.insert_mode.auto_load = True
c.input.insert_mode.leave_on_load = True

# Tabs
c.tabs.background = True  # Open new tabs in background
c.tabs.select_on_remove = "next"  # prev, next, last-used

# Session
c.session.lazy_restore = True

# ============================================================================
# COLORS - Dracula Theme (Easy to customize)
# ============================================================================

# Background colors
bg = "#282a36"
bg_light = "#44475a"
bg_lighter = "#6272a4"

# Foreground colors
fg = "#f8f8f2"
fg_dark = "#6272a4"

# Accent colors
cyan = "#8be9fd"
green = "#50fa7b"
orange = "#ffb86c"
pink = "#ff79c6"
purple = "#bd93f9"
red = "#ff5555"
yellow = "#f1fa8c"

# Completion widget
c.colors.completion.category.bg = bg_light
c.colors.completion.category.fg = cyan
c.colors.completion.category.border.top = bg_light
c.colors.completion.category.border.bottom = bg_light
c.colors.completion.even.bg = bg
c.colors.completion.odd.bg = bg_light
c.colors.completion.fg = fg
c.colors.completion.item.selected.bg = purple
c.colors.completion.item.selected.fg = bg
c.colors.completion.item.selected.border.top = purple
c.colors.completion.item.selected.border.bottom = purple
c.colors.completion.match.fg = green

# Downloads
c.colors.downloads.bar.bg = bg
c.colors.downloads.error.bg = red
c.colors.downloads.error.fg = bg
c.colors.downloads.start.bg = bg
c.colors.downloads.start.fg = cyan
c.colors.downloads.stop.bg = bg
c.colors.downloads.stop.fg = green

# Hints
c.colors.hints.bg = yellow
c.colors.hints.fg = bg
c.colors.hints.match.fg = green

# Messages
c.colors.messages.error.bg = red
c.colors.messages.error.fg = bg
c.colors.messages.info.bg = bg_light
c.colors.messages.info.fg = fg
c.colors.messages.warning.bg = orange
c.colors.messages.warning.fg = bg

# Prompts
c.colors.prompts.bg = bg
c.colors.prompts.fg = fg
c.colors.prompts.selected.bg = purple
c.colors.prompts.selected.fg = bg

# Status bar
c.colors.statusbar.normal.bg = bg
c.colors.statusbar.normal.fg = fg
c.colors.statusbar.command.bg = bg
c.colors.statusbar.command.fg = fg
c.colors.statusbar.insert.bg = green
c.colors.statusbar.insert.fg = bg
c.colors.statusbar.passthrough.bg = cyan
c.colors.statusbar.passthrough.fg = bg
c.colors.statusbar.url.fg = fg
c.colors.statusbar.url.hover.fg = cyan
c.colors.statusbar.url.success.http.fg = green
c.colors.statusbar.url.success.https.fg = green
c.colors.statusbar.url.warn.fg = yellow

# Tabs
c.colors.tabs.bar.bg = bg
c.colors.tabs.even.bg = bg
c.colors.tabs.even.fg = fg
c.colors.tabs.odd.bg = bg_light
c.colors.tabs.odd.fg = fg
c.colors.tabs.selected.even.bg = purple
c.colors.tabs.selected.even.fg = bg
c.colors.tabs.selected.odd.bg = purple
c.colors.tabs.selected.odd.fg = bg
c.colors.tabs.indicator.error = red
c.colors.tabs.indicator.start = cyan
c.colors.tabs.indicator.stop = green

# Webpage colors (dark mode)
c.colors.webpage.preferred_color_scheme = "dark"
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.images = "never"

# ============================================================================
# KEY BINDINGS
# ============================================================================

# Unbind defaults you don't want
config.unbind("d", mode="normal")  # Don't close tab with 'd'
config.unbind("<Ctrl-q>", mode="normal")  # Don't quit with Ctrl-Q

# Custom bindings
config.bind("x", "tab-close")
config.bind("X", "undo")
config.bind("J", "tab-prev")
config.bind("K", "tab-next")
config.bind("<Ctrl-l>", "set-cmd-text :open ")
config.bind("<Ctrl-Shift-l>", "set-cmd-text :open -t ")
config.bind(",m", "spawn mpv {url}")
config.bind(",M", "hint links spawn mpv {hint-url}")
config.bind(";i", "hint images download")
config.bind("gd", "download-open")
config.bind("gD", "download-clear")

# Vim-style navigation
config.bind("h", "scroll left")
config.bind("j", "scroll down")
config.bind("k", "scroll up")
config.bind("l", "scroll right")
config.bind("gg", "scroll-to-perc 0")
config.bind("G", "scroll-to-perc")

# Quick marks for frequent sites
config.bind("gc", "open -t https://claude.ai")
config.bind("gg", "open -t https://github.com")
config.bind("gr", "open -t https://reddit.com")
config.bind("gy", "open -t https://youtube.com")

# ============================================================================
# PER-DOMAIN SETTINGS
# ============================================================================

# Allow JavaScript for specific sites only (if you want to disable it globally)
# config.set('content.javascript.enabled', True, 'github.com')
# config.set('content.javascript.enabled', True, 'claude.ai')

# Site-specific user agent strings
# config.set('content.headers.user_agent',
#            'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0',
#            'https://web.whatsapp.com/')

# ============================================================================
# ADVANCED FEATURES
# ============================================================================

# Ad blocking - uses built-in host blocker and Brave's adblock
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters-2020.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters-2021.txt",
]

c.content.blocking.hosts.lists = [
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
]

# Load autoconfig.yml (GUI settings)
config.load_autoconfig(False)

# ============================================================================
# USERSCRIPTS
# ============================================================================

# Create userscripts directory: ~/.local/share/qutebrowser/userscripts/
# Add executable scripts there for custom functionality

# Example: Password manager integration
config.bind("<z><l>", "spawn --userscript qute-pass")
config.bind("<z><u>", "spawn --userscript qute-pass --username-only")
config.bind("<z><p>", "spawn --userscript qute-pass --password-only")

# ============================================================================
# BROWSER PROFILES (for your multi-browser setup)
# ============================================================================

# Get browser instance from environment or args
import sys

browser_instance = os.environ.get("QT_WAYLAND_APP_ID", "default")

# Per-instance customization
if browser_instance == "l_browser":
    c.window.title_format = "[L] {perc}{current_title}{title_sep}qutebrowser"
    c.colors.tabs.selected.even.bg = cyan
    c.colors.tabs.selected.odd.bg = cyan
    c.url.start_pages = ["https://claude.ai"]

elif browser_instance == "hub_browser":
    c.window.title_format = "[HUB] {perc}{current_title}{title_sep}qutebrowser"
    c.colors.tabs.selected.even.bg = green
    c.colors.tabs.selected.odd.bg = green
    c.url.start_pages = ["https://github.com"]

elif browser_instance == "r_browser":
    c.window.title_format = "[R] {perc}{current_title}{title_sep}qutebrowser"
    c.colors.tabs.selected.even.bg = orange
    c.colors.tabs.selected.odd.bg = orange
    c.url.start_pages = ["https://reddit.com"]

elif browser_instance == "top_browser":
    c.window.title_format = "[TOP] {perc}{current_title}{title_sep}qutebrowser"
    c.colors.tabs.selected.even.bg = pink
    c.colors.tabs.selected.odd.bg = pink
    c.url.start_pages = ["https://news.ycombinator.com"]
