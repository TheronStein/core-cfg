## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Show%20two%20meta%20data%20fields%20in%20same%20table%20column/#basic "Permanent link")

```dataview
TABLE wake-up, [go-to-sleep, gotosleep] as "Bed time", [lunch, dinner] AS "Meal times"
from "10 Example Data/dailys"
where date(day).weekyear = 3
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Show%20two%20meta%20data%20fields%20in%20same%20table%20column/#variants "Permanent link")

In case you only have one valid value per file for this column that is stored in different meta data fields, use filter and flatten:

```dataview
TABLE wake-up, ST AS "Bed time", [lunch, dinner] AS "Meal times"
from "10 Example Data/dailys"
where date(day).weekyear = 3
FLATTEN filter([gotosleep, go-to-sleep], (x) => x) as ST
```