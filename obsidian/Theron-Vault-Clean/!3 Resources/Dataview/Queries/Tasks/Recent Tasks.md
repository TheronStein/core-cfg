# Get latest open tasks[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Get%20latest%20open%20tasks/#get-latest-open-tasks "Permanent link")

Difference between status and completed

A task only counts as completed if its status is equals to "x". If you use custom task statuses, i.e. "-", a task will appear checked but is _not_ completed.

## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Get%20latest%20open%20tasks/#basic "Permanent link")

```dataview
TASK
FROM "10 Example Data/dailys"
WHERE !completed
SORT file.day DESC
LIMIT 10
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Get%20latest%20open%20tasks/#variants "Permanent link")

If using custom statuses for TASKS, it's maybe better to check for `status = " "` instead of `!completed`, depending on your use case

```dataview
TASK
FROM "10 Example Data/dailys"
WHERE status = " "
SORT file.day DESC
LIMIT 10
	```