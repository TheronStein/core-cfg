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

# Dark mode for websites (prefer dark color schemes)
c.colors.webpage.preferred_color_scheme = "dark"
c.colors.webpage.darkmode.enabled = True

# Session
c.session.lazy_restore = True


# Tab appearance
c.tabs.background = True  # Open new tabs in background
c.tabs.select_on_remove = "next"  # prev, next, last-used
c.tabs.position = "left"  # top, bottom, left, right
c.tabs.width = "15%"
c.tabs.indicator.width = 3
c.tabs.favicons.scale = 1
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

# Fonts - larger for better visibility

# Font settings
c.fonts.default_family = ["JetBrains Mono", "DejaVu Sans Mono", "monospace"]
c.fonts.web.family.standard = "Liberation Sans"
c.fonts.web.family.fixed = "JetBrains Mono"
c.fonts.web.size.default = 18
c.fonts.default_size = "18pt"
c.fonts.statusbar = "18pt monospace"
c.fonts.tabs.selected = "18pt monospace"
c.fonts.tabs.unselected = "16pt monospace"
c.fonts.completion.entry = "18pt monospace"
c.fonts.hints = "bold 18pt monospace"
