# Tunicodes

Quickly insert emojis and other Unicode® characters
via their codepoints, emoji `:label:`s, vim digraphs
on any command-line interface.

This is an unofficial plugin for WezTerm.

## Usage

Open your WezTerm terminal, and activate Tunicodes input with with your binding.
Type or paste one of the examples, then press RETURN.
Feel free to modify the examples to suit your needs.
A more detailed intro is also [available here][alt_intro].

| Output                                                               | Input |
|----------------------------------------------------------------------|-------|
| 💜 or 💜                                                             | `\u{1f49c} or :purple_heart:` |
| 🚀 or 🚀                                                             | `\u{1f680} or :rocket:` |
| ⏰🚗⚡                                                               | `\u{23f0 1f697 26a1}` |
| 🎹🎵🎶                                                               | `:musical_keyboard::musical_note::notes:` |
| 💎🤲🦍📈                                                             | `\u{1f48e 1f932 1f98d 1f4c8}` |
| 🍕➕🍍🟰🤔                                                           | `:pizza::heavy_plus_sign::pineapple::heavy_equals_sign::thinking_face:` |
| 🔴➡️⬛                                                                | `:red_circle::arrow_right::black_large_square:` |
| The 🌐 is a Σ of ┏━┛s                                                | `The \u{1f310} is a \dS* of \d{DRHHUL}s` |
| 🧽🦑🍍🗿⭐🪨🐚🦀🐟🪸🌊                                               | `:sponge::squid::pineapple::moyai::star::rock::shell:\u{1fabc}:crab::fish::coral::ocean:` |
| `(λ 𝑓 [x] (* x x))`                                                  | `(\dl* \u{1d453} [x] (* x x))` |
| √❤️=? cos❤️=? d/dx❤️=?                                                  | `\dRT:heart:=? cos:heart:=? d/dx:heart:=?` |
| F{❤️} = (1/2)π∫(-∞ ∞)𝑓(t)e^(it❤️)dt=?                                  | `F{:heart:} = (1/2)\d{p*In}(-\d{00SP00})\u{1d453}(t)e^(it:heart:)dt=?` |

[alt_intro]: ./docs/Intro.md

## Installation

### Download plugin

You need to have [WezTerm][wezterm_home] installed.

In Linux/\*BSD/Mac:

```sh
plugins_dir="$HOME/.config/wezterm/plugins"
mkdir -p "$plugins_dir"
git clone https://gitlab.com/lilaqua/tunicodes "$plugins_dir/tunicodes"
```

### Enable binding

Assign a [keybinding][wezterm_keybindings] of your
preference in your [WezTerm config file][wezterm_cfg_file].
In this example, I'll use `CTRL+SHIFT+R`.

```lua
local wezterm = require 'wezterm'
local cfg = wezterm.config_builder()
local tunicodes = require 'plugins/tunicodes'

--------- ... -------

cfg.keys = {
  ------- ... -------
  { action = tunicodes.DefaultAction, key = 'r', mods = 'CTRL|SHIFT' },
  ------- ... -------
}
```

[wezterm_home]: https://wezfurlong.org/wezterm
[wezterm_keybindings]: https://wezfurlong.org/wezterm/config/keys.html
[wezterm_cfg_file]: https://wezfurlong.org/wezterm/config/files.html#configuration-files

## Further Information

For more details, check out the [FAQ][project_faq].

[project_faq]: ./docs/FAQ.md

## Notice

Unicode® is a registered trademark of the Unicode Consortium.
This project is not affiliated with or endorsed by the Unicode Consortium.
