## Directory

```js
/** 
* Ask the user to choose a target folder for the new note
* if optional fBase is provided, filter folder tree by fBase
* if optional fWhere is provided, filter by fBase at -1 = start, 1 = end, 0 = contains
**/
async function selectFolder(fBase,fWhere) {
	if ( fBase === undefined ) {
		folders = this.app.vault.getAllLoadedFiles().filter(i => i.children).map(folder => folder.path);
	} else {
		if ( (fWhere === undefined) || (fWhere === 0 ) ) {
			folders = this.app.vault.getAllLoadedFiles().filter(i => i.children).map(folder => folder.path).filter(p => p.contains(fBase));
		} else if ( fWhere === -1 ) {
			folders = this.app.vault.getAllLoadedFiles().filter(i => i.children).map(folder => folder.path).filter(p => p.startsWith(fBase));
		} else if ( fWhere === 1 ) {
			folders = this.app.vault.getAllLoadedFiles().filter(i => i.children).map(folder => folder.path).filter(p => p.endsWith(fBase));
		} else {
			throw new Error('(Syrup) selectFolder: Invalid value for "fWhere" - must be -1,0 or 1');		
		}
	}
	const folderPath = await tp.system.suggester(folders, folders, false, "Choose a folder for the new file");
	return folderPath
}
```

## FileName

```js
/** 
* Ask the user for a note name if template was not called from a "dead link".
* The function identifies whether it should asked based on the title of
* the note that triggered the workflow.
* When the name starts with 'Unitled' we assume that the workflow
* was not triggered from a link.
* Otherwise we won't ask and take the name provded by the link.
* Should the user add any invalid characters, replace them
**/
async function askFileName(){
  let fName = tp.file.title;
  //console.log("Note Name=" +fName)
  if (fName.startsWith("Untitled")) {
    fName = await tp.system.prompt("Please provide a Filename");
    // A file name cannot contain any of the 
    // following characters: * " \ / < > : | ?
    // ...replace any occurance with underscore
	if ( fName ){
		fName = fName.replace(/[^\w\s]/gi, '_');
	}
  } 
  return fName;
}
```

## Move - File to Specified Path

```js
/**
* Move file to folder selected via 'selectFolder()'
* Makes 5 attempts to add a suffix to the file name
* if a file by the same name already exists in the target folder
* Adopted from: https://github.com/SilentVoid13/Templater/discussions/625
**/
async function moveFile(path, name, times = 1) {
	if (times > 5) {
		throw new Error('(Syrup) moveFile: Too many tries')
	}
	try {
		let newName = name;
		if (times > 1) newName = `${name} (${times})`;
		await tp.file.move( path + "/" + newName);
		return newName
	} catch(err) {
		return moveFile(path, name, times +1)
	}
}
```