###  dv.markdownTable(headers, values)

Equivalent to `dv.table()`, which renders a table with the given list of headers and 2D array of elements, but returns plain Markdown.

`// Render a simple table of book info sorted by rating. const table = dv.markdownTable(["File", "Genre", "Time Read", "Rating"], dv.pages("#book")     .sort(b => b.rating)     .map(b => [b.file.link, b.genre, b["time-read"], b.rating]))  dv.paragraph(table);`

###  dv.markdownList(values)

Equivalent to `dv.list()`, which renders a list of the given elements, but returns plain Markdown.

`const markdown = dv.markdownList([1, 2, 3]); dv.paragraph(markdown);`