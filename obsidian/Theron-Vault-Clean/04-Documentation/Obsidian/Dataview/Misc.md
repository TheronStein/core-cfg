## Utility

### `dv.array(value)`

Convert a given value or array into a Dataview [data array](https://blacksmithgu.github.io/obsidian-dataview/api/data-array). If the value is already a data array, returns it unchanged.

`dv.array([1, 2, 3]) => dataview data array [1, 2, 3]`

### `dv.isArray(value)`

Returns true if the given value is an array or dataview array.

`dv.isArray(dv.array([1, 2, 3])) => true dv.isArray([1, 2, 3]) => true dv.isArray({ x: 1 }) => false`

### `dv.table(headers, elements)`

Renders a dataview table. `headers` is an array of column headers. `elements` is an array of rows. Each row is itself an array of columns. Inside a row, every column which is an array will be rendered with bullet points.

`dv.table(     ["Col1", "Col2", "Col3"],         [             ["Row1", "Dummy", "Dummy"],             ["Row2",                  ["Bullet1",                  "Bullet2",                  "Bullet3"],              "Dummy"],             ["Row3", "Dummy", "Dummy"]         ]     );`

An example of how to render a simple table of book info sorted by rating.

`dv.table(["File", "Genre", "Time Read", "Rating"], dv.pages("#book")     .sort(b => b.rating)     .map(b => [b.file.link, b.genre, b["time-read"], b.rating]))`