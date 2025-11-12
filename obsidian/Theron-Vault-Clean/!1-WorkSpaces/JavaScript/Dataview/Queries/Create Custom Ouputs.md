String concatenation

You can create custom outputs with something called **string concatenation**. Basically, that means that you are adding strings - texts - and meta data together to one output, just like numbers.  
How you do this looks always the same, for example:  
`"Hello! This is file " + file.name`  
The part in `""` is a text, where you can type anything you want. Then, with a `+`, you can add to this text a meta data value, so it gets "summed up" and displayed as one value.  
You can add as many texts and variables as you want. See the examples below!

## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/How%20to%20create%20custom%20outputs%20in%20queries/#basic "Permanent link")

```js
LIST "from " + author 
FROM #type/books 
```

**With more elements**

```js
LIST "from " + author + " (Progress: " + pagesRead + "/" + totalPages + " pages)"
FROM #type/books 
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/How%20to%20create%20custom%20outputs%20in%20queries/#variants "Permanent link")

### Add formatting[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/How%20to%20create%20custom%20outputs%20in%20queries/#add-formatting "Permanent link")
```js
LIST WITHOUT ID "$" + price + " / **" + file.name + "** / " + genre + " / _" + publisher + "_"
FROM "10 Example Data/games"
```

### Usage in tables[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/How%20to%20create%20custom%20outputs%20in%20queries/#usage-in-tables "Permanent link")

```js
TABLE "Call under: " + contacts.phone AS "Phone" 
from "10 Example Data/people"
```

### Add HTML formatting[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/How%20to%20create%20custom%20outputs%20in%20queries/#add-html-formatting "Permanent link")

```js
TABLE contacts.phone + "<br>" + contacts.mail AS "Contacts", "<span style='color:red'>" + relationship + "</span>" AS "Relationship"
from "10 Example Data/people"
WHERE relationship
```