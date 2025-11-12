## Find and replace content in another file

If you want to find and replace content in another file you can use `app.vault.process()`. The callback function to replace the data in the file must be synchronous.

```
<%*
const file = tp.file.find_tfile("file name");
await app.vault.process(file, (data) => {
  return data.replace("replace me", "with me");
});
-%>
```

Alternatively, you can use `app.vault.read()` then `app.vault.modify()` to read then modify the contents of a file. This will allow you to perform asynchronous operations when doing replacements.

```
<%*
// Get contents of file
const file = tp.file.find_tfile("file name");
const content = await app.vault.read(file);
// Replace content
const newContent = content.replace("replace me", "with me");
await app.vault.modify(file, newContent);
-%>
```