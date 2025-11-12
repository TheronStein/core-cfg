### Conditionally update a frontmatter value using MetaEdit.

Say you have a frontmatter key `status` and you want to setup a button that will progress the value from one status to the next.

```
<%*
const file = tp.file.find_tfile(tp.file.title);
const {update} = app.plugins.plugins["metaedit"].api;
const status = tp.frontmatter.status;

if (status === "In Progress") {
 await update("status","Complete",file);
}
if (status === "Backlog") {
await update("status", "In Progress", file);
}
-%>
```


### Create a new note for every link in a file

Say you've got a note and it has a bunch of links, but none of those links resolve to created notes yet. This snippet will create all those files.

```
const currentFile = tp.file.find_tfile(tp.file.title)
const links = app.metadataCache.getFileCache(currentFile)?.links
if (links) {
   links.forEach(link => { 
       await tp.file.create_new("", link.name)
    })
}
```

### Get inline meta from within a note

This snippet creates an object `dataview` that contains key/value pairs of any inline meta within the note it is run. For example if you had a meta value `foo:: bar`, `dataview.foo` would equal `bar`

```
<%*
const content = tp.file.content.split("\n")
const dataview = content.filter(line => line.match(/\w+\:\: \w+$/)).reduce((acc, line) => {
    const [key, value] = line.split(":: ")
    acc[key] = value
    return acc
}, {})
%>
```

### Load a selected template from a suggester

Show a suggester with different template options. Load in the selected template from the suggester. Check out that switch statement!

```
<%*
const choice = await tp.system.suggester(["Simple Note", "Book", "Music", "MOC"], ["Simple Note", "Book", "Music", "MOC"]);
let output = ""
switch(choice) {
	case "Book":
		output = await tp.file.include("[[-Book]]")
		break;
	case "Music":
		output = await tp.file.include("[[-Music]]")
		break
	case "MOC":
		output = await tp.file.include("[[-MOC]]")
		break;
	default:
		new Notice("No Matching Template")
}
   
tR += output
%>
```

### Add/edit metadata in all notes inside a folder

**note: only works with folders in vault root. It won't find a nested folder. Requires MetaEdit plug.**  
Select a folder from a suggester, enter a key and value using a prompt and this will iterate over every note in the folder and update the specified meta key.

```
<%*
const {update} = app.plugins.plugins["metaedit"].api
const root = app.vault.getRoot()
const folders = root.children.filter(child => child.children)
const selectedFolder = await tp.system.suggester(e => e.name, folders, false, "Choose a Folder")
const metaKey = await tp.system.prompt("What Meta Key?")
const metaValue = await tp.system.prompt("Meta Value")
if (selectedFolder.children) {
selectedFolder.children.forEach(async (child) => {
    const {frontmatter} = app.metadataCache.getCache(child.path)
	const content = await app.vault.read(child)
	if (frontmatter) {
		if (Object.keys(frontmatter).includes(metaKey)) {
			update(metaKey, metaValue, child)
		} else {
			const contentArray = content.split("\n")
			contentArray.splice(1, 0, `${metaKey}: ${metaValue}`)
			await app.vault.modify(child, contentArray.join("\n"))
		}
	} else {
		const updatedContent = `---\n${metaKey}: ${metaValue}\n---`.concat(content)
		await app.vault.modify(child, updatedContent)
	}
})
} else {
new Notice("No Notes in Selected Folder")
}
%>
```

## Contents from another note

Here's how to grab the contents from another note and bring it forward into the current note.

```
<%*
const file = tp.file.find_tfile("Note Title")
const content = await app.vault.read(file)
// do something with the content
const output = content.substring(0, 10)
tR += output
%>
```

Broken down:

1. We get the [TFile](https://shbgm.ca/TFile) of the note that has content we want to pull in. A [TFile](https://shbgm.ca/TFile) is an object that contains a bunch of information about a note. It is used all over Obsidian to get information about a given file.
2. We use the obsidian api to read the contents of the note. This returns a string of all the note's contents
3. Do something with the string. I'm just slicing off a random substring, but you can get fancy like turn the string into an array and iterate over each line: `content.split("\n").forEach(line => new Notice(line))`
4. To output our value from a JS command block you use `tR +=`. In this case I'm outputting my random substring.

You can use the TFile approach to get other stuff from a note. For example, say I wanted to access the frontmatter in the metadata:

```
let output = ""
const file = tp.file.find_tfile("Note Title")
const cache = tp.metadataCache.getFileCache(file)
if (cache) {
  const frontmatter = cache.frontmatter
  output = frontmatter.someKey
}
tR += output
```

You use these commands by putting them in their own Template Note inside your templater folder. You can call them by running the insert template command or inside a button:

```button
name Grab That Cheese
type append template
action Grab That Cheese Template Note
```