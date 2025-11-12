tmux allows the colour and attribute of text to be configured with a simple syntax, this is known as the style. There are two places styles appear:

- In options, such as `status-style`.
    
- Enclosed in `#[]` in an option value, this is called an embedded style (see the next section).
    

A style has a number of terms separated by spaces or commas, the most useful are:

- `default` uses the default colour; this must appear on its own. The default colour is often set by another option, for example for embedded styles in the `status-left` option, it is `status-style`.
    
- `bg` sets the background colour. The colour is also given, for example `bg=red`.
    
- `fg` sets the foreground colour. Like `bg`, the colour is given: `fg=green`.
    
- `bright` or `bold`, `underscore`, `reverse`, `italics` set the attributes. These appear alone, such as: `bright,reverse`.
    

Colours may be one of `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white` for the standard terminal colours; `brightred`, `brightyellow` and so on for the bright variants; `colour0` to `colour255` for the colours from the 256-colour palette; `default` for the default colour; or a hexadecimal RGB colour such as `#882244`.

The remaining style terms are described [in the manual page](https://man.openbsd.org/tmux#STYLES).

For example, to set the status line background to blue using the `status-style` option:

```
set -g status-style 'bg=blue'
```