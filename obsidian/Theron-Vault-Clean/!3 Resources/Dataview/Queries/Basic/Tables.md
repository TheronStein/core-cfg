## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Table%20Queries/#basic "Permanent link")

**Show pages from a folder as table**

```dataview
TABLE
FROM "10 Example Data/games"
```

**Show pages from a tag as table**

```dataview
TABLE
FROM #type/books 
```

**Combine multiple tags**

```dataview
TABLE
FROM #dvjs/el OR #dv/min 
```

**Combine multiple folders**

```dataview
TABLE
FROM "10 Example Data/books" OR "10 Example Data/games"
```

**Combine tags and folders**

```dataview
TABLE
FROM "10 Example Data/games" AND #genre/action  
```

**List all pages**

Add `dataview` to code block

The output of this is pretty long. If you want to see it, add `dataview` to the code block - like on the examples above!  
Please note: There needs to be a **space** behind `TABLE` to see results!

```
TABLE 
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Table%20Queries/#variants "Permanent link")

### Show pages from a certain author[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Table%20Queries/#show-pages-from-a-certain-author "Permanent link")

```dataview
TABLE
FROM #type/books 
WHERE author = "Conrad C"
```

### Show pages and additional information[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Table%20Queries/#show-pages-and-additional-information "Permanent link")

```dataview
TABLE author, pagesRead, totalPages
FROM #type/books
```

### Show only meta data information and no file link[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Table%20Queries/#show-only-meta-data-information-and-no-file-link "Permanent link")

```dataview
TABLE WITHOUT ID source, time, ingredients
FROM "10 Example Data/food"
WHERE source
```

### Group list elements[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Table%20Queries/#group-list-elements "Permanent link")

![What is#^new-id-after-grouping](https://s-blu.github.io/obsidian_dataview_example_vault/00%20Meta/Vault%20Infos/What%20is/#new-id-after-grouping)

**Without additional columns**

```dataview
TABLE 
FROM "10 Example Data/books"
GROUP BY author
```

**With additional columns**

```dataview
TABLE rows.file.link, rows.pagesRead
FROM "10 Example Data/books"
GROUP BY author
```

### Customize table headers[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Table%20Queries/#customize-table-headers "Permanent link")

**Of additional columns**

```dataview
TABLE contacts.phone AS "Phone Number", contacts.mail AS "E-Mail"
from "10 Example Data/people"
```

**Of the first (link/group) header without grouping**

```dataview
TABLE WITHOUT ID file.link AS "Game", developer, price
FROM "10 Example Data/games"
```

**Of the first (link/group) header with grouping**

```dataview
TABLE WITHOUT ID key AS "Author", rows.file.link AS "Books"
FROM "10 Example Data/books"
GROUP BY author
```

### Sort tables[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Basic%20Table%20Queries/#sort-tables "Permanent link")

```dataview
TABLE author
FROM "10 Example Data/books"
SORT author
```