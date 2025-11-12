### `dv.current()`

Get page information (via `dv.page()`) for the page the script is currently executing on.

### `dv.pages(source)`

Take a single string argument, `source`, which is the same form as a [query language source](https://blacksmithgu.github.io/obsidian-dataview/reference/sources). Return a [data array](https://blacksmithgu.github.io/obsidian-dataview/api/data-array) of page objects, which are plain objects with all of the page fields as values.

`dv.pages() => all pages in your vault dv.pages("#books") => all pages with tag 'books' dv.pages('"folder"') => all pages from folder "folder" dv.pages("#yes or -#no") => all pages with tag #yes, or which DON'T have tag #no dv.pages('"folder" or #tag') => all pages with tag #tag, or from folder "folder"`

Note that folders need to be double-quoted inside the string (i.e., `dv.pages("folder")` does not work, but `dv.pages('"folder"')` does) - this is to exactly match how sources are written in the query language.

### `dv.pagePaths(source)`

As with `dv.pages`, but just returns a [data array](https://blacksmithgu.github.io/obsidian-dataview/api/data-array) of paths of pages that match the given source.

`dv.pagePaths("#books") => the paths of pages with tag 'books'`

### `dv.page(path)`

Map a simple path or link to the full page object, which includes all of the pages fields. Automatically does link resolution, and will figure out the extension automatically if not present.

`dv.page("Index") => The page object for /Index dv.page("books/The Raisin.md") => The page object for /books/The Raisin.md`