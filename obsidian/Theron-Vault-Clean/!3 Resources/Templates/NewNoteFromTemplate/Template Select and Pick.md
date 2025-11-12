## Prompt - Which template from Specified Array

```js
/**
* What the script does:
* 1. Asks the user to select a template
* 2. Decide what to do based on the template selected by the user
* 3. Write the selected template to the new note
**/

// Var output will be used to include the main template
var output;

// Store the TFile instance of the note that triggered this flow
// in case we are asked to delete the note.
const myTFile = tp.file.find_tfile(tp.file.title);

/** 
* 1.Ask the user to select a template
**/
try {
	fTemplate = await selectTemplate();
} catch(err){
	//console.log("Error captured:" +err);
	new tp.obsidian.Notice(err,mTimer);
	await deleteNote(myTFile,deleteOnCancel);
	return;
}
```

## Switch Case to Select Specific Template

```js
**/
let templateApplied = false;
switch( fTemplate ){
	case "Note":
		newFolder = await selectFolder();
		tp.file.title = await askFileName();
		//console.log(newFolder, tp.file.title);
		if( newFolder && tp.file.title) {
			tp.file.title = await moveFile(`${newFolder}`,`${tp.file.title}`);
			await setClassification();
			output = await tp.file.include("[[New Note]]");
			templateApplied = true;
		}
		break;
	case "Meeting":
		newFolder = await selectFolder();
		tp.file.title = await askFileName();
		if( newFolder && tp.file.title) {	
			fDate = tp.date.now("YYMMDD")
			tp.file.title = await moveFile(`${newFolder}`, `${fDate}` + " - " + `${tp.file.title}`);
			await setClassification();
			output = await tp.file.include("[[meeting_general]]");
			templateApplied = true;
		}
		break;
	case "Contact":
		tp.file.title = await askFileName();
		if( tp.file.title ) {
			await tp.file.move("/Actors/" + tp.file.title);
			output = await tp.file.include("[[New Person]]");
			templateApplied = true;
		}
		break;
	case "Organisation":
		tp.file.title = await askFileName();
		if( tp.file.title ) {
			await tp.file.move("/Actors/" + tp.file.title);
			output = await tp.file.include("[[New Organisation]]");	
			templateApplied = true;
		}
		break;
	case  "Circle":
		tp.file.title = await askFileName();
		if( tp.file.title ) {
			await tp.file.move("/Actors/" + tp.file.title);
			output = await tp.file.include("[[New Circle]]");	
			templateApplied = true;
		}
		break;
	case "Venture":
			// per my own definition Ventures and Products are created as files
			// under a folder of the same name (.i.e. /Ventures/My Big Project/My Big Project.md)
		newFolder = await selectFolder("Ventures", 1);
		tp.file.title = await askFileName();
		if( newFolder && tp.file.title) {	
			await tp.file.move(`${newFolder}` + "/" + tp.file.title + "/" + tp.file.title);
			output = await tp.file.include("[[New Venture]]");
			templateApplied = true;
		}
		break;
	case "Product":
			// per my own definition Ventures and Products are created as files
			// under a folder of the same name (.i.e. /Ventures/My Big Project/My Big Project.md)
		tp.file.title = await askFileName();
		if( tp.file.title ) {	
			await tp.file.move("/Catalogue/" + tp.file.title + "/" + tp.file.title);
			output = await tp.file.include("[[zzSystem/Templates/Templater/New Product]]");
			templateApplied = true;
		}
		break;
	case "Workstream":
			// per my definition Workstreams and Components are created as files
			// under a folder of the same name
		newFolder = await selectFolder("Ventures/");
		tp.file.title = await askFileName();
		if( newFolder && tp.file.title) {	
			await tp.file.move(`${newFolder}` + "/" + `${tp.file.title}` + "/" + `${tp.file.title}`);
			await setClassification();
			output = await tp.file.include("[[New Workstream]]");
			templateApplied = true;
		}
		break;
	case "Component":
			// per my definition Workstreams and Components are created as files
			// under a folder of the same name
		newFolder = await selectFolder("Catalogue/");
		tp.file.title = await askFileName();
		if( newFolder && tp.file.title) {	
			await tp.file.move(`${newFolder}` + "/" + `${tp.file.title}` + "/" + `${tp.file.title}`);
			await setClassification();
			output = await tp.file.include("[[New Component]]");
			templateApplied = true;
		}
		break;					
	default:
		// There is no default. Landing here points to a misconfiguration
		// console.log("Invalid template selection in Note Creation Dialog. Misconfiguration!");
		templateApplied = false;
}
if( !templateApplied ){
	new tp.obsidian.Notice("No template applied.\nDid you cancel the workflow?", mTimer);
	await deleteNote(myTFile,deleteOnCancel);
	return;
}
```