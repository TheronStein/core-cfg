---
pageid: 2
---

To execute the macro you recorded in register `a`, press:

```
@a
```

If you want to repeat it multiple times, use:

```
3@a
```

(This will execute the macro three times.)

If you just ran `@a` and want to repeat the last macro again:

```
@@
```

This repeats the last executed macro.

---

## Multiple Lines

This applies the macro stored in register `a` to lines **2 through 5**.

```
:2,5normal @a
```

Alternatively, in **visual mode**:

1. Select multiple lines with `V` and move up/down.
    
2. Press `:`
    
3. Type:
    
    ```
    normal @a
    ```
    
4. Press **Enter** to apply the macro to all selected lines.

## Until the End of a File

To apply the macro from the current line to the end of the file:

```
:.,$normal @a
```

or simply:

```
:normal @a
```