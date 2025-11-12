#JavaScript
#References/Coding

```js
const filesToDelete = []; const pages = 



dv.pages().where(p => p.file.name.includes("Index")); for (let page of pages) { filesToDelete.push(page.file.path); } for (let filePath of filesToDelete) { await tp.file.delete(filePath);
```

```js
app.workspace.on('layout-ready', () => {
	.nav-folder-title[Data-Path^="!"].classList.add("navdir-Vault");
	.nav-folder-title[Data-Path^="0"].classList.add("navdir-Default");
	.nav-folder-title[Data-Path^="X"].classList.add("navdir-Personal");
	.nav-folder-title[Data-Path^="X"].classList.add("navdir-Mounts");										
});

app.workspace.on('active-leaf-change', () => {

    displayProfilePictures();  // Run the function when switching between notes

});
```

