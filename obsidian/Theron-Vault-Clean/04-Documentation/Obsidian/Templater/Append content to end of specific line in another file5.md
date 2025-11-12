## Append content in another file

If you want to append content in another file you can use `app.vault.process()`. The callback function to replace the data in the file must be synchronous.

```
<%*
const file = tp.file.find_tfile("file name");
await app.vault.process(file, (data) => {
  // Append content (use \n for line break)
  return data + "\nContent you want to append";
});
_%>
```

Alternatively, you can use `app.vault.read()` then `app.vault.modify()` to read then modify the contents of a file. This will allow you to perform asynchronous operations when doing replacements.

```
<%*
// Get contents of file you want to edit
const file = tp.file.find_tfile("file name");
const content = await app.vault.read(file);
// Append content (use \n for line break)
const newContent = content + "\nContent you want to append";
// Update file you want to edit
await app.vault.modify(file, newContent);
_%>
```

## Append content to end of specific line in another file

If you want to append content to the end of a specific line in another file you can use `app.vault.process()`. The callback function to replace the data in the file must be synchronous.

```
<%*
const lineNumber = 3;

const file = tp.file.find_tfile("file name");
await app.vault.process(file, (data) => {
  // Split content into lines
  const lines = data.split("\n");
  // Append content to end of specific line
  lines[lineNumber] += "Content you want to append;
  // Join lines back together
  return lines.join("\n");
});
_%>
```

Alternatively, you can use `app.vault.read()` then `app.vault.modify()` to read then modify the contents of a file. This will allow you to perform asynchronous operations when doing replacements.

```
<%*
const lineNumber = 3;

// Get contents of file you want to edit
const file = tp.file.find_tfile("file name");
const content = await app.vault.read(file);
// Split content into lines
const lines = content.split("\n");
// Append content to end of specific line
lines[lineNumber] += "Content you want to append";
// Join lines back together
const newContent = lines.join("\n");
// Update file you want to edit
await app.vault.modify(file, newContent);
_%>
```

## Copy content between headers at cursor

You can place your cursor in a section, run this script, and have everything between the heading before and the heading after copied to your clipboard.

```
<%*
const { line: cursorLine } = app.workspace.activeEditor.editor.getCursor();
const currentTFile = tp.file.find_tfile(tp.file.path(true));
const { headings, sections } = app.metadataCache.getFileCache(currentTFile);
let headingAboveSection;
let cursorSection;
let headingBelowSection;
for (const index in sections) {
  const section = sections[index];
  if (!cursorSection) {
    if (section.type === "heading") {
      headingAboveSection = section;
    }
    const { line: startLine } = section.position.start;
    const { line: endLine } = section.position.end;
    if (startLine <= cursorLine && cursorLine <= endLine) {
      cursorSection = section;
    }
  } else if (section.type === "heading") {
    headingBelowSection = section;
    break;
  }
}
const { line: startLine } = headingAboveSection.position.start;
const endLine = headingBelowSection?.position.start.line ?? editor.lastLine();
const sectionContent = tp.file.content.split("\n").slice(startLine, endLine).join("\n");
window.navigator.clipboard.writeText(sectionContent);
-%>
```

## Using Templater functions outside of Templater

You can use many of the Templater functions either in other plugins or in the developer tools console (`CMD Shift I`).

Here’s an example of using `tp.system.prompt`.

```
// Get "system" module
const systemModule = app.plugins.getPlugin('templater-obsidian').templater.functions_generator.internal_functions.modules_array.find(x => x.name === "system").static_object;

const value = await systemModule.prompt("What genre would you like to choose?");
```

And an example of using `tp.date.now`.

```
// Get "date" module
const dateModule = app.plugins.getPlugin('templater-obsidian').templater.functions_generator.internal_functions.modules_array.find(x => x.name === "date").static_object;

const now = dateModule.now("YYYY-MM-DD");
```

## HTML in Notice

You can have HTML in a Notice (in app notification) by appending HTML elements to `notice.noticeEl`.

```
<%*
const notice = new Notice();
notice.noticeEl.append(
  createEl("strong", { text: "Success" }),
  " script created 3 files",
);
-%>
```

If you need to set the duration of the Notice and have HTML, you can use an empty string for the base Notice text and still append HTML to it.

```
<%*
const notice = new Notice("", 5000);
notice.noticeEl.append(
  createEl("strong", { text: "Success" }),
  " script created 3 files",
);
-%>
```