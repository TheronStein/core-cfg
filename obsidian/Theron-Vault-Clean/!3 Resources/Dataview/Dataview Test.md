```js
const FolderPath = '"/08 Databases/Theron-Database/Users"'
dv.list(dv.pages(FolderPath)
.where(page => !page.file.name.includes("W")))

dv.pages('"08 Databases/Theron-Database/Users"').map(p => p.user_id)
```