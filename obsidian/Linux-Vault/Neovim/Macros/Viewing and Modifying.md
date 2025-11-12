---
pageid: 1
---

To check what was recorded in a register, type:

```
:registers a
```

This will display the contents of register `a`.

If you want to see **all** registers:

```
:registers
```

---

Since macros are stored in registers, you can edit them. To do so:

1. Open the command mode:
    
    ```
    :let @a = 'your commands here'
    ```
    
    Example:
    
    ```
    :let @a = "IHello world<Esc>"
    ```
    
    (This would insert "Hello world" when `@a` is run.)
    