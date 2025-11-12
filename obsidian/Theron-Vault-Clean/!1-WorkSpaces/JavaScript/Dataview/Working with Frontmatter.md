## Numbers & Logic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#numbers-logic "Permanent link")

```dataview
TABLE WITHOUT ID EmptyValue, Bool, Numeric, StringNumeric
FROM ""
WHERE file.name = this.file.name
```

---

## Strings[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#strings "Permanent link")

#### Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#basic "Permanent link")

```dataview
TABLE WITHOUT ID StringWithQuotes as "String in Quotes", StringNoQuotes as "String no Quotes", StringEscapting as "String Escaping", StringHTML as "String with HTML"
FROM ""
WHERE file.name = this.file.name
```

#### Multiline[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#multiline "Permanent link")

```dataview
TABLE WITHOUT ID StringMultiline, StringMultiWithBreaks
FROM ""
WHERE file.name = this.file.name
```

Tips for Working with Strings

Traps for Working with Strings

---

## Links[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#links "Permanent link")

```dataview
TABLE WITHOUT ID Link, Link.file.cday
FROM ""
WHERE file.name = this.file.name
```

---

## Dates[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#dates "Permanent link")

```dataview
TABLE WITHOUT ID Date, DateTime, Duration, Date + Duration as "Date + Duration", dateformat(Date, "yyyy-MM") as "Formatted Date"
FROM ""
WHERE file.name = this.file.name
```

---

## Arrays[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#arrays "Permanent link")

```dataview
TABLE WITHOUT ID FlatArray, BulletArray
FROM ""
WHERE file.name = this.file.name
```

- If field is an array (like in your case), then contains is looking for an _element_ that matches exactly. So if you had `field:: [[abc]], [[def]], a` then it would match. If field is a string (an array of characters)... it would still be looking for an _element_ it's just that in that case elements are individual characters. A simple way around it would be to do `=contains(join(this.field), "a")` which turns the array into a string, and then does a character search for any a's.

---

## Objects[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#objects "Permanent link")

#### Basics[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#basics "Permanent link")

```dataview
TABLE WITHOUT ID KeyedObject, NestedObject
FROM ""
WHERE file.name = this.file.name
```

#### Looking inside[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#looking-inside "Permanent link")

```dataview
TABLE WITHOUT ID KeyedObject.name, NestedObject[0].color, "<div style='background-color:#" + NestedObject[0].color + ";'> </div>" as  "HTML Color"
FROM ""
WHERE file.name = this.file.name
```

#### Flattening objects[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Frontmatter%20Overview/#flattening-objects "Permanent link")

```dataview
TABLE WITHOUT ID NObjects.name, NObjects.color, "<div style='background-color:#" + NObjects.color + ";'> </div>" as  "HTML Color"
FROM ""
WHERE file.name = this.file.name
FLATTEN NestedObject as NObjects
```