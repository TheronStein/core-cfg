# FAQ

## Why that name?

This tool allows you to _Type UNICODE Strings_ faster.

## Why did you create this?

- I was tired of switching to an emoji picker many times.
- I was missing vim digraphs in non-vim terminal apps.
- I memorized some of my favorite Unicode codepoints.
- I missed Perl's `\u{hexcodepoint}` in other environments.
- I wanted quick access to my Greek symbols.
- I wanted to explore [APL][apl_lang], but the unique characters posed a significant roadblock.
- I wanted to type long sequences of Vim digraphs **faster than** Vim's built-in digraph input.

## Why should I use Vim digraphs?

For many chars, digraphs are sequences that are far more memorable
than just the plain codepoints, when an emoji label isn't available.

## Why no separators for digraphs?

Digraphs already have a character length limit of two,
so a separator is redundant. Also, it will create
conflicts with existing digraphs. As the cherry on top:
they're called **di**graphs.

## What are those weird equations with ❤️s?

[This][xkcd_55].

## Why didn't you invest more effort in the aesthetics of this?

Because it LGTM for now.

## Why there is no LICENSE?

I'm still thinking about the choice of license.

[xkcd_55]: https://xkcd.com/55/
[apl_lang]: https://aplwiki.com/
