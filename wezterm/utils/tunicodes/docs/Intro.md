# Introduction

Make sure you completed the install instructions.

## Via emoji labels

They behave in a way similar to discord and slack emojis:

- `:purple_heart:` outputs `💜`

Stack many of them by plain concatenation:

- `:purple_heart::purple_heart:` outputs `💜💜`

## Via codepoints

Insert **single** characters by wrapping sequences in `\{` and `}`, like so:

- `\u{1f49c}` outputs `💜`

Insert **multiple** characters between `\u{` and `}`,
ensuring that you separate them properly with at least
one comma and/or space between each codepoint.

- `\u{1f49c 1f49c}` outputs `💜💜`

## Via Vim digraphs

Insert **single** characters using `\d` followed
by the two chars for the digraph mapping.

- `\d00` outputs `∞`

Insert **multiple** digraph sequences by
wrapping them between `\d{` and `}`, **without** separators
like so:

- `\d{a*(Ub**Xg*}` outputs `α∩β×γ`
- `\d{FAa*(-b*}` outputs `∀α∈β`

Even if you input only one digraph, you can also wrap with `{}` for readability:

- `e^(i\d{p*}) = -1` outputs `e^(iπ) = -1`
- `e^(i\dp*) = -1` also outputs `e^(iπ) = -1`

**Fun fact:** If you're inserting a high number of consecutive
digraphs in a row, this method allows inserting them
**faster than** Vim's native digraph input! How cool is _that_!

**Remember:**

- Digraphs are **case-sensitive**. ⚠️
- Do **NOT** use separators of any kind between the digraphs.
- You can view a [list of digraphs][vim_digraphs_list] by opening your Vim (or Neovim) and running `:help digraphs-table`.

[vim_digraphs_list]: https://vimhelp.org/digraph.txt.html

## Via class names

Added support for class names.

The input method is similar to codepoints, but, but with class names instead of regular names.

Currently, you will need to install a [special font][nerd_fonts_home] to view these glyphs.

- `\C{nf-seti-javascript}` outputs `` (js logo)
- `\C{nf-seti-ruby}` outputs `` (ruby logo)
- `\C{nf-seti-lua}` outputs `` (lua logo)

You'll need to use a [cheatsheet of glyphs][nerd_fonts_cheat_sheet]
for the first lookup, by memorizing the class names, displayed right below each logo.

[nerd_fonts_home]: https://nerdfonts.com/
[nerd_fonts_cheat_sheet]: https://nerdfonts.com/cheat-sheet

## Joining it all together

For quick input, you can mix the sequences mentioned above
intermingled with regular text,
so that you don't need to call the binding multiple times.

Aaaaaaand **That's all folks!** Go enjoy your buffed up Terminal!
