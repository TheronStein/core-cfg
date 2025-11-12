Below are as high level of the current code (quite dirty as i have not yet cleaned it, my apologies!) - the current code wraps the 'update' function only in an 'async/await' wrapper.  
I hope that this is clear enough!  
Thanks for your help on this.

**frontmatter display function**

```
const {globalFunc} = customJS;
let {items} = input;
let ing = [];
let j = 0;

if (!Boolean(items)) {
	return "⚠️ <b>Warning</b>\nThe frontmatter field is empty!\n<b>The list cannot be printed.</b>"
}

for (let i = 0; i < items.length; i++) {
	let name = items[i].replace(items[i].split(" ")[0] + " " + items[i].split(" ")[1]+ " " + items[i].split(" ")[2], "");
	let unit = items[i].split(" ")[2];
	let amount = items[i].split(" ")[1];
	let emoji = items[i].split(" ")[0];

	if (amount > 0) {
		ing[j] = emoji + " " + amount + " " + unit + " <b>" + name + "</b>"
		j++
	}
}

if (ing.length == 0) {
	return dv.el('p', "✌️ Nothing to do")
}

dv.el('div', globalFunc.BuildList(ing, "\n"))

```

**Corresponding dv.view**

```
dv.view("/path/to/items", { items: dv.current().datagroup1 })
```

**Reset function**  
which sits within a customJS class.

```
resetList(args) {
		const {
			that,
			app,
			dv,
			theme,
			listOfIt,
    } = args;
		
    const { createButton } = app.plugins.plugins["buttons"]
const updateSct = listOfIt
		const btnStr = this.getBtnName(theme, updateSct)
			
			dv.el('div',
				createButton({
					app,
					el: that.container,
					args: { name: btnStr, color: 'blue' },
					clickOverride: { click: this.getEditApi(), params: [updateSct, this.processItems(this.getPoint(dv.page("pagename.md"), updateSct), false), dv.page("pagename.md").file.path]}
				}),
			)

  }
	
	async getEditApi() {
		const { update } = app.plugins.plugins["metaedit"].api
		return await update
	}
```

**Corresponding dv.view**

```
const {customClass} = customJS
customClass.resetList({app: app, dv: dv, that:this, theme: "to0", listOfIt: "datagroup1" }) 
```

0 replies