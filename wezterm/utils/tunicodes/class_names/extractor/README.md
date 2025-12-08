# Extractor for Nerd Font Glyphs

## Procedure (manual)

I performed these steps with Firefox:

- Visit the [nerd fonts cheatsheet site][nf_cheatsheet].
- Open developer tools.
- In the REPL run `console.log(glyphs)`.
- Right click the _Object {_ and use the option `Copy Object`.
- Create `glyphs.json` in this directoy, paste in file.
- Make sure Ruby is installed.
- Run `./extractor`

[nf_cheatsheet]: https://nerdfonts.com/cheat-sheet
