### `dv.fileLink(path, [embed?], [display-name])`

Converts a textual path into a Dataview `Link` object; you can optionally also specify if the link is embedded as well as it's display name.

`dv.fileLink("2021-08-08") => link to file named "2021-08-08" dv.fileLink("book/The Raisin", true) => embed link to "The Raisin" dv.fileLink("Test", false, "Test File") => link to file "Test" with display name "Tes`

### `dv.sectionLink(path, section, [embed?], [display?])`

Converts a textual path + section name into a Dataview `Link` object; you can optionally also specify if the link is embedded and it's display name.

`dv.sectionLink("Index", "Books") => [[Index#Books]] dv.sectionLink("Index", "Books", false, "My Books") => [[Index#Books|My Books]]`

### `dv.blockLink(path, blockId, [embed?], [display?])`

Converts a textual path + block ID into a Dataview `Link` object; you can optionally also specify if the link is embedded and it's display name.

`dv.blockLink("Notes", "12gdhjg3") => [[Index#^12gdhjg3]]`