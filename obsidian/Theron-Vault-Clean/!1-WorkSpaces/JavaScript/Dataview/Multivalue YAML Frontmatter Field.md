## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Multivalue%20YAML%20Frontmatter%20Field/#basic "Permanent link")

```dataview
TABLE wellbeing.mood, wellbeing.mood-notes
FROM "10 Example Data/dailys"
WHERE wellbeing.health > 2
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Multivalue%20YAML%20Frontmatter%20Field/#variants "Permanent link")

Add better readable table headers

```dataview
TABLE wellbeing.mood AS "Mood", wellbeing.mood-notes AS "Mood Notes"
FROM "10 Example Data/dailys"
WHERE wellbeing.health > 2
```