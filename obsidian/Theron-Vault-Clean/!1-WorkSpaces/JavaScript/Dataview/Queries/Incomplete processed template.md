## Query Pages with unmaintained tags[¶](https://s-blu.github.io/obsidian_dataview_example_vault/00%20Meta/maintenance/Unprocessed%20template/#query-pages-with-unmaintained-tags "Permanent link")

```dataview
LIST
FROM "20 Dataview Queries"
WHERE econtains(file.etags, "#dv/")
```

## Query Pages with the ToDo callout[¶](https://s-blu.github.io/obsidian_dataview_example_vault/00%20Meta/maintenance/Unprocessed%20template/#query-pages-with-the-todo-callout "Permanent link")

```dataview
LIST
FROM "20 Dataview Queries"
WHERE contains(file.tasks.text, "Use this template")
```