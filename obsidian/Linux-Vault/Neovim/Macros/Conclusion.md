---
pageid: 4
---

Summary of Macro Commands

|Command|Description|
|---|---|
|`qa`|Start recording a macro in register `a`|
|`q`|Stop recording the macro|
|`@a`|Play back macro stored in `a`|
|`@@`|Replay the last used macro|
|`3@a`|Play macro `a` three times|
|`:registers a`|View contents of register `a`|
|`:let @a = 'commands'`|Edit macro contents manually|
|`:g/pattern/normal @a`|Apply macro only to lines with a pattern|
|`:.,$normal @a`|Apply macro to all lines from current to end|

## Conclusion

- Macros are **temporary** unless you save them in your `vimrc/init.lua`.
    
- Use registers like `a-z` to store different macros.
    
- Running macros on multiple lines is **powerful** for automating repetitive tasks.
    