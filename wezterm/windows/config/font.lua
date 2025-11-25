
return { 


-- Font
  font_size = 14.0,
  font = wezterm.font_with_fallback({
    "Input Mono Nerd Font",
    "Iosevka Nerd Font"
    "JetBrains Mono NL",
    "FiraCode Nerd Font",
    "Hack Nerd Font",
    "DejaVu Sans Mono Nerd Font",
    "MesloLGS Nerd Font Mono",
    "FiraCode Nerd Font Mono",
    "Symbols Nerd Font",
    "PowerlineSymbols",
    "Noto Sans Mono",
    "Noto Sans Symbols",
    "Noto Sans Symbols2",
    "monospace",
  })
  harfbuzz_features = {"liga=0", "calt=0"}  -- Disables ligatures
}
