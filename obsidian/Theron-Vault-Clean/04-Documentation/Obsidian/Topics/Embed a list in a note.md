To embed a list from a different note, first add a [block identifier](https://help.obsidian.md/Linking+notes+and+files/Internal+links#Link to a block in a note) to your list:

```md

- list item 1
- list item 2

^my-list-id
```

Then link to the list using the block identifier:

```md
![[My note#^my-list-id]]
```

#Obsidian/Embed/List