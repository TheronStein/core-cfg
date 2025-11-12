---
pageid: 5
---

Imagine you have the following text:

```
apple
banana
cherry
```

### **Step 1: Record a Macro**

1. Move to the first line (`apple`).
    
2. Start recording with:
    
    ```
    qa
    ```
    
3. Type:
    
    - `A` (to append)
        
    - `- fruit` (add text)
        
    - `<Esc>` (exit insert mode)
        
    - `j` (move down)
        
4. Stop recording with:
    
    ```
    q
    ```
    

### **Step 2: Apply the Macro**

Run it on the next two lines using:

```
@a
```

or repeat on multiple lines:

```
2@a
```

Now, the text looks like:

```
apple - fruit
banana - fruit
cherry - fruit
```

---