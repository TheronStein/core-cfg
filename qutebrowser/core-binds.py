# Quick marks for frequent sites
# config.bind("gc", "open -t https://candy.ai")
# config.bind("gpp", "open -t https://pornpics.com")
# Quick marks for frequent sites
# Unbind defaults that conflict with ijkl navigation
config.unbind("i")  # default: enter-mode insert
config.unbind("u")  # default: enter-mode insert
config.unbind("j")  # default: scroll down
config.unbind("k")  # default: scroll up
config.unbind("h")  # default: scroll left (if you want to reclaim it)
config.unbind("J")  # default: tab-next
config.unbind("K")  # default: tab-prev
config.unbind("H")  # default: back
config.unbind("L")  # default: forward
config.unbind("d")  # default: forward
config.unbind("ad")  # default: forward
config.unbind("pp")  # default: forward
config.unbind("pP")  # default: forward
config.unbind("<Ctrl+q>")  # default: forward

# Unbind g-prefixed defaults you're overwriting
config.unbind("gg")  # you rebind this
config.unbind("gd")  # default: download
config.unbind("gf")  # default: view-source
config.unbind("gm")  # default: tab-move
config.unbind("go")  # default: open current url
config.unbind("gO")  # default: open current url in tab

# Caret mode unbinds
# config.unbind("i", mode="caret")
config.unbind("j", mode="caret")
config.unbind("k", mode="caret")
config.unbind("h", mode="caret")
config.unbind("J", mode="caret")
config.unbind("L", mode="caret")
config.unbind("H", mode="caret")
config.unbind('y', mode='caret')

# # Vim-style navigation
# config.bind("h", "scroll left")
# config.bind("j", "scroll down")
# config.bind("k", "scroll up")
# config.bind("l", "scroll right")
# config.bind("gg", "scroll-to-perc 0")
# config.bind("G", "scroll-to-perc")
config.bind("gqh", "open -t qute://help")
config.bind("gyt", "open -t https://youtube.com")

config.bind("gal", "open -t https://archlinux.org")
config.bind("gw", "open -t https://wezterm.org")
config.bind("ghy", "open -t https://hypr.land")

# GIT
config.bind("gth", "open -t https://github.com")
config.bind("gtl", "open -t https://gitlab.chaoscore.org")

# AI
# https://github.com/sxyazi/yazi
# https://github.com/AnirudhG07/awesome-yazi
config.bind("gax", "open -t https://grok.com")
config.bind("gc", "open -t https://claude.ai")
config.bind("gpt", "open -t https://chat.openai.com")

config.bind("do", "download-open")     # open downloads
config.bind("dc", "download-clear")    # clear downloads
config.bind("dC", "download-cancel")     # open downloads
#s Normal mode scrolling
config.bind("a", "mode-enter insert")  # Enter insert mode with 'a' (append)
config.bind('p', 'mode-enter passthrough')
config.bind('<Ctrl-q>', 'mode-leave', mode='passthrough')
# config.bind('<Ctrl-c>', 'mode-leave', mode='passthrough')
config.bind("i", "scroll up")
config.bind("k", "scroll down")
config.bind("hs", "cmd-set-text -s :set ")  # quick settings
config.bind("o", "cmd-set-text -s :open")
config.bind("O", "cmd-set-text -s :open -t")
config.bind("go", "cmd-set-text :open {url:pretty}")
config.bind("gO", "cmd-set-text :open -t {url:pretty}")
config.bind("k", "move-to-next-line", mode="caret")
config.bind("i", "move-to-prev-line", mode="caret")
config.bind("j", "move-to-prev-char", mode="caret")
config.bind("l", "move-to-next-char", mode="caret")

# Word movement (optional, adjust to taste)
config.bind("J", "move-to-prev-word", mode="caret")
config.bind("t", "cmd-set-text -s :open -t")

# Command mode completion navigation
config.bind("<Ctrl-k>", "completion-item-focus next", mode="command")
config.bind("<Ctrl-i>", "completion-item-focus prev", mode="command")

config.bind("gg", "scroll-to-perc 0")
config.bind("G", "scroll-to-perc")
# K and I are used for tab navigation, so using Alt+k/i for half-page scrolling
config.bind("<Ctrl+k>", "scroll-page 0 0.5")
config.bind("<Ctrl+i>", "scroll-page 0 -0.5")
config.bind("hh", "history")           # open history
config.bind("hb", "bookmark-list")     # open bookmarks
config.bind("hs", "cmd-set-text -s :set ")  # quick settings
config.bind("o", "cmd-set-text -s :open")
config.bind("O", "cmd-set-text -s :open -t")
config.bind("/", "cmd-set-text /")
config.bind("?", "cmd-set-text ?")

config.bind("f", "hint")
config.bind("<Alt-F>", "hint links tab-bg")  # Open in background tab
config.bind("F", "hint links tab")    # Open in foreground tab (switch to it)
config.bind("yf", "hint links yank")
config.bind(";y", "hint links yank-primary")

config.bind("t", "cmd-set-text -s :open -t")
# config.bind("T", "tab-clone")
# config.bind("x", "tab-close")
config.bind("<Ctrl+u>", "undo")
# config.bind("J", "tab-next")
# config.bind("K", "tab-prev")
# config.bind("gt", "tab-focus")
# config.bind("gT", "tab-move -")
# config.bind("g^", "tab-focus 1")
# config.bind("g$", "tab-focus -1")
config.bind("B", "cmd-set-text -s :bookmark-load")
config.bind("<Alt+B>", "cmd-set-text -s :bookmark-load -t")
config.bind("<Ctrl+backspace>", "back")
config.bind("<Ctrl+[>", "back")
config.bind("<Ctrl+]>", "forward")
config.bind("r", "reload")
config.bind("R", "reload -f")

config.bind("/", "cmd-set-text /")
config.bind("?", "cmd-set-text ?")
config.bind("n", "search-next")
config.bind("N", "search-prev")

config.bind("yy", "yank")
config.bind(":", "cmd-set-text :")
config.bind("!", "cmd-set-text -s :spawn")
## Markdown yank bindings# Enter caret mode, select text, then yank as markdown
config.bind('ym', 'mode-enter caret ;; hint links userscript yank-markdown selection')

# config.bind('yM', 'spawn --userscript yank-markdown selection', mode='caret')
config.bind('yy', 'yank selection', mode='caret')  # Keep normal yank on yy
# Or bind in caret mode directly
# config.bind('y', 'yank selection ;; spawn --userscript yank-markdown selection', mode='caret')
config.bind("Pc", "open -- {clipboard}")
config.bind("PC", "open -t -- {clipboard}")
config.bind("Pp", "open -t -- {primary}")

config.bind("m", "quickmark-save")
config.bind("'", "quickmark-load")
config.bind("b", "bookmark-add")
config.bind("B", "cmd-set-text -s :bookmark-load")
config.bind("<Alt+B>", "cmd-set-text -s :bookmark-load -t")

config.bind("zi", "zoom-in")
config.bind("zo", "zoom-out")
config.bind("z0", "zoom")
config.bind("<Ctrl+=>", "zoom-in")
config.bind("<Ctrl+->", "zoom-out")
config.bind("<Ctrl+Shift+l>", "cmd-set-text -s :open")
config.bind("<Ctrl+Shift+k>", "cmd-set-text -s :open -t")
config.bind("gi", "hint inputs")
config.bind("<Ctrl+f>", "cmd-set-text /")
config.bind("gm", "tab-mute")

config.bind(":", "cmd-set-text :")
config.bind("!", "cmd-set-text -s :spawn")

config.bind("<Escape>", "clear-keychain ;; search ;; fullscreen --leave")
config.bind("<Ctrl+c>", "stop")
config.bind("<Ctrl+r>", "config-source")
config.bind("<Ctrl+Shift+Q>", "quit")

config.bind("<Alt+f>", "fullscreen")
# config.bind("", "fullscreen")
config.bind("<F5>", "reload")
config.bind("<Ctrl+0>", "zoom")

config.bind("<Ctrl+t>", "open -t")
config.bind("<Ctrl+w>", "tab-close")
config.bind("<Ctrl+Shift+u>", "undo")
config.bind("<Ctrl+e>", "tab-next")
config.bind("<Ctrl+q>", "tab-prev")

# Hint mode navigation - Ctrl+Tab to go backwards through hint selections
# config.bind("<Ctrl+Tab>", "hint-follow-previous", mode="hint")
config.bind("<Ctrl+Shift+l>", "cmd-set-text -s :open")
config.bind("<Ctrl+Shift+k>", "cmd-set-text -s :open -t")

config.bind("<Ctrl+f>", "cmd-set-text /")
# config.bind("<Ctrl+g>", "search-next")
## Toggle Picture-in-Picture with ,p
# config.bind('<Ctrl+p>', 'jseval -q (function(){var v=document.querySelector("video");if(v){v.requestPictureInPicture();}})();')
# config.bind(',p', 'jseval -q (function(){var v=document.querySelector("video");if(v){v.requestPictureInPicture();}})();')
# config.bind(',p', 'jseval -q document.getElementsByTagName("video")[0].requestPictureInPicture();')
config.bind(',p', 'spawn mpv {url}')
config.bind(',h', 'hint links spawn mpv {hint-url}')
config.bind(',P', 'spawn mpv --title=pip-video {url}')
# config.bind(',p', 'jseval document.querySelector("video").requestPictureInPicture()') 
config.bind("<Ctrl+Shift+g>", "search-prev")
config.bind("<Ctrl+y>", "yank")
config.bind("<Ctrl+p>", "open -- {clipboard}")
config.bind("<Ctrl+v>", "open -- {clipboard}")
config.bind("<Ctrl+Shift+v>", "open -t -- {clipboard}")
# Fix Ctrl+a for select all in insert mode
config.bind("<Ctrl+a>", "fake-key <Ctrl+a>", mode="insert")
# Open current URL in another browser for passkey/WebAuthn authentication
# (QtWebEngine has incomplete WebAuthn support)
config.bind("gxb", "spawn brave-nightly {url}")
config.bind("gxw", "spawn waterfox {url}")
