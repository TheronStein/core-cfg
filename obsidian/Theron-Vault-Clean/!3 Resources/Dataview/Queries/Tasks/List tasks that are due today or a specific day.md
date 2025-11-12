## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/List%20tasks%20that%20are%20due%20today%20or%20a%20specific%20day/#basic "Permanent link")

Usage in daily notes

When used in a daily note thats named in format `YYYY-MM-DD`, you can replace the specific date information (`date("2022-11-30")`) with `this.file.day`

```dataview
TASK 
WHERE !completed AND duedate AND duedate <= date("2022-11-30") AND contains(text, "due")
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/List%20tasks%20that%20are%20due%20today%20or%20a%20specific%20day/#variants "Permanent link")

### Show tasks that are due today or earlier[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/List%20tasks%20that%20are%20due%20today%20or%20a%20specific%20day/#show-tasks-that-are-due-today-or-earlier "Permanent link")

```dataview
TASK 
WHERE !completed AND duedate AND duedate <= date(today) AND contains(text, "due")
```