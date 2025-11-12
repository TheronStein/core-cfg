## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Mark%20all%20days%20in%20a%20calendar%20where%20you%20spent%20a%20certain%20amount%20of%20money/#basic "Permanent link")

```dataview
CALENDAR file.mtime
FROM "20 Dataview Queries"
FLATTEN round(sum(paid)) as SUM
WHERE paid and SUM > 75
```

bought:: Nike shoes  
paid:: 99

bought:: Delicious Cake  
paid:: 7

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Mark%20all%20days%20in%20a%20calendar%20where%20you%20spent%20a%20certain%20amount%20of%20money/#variants "Permanent link")

### When using expenses in form of "99 $"[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Mark%20all%20days%20in%20a%20calendar%20where%20you%20spent%20a%20certain%20amount%20of%20money/#when-using-expenses-in-form-of-99 "Permanent link")

^8d9d50

```
[!info]
You'll need to go back to Januray/Februrary 2022 to see the data
```

```dataview
CALENDAR file.day
FROM "10 Example Data/dailys"
FLATTEN round(sum(map(paid, (x) => number(regexreplace(x, " ?\$", ""))))) as SUM
WHERE paid and SUM > 75
```

```
[!tip]
When you try to write complex calendar queries, write a TABLE query first to make sure your query returns the results you're expecting.
```

```dataview
TABLE paid, SUM
FROM "10 Example Data/dailys"
FLATTEN round(sum(map(paid, (x) => number(regexreplace(x, "\$", ""))))) as SUM
WHERE paid and SUM > 75
```