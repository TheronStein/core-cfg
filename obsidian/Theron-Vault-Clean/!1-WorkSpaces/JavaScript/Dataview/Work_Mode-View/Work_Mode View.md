
```js
 TABLE 	
 status as Status,
 dateformat(file.mtime, "yyyy-MM-dd") as "Last Modified"
 
 FROM #active
 
 WHERE file.name != this.file.name
 WHERE status_category = this.work_mode
 
 SORT file.mtime desc
```
