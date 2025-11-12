
[#obsidian](https://publish.obsidian.md/#obsidian)

## Problem

1. it is difficult to name tag
2. tags are very atomic, there will be many tags
3. subset problem, e.g. panda css belong to css so anything that tagged with panda css should be automatically tagged with css

## Difference between Tags and Link

We can use virtual node to imitate the function of tags. But there are several difference.

- it is easier to remove tags. You global replace it with empty string.
- virtual nodes are nodes in graph view. They can gather notes in graph view. They can also pollute the graph view 💩.

## Solution

evolution of organization method

1. folder based
    1. ✅ easy
    2. ❌ cannot have file in two folders, nested and hide the notes, not cohesion in graph
2. simple tag based / virtual node (`#software-engineering/css/panda-css`) and flatten structure
    1. ✅ easy, flatten structure → not hidden, can have multiple parents at the same time, if virtual node → cohesion in graph
    2. ❌ fail to see all notes of parents (e.g. cannot see all notes of software engineering / css)
    3. this is a [Completely better alternative](https://yomaru.dev/700+Knowledge/Completely+better+alternative) than the folder based organization
3. tag based break down (`#software-engineering #css #panda-css`) and flatten structure
    1. ✅ see all notes of parents
    2. ❌ the tags are not scoped (e.g. cannot see the relationship between `#css` and `#panda-css`)
4. tag based break down (`#software-engineering/css/panda-css`,`#software-engineering/css` ,`#software-engineering` )
    1. ❌ difficult to write parent tags by yourself → this problem can be solved by [HananoshikaYomaru/obsidian-tag-generator at 1.0.4 (github.com)](https://github.com/HananoshikaYomaru/obsidian-tag-generator/tree/1.0.4)
    2. This is a completely better alternative than simple tag based

```
#software-engineering/css/panda-css 
^                         ^ 
higher level              lower level
```

if you cannot think of the lower level tag, just start from the high level first