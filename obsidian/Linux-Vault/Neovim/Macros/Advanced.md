---
pageid: 3
---

## Search Matches

---
if you're already at the beginning of the range.

You can apply a macro only to lines matching a pattern:

```
:g/pattern/normal @a
```

For example, if you want to run `@a` on all lines containing "error":

```
:g/error/normal @a
```

---

## Loops

If you want to **repeat a macro on each line**, go to the first line and use:

```
:while line('.') <= line('$') | normal @a | execute "normal j" | endwhile
```

This runs `@a` on every line until the end of the file.