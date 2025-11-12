## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Style%20dataview%20table%20columns/#basic "Permanent link")

```dataview
TABLE 
    publisher,
    developer,
    "<span style='display:flex; justify-content: right;'>" + price + "</span>" AS Price
FROM "10 Example Data/games"
```

Other style possibilities

For bold, italic, highlighted or strikethrough text, see the first variant.  
**Underscore text**: `<span style='text-decoration: underline;'>`  
**Right alignment**: `<span style='display:flex; justify-content: right;'>`  
**Center alignment**: `<span style='display:flex; justify-content: center;'>`  
**Make text uppercase**: `<span style='text-transform: uppercase;'>`  
**Text color**: `<span style='color: red;'>`

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Style%20dataview%20table%20columns/#variants "Permanent link")

### Use bold, italic or highlight text styles[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Style%20dataview%20table%20columns/#use-bold-italic-or-highlight-text-styles "Permanent link")

Available styles

You can use every style [Obsidian has available](https://help.obsidian.md/How+to/Format+your+notes) this way.

```dataview
TABLE 
    "_" + publisher + "_" AS Publisher,
    "**" + developer + "**" AS Developer,
    "==" + price + "==" AS Price
FROM "10 Example Data/games"
```

### Style multiple columns[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Style%20dataview%20table%20columns/#style-multiple-columns "Permanent link")

```dataview
TABLE styleStart + author + styleEnd AS Author, 
    genres, 
    styleStart + totalPages + styleEnd AS "Total Pages"
FROM "10 Example Data/books"
FLATTEN "<span style='display:flex; justify-content: center;'>" AS styleStart
FLATTEN "</span>" AS styleEnd
```

### Use different styles[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Style%20dataview%20table%20columns/#use-different-styles "Permanent link")

```dataview
TABLE greenStyle + author + styleEnd AS Author, 
    genres, 
    rightAlignStyle + totalPages + styleEnd AS "Total Pages"
FROM "10 Example Data/books"
FLATTEN "<span style='color: lightgreen;'>" AS greenStyle
FLATTEN "<span style='display:flex; justify-content: right;'>" AS rightAlignStyle
FLATTEN "</span>" AS styleEnd
```

### Style page link[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Style%20dataview%20table%20columns/#style-page-link "Permanent link")

```dataview
TABLE WITHOUT ID styleStart + file.link + styleEnd AS "Book", 
    author,
    totalPages
FROM "10 Example Data/books"
FLATTEN "<span style='text-transform: uppercase;'>" AS styleStart
FLATTEN "</span>" AS styleEnd
```