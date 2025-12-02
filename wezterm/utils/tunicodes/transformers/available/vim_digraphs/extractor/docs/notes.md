## Implementation details

### Why there is a temporary file?

I still couldn't make vim or nvim output correctly without it.
For some reason, it refuses to output when capturing stdout directly.
However, writing to the file seems and reading back seems to do the trick.

### Column numbers magic value

The magic value of 18 was chosen according to manual
analysis of the output of the `:digraphs` command
in neovim (and vim).
It has been calculated as follows:

```
DD  ws  demo  ws  codepoint = total
────────────────────────────────────
2   ?   1~4   ?   1~10
│   │   │ │   │   │  │    get the max length of each (except whitespace)
│   │   ├─┘   │   │┌─┘
│   │   │     │   ││          ┌────┐
2 + 1 + 4   + 1 + 10        = │ 18 │
│   │   │     │   ││          └────┘
│   │   │     │   ├┘
└───│───│─────│───│────── digraph input chars
    └───│─────│───│────── whitespace
        └─────│───│────── size of visual hint demo representation
              └───│────── whitespace
                  └────── max length of possible base 10 codepoint
```
