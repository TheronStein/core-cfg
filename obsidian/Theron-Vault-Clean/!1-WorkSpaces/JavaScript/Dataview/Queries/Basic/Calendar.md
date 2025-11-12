**Query from a folder**

```dataview
CALENDAR file.day
FROM "10 Example Data/dailys"
```

**Query from a tag**

```dataview
CALENDAR file.day
FROM #daily 
```

**Query from a tag/folder combination**

```dataview
CALENDAR file.day
FROM "10 Example Data/dailys" OR #journal 
```

**Query for all pages, everywhere**

Query for "all"

Unlike other Query Types, Calendar **always** need the datefield information. The most minimalistic Query for a Calendar looks like `CALENDAR <datefield>` - but then _all_ of your files need to have a valid date inside this specific field!

```dataview
CALENDAR file.ctime 
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Calendar%20Queries/#variants "Permanent link")

### Make sure the date information is available[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Calendar%20Queries/#make-sure-the-date-information-is-available "Permanent link")

```dataview
CALENDAR due
FROM "10 Example Data/assignments"
WHERE due
```

Advanced usage

Do you want to see more advanced examples? Head over to the [Query Type Overview](https://s-blu.github.io/obsidian_dataview_example_vault/30%20Dataview%20Resources/31%20Query%20Overviews/Queries%20by%20Type/#calendar) to see all available CALENDAR queries in the vault!