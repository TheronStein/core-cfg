```
[!info]
You'll need to go back to Januray/Februrary 2022 to see the data.
```

## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Mark%20days%20that%20have%20unfinished%20todos/#basic "Permanent link")

```dataview
CALENDAR file.day
FROM "10 Example Data/dailys"
FLATTEN all(map(file.tasks, (x) => x.completed)) AS "allCompleted"
WHERE !allCompleted
```

```
[!tip]
When you try to write complex calendar queries, write a TABLE query first to make sure your query returns the results you're expecting.
```

```dataview
TABLE file.day, allCompleted
FROM "10 Example Data/dailys"
FLATTEN all(map(file.tasks, (x) => x.completed)) AS "allCompleted"
WHERE allCompleted
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Mark%20days%20that%20have%20unfinished%20todos/#variants "Permanent link")

### If you use custom task status and want to see all without a status[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Mark%20days%20that%20have%20unfinished%20todos/#if-you-use-custom-task-status-and-want-to-see-all-without-a-status "Permanent link")

```dataview
CALENDAR file.day
FROM "10 Example Data/dailys"
FLATTEN any(map(file.tasks, (x) => x.status = " ")) AS "anyEmpty"
WHERE anyEmpty
```