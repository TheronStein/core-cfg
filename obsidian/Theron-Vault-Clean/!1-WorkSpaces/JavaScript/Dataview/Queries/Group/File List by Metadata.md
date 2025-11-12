Tip

After using a GROUP BY statement, results will be inside an object that looks like:  
- {key: groupName; rows: ArrayOfDataColumns}

> This means to refer to things in your TABLE/LIST after grouping, you should either use `key`, or `rows.fieldName` to access them.

## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Group%20list%20of%20files%20by%20metadata/#basic "Permanent link")

List of files grouped by creation date:

```dataview
LIST rows.file.link
FROM "10 Example Data/books"
GROUP BY file.cday
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Group%20list%20of%20files%20by%20metadata/#variants "Permanent link")

### Join grouped values into a string rather than a list[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Group%20list%20of%20files%20by%20metadata/#join-grouped-values-into-a-string-rather-than-a-list "Permanent link")

```dataview
LIST join(rows.file.link, " | ")
FROM "10 Example Data/books"
GROUP BY file.cday
```

### Create a custom field using Flatten[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Group%20list%20of%20files%20by%20metadata/#create-a-custom-field-using-flatten "Permanent link")

After grouping, it's usually only possible to display a single set of value under each group heading. In order to display something more complex, `FLATTEN` can be used to create a custom value that remains available after the `GROUP BY`.

```dataview
LIST rows.customValue
FROM "10 Example Data/books"
FLATTEN file.link + " (" + author + ")" AS customValue
GROUP BY "**" + file.cday + "**"
```