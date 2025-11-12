### `dv.execute(source)`

Execute an arbitrary dataview query and embed the view into the current page.

`dv.execute("LIST FROM #tag"); dv.execute("TABLE field1, field2 FROM #thing");`

### `dv.executeJs(source)`

Execute an arbitrary DataviewJS query and embed the view into the current page.

`dv.executeJs("dv.list([1, 2, 3])");`