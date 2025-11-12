```js
<%*
/** 
* Central note creation workflow to my PPKM for use with Templater-plugin ***
* Author: Syrup
* Version: 0.94
* Date: 16/06/2024
**/

// ### CHANGELOG
// Version: 0.94 - fname: Replace invalid characters with '_'; Attempt to enhance comments in prep for dissemination
// Version: 0.93 - Refactored "if-else spaghetti" for template action into a switch statement
// Version: 0.92 - Introduced graceful handling of user cancellation (Note 6:)
// - configuration option mTimer: sets the duration for notification messages
// - configuration option deleteOnCancel: if 'true', will delete the original note when the workflow is cancelled. 
// - function deleteNote: Will delete the note taking into account the Obsidian setting for note deletion & 'deleteOnCancel'.
// - Wrapped call to 'selectTemplate' into a try-catch and added a notification (e.g. when user aborts)
// - Added test for tp.file.title (and newFolder where applicable) & execute 'deleteNote' where the test fails
// Version: v0.91 - comments updated
// 11/07/23 Syrup: Added entity 'Circle' (contact groups/teams)
// 27/10 Syrup: Introduced root_link & parent_link
// 21/10 Syrup: Refactored 'setClassification()', 'selectFolder()' to remove dependency on folder level - "Ventures" and "Meetings" folders can be multiple now and do not need to live in the vault root, so to have separate ones for e.g. 'work' and 'personal'
// Version: v0.6
// 05/10/22 Syrup: Turned labels into fields (e.g. "Venture:" -> "Venture::")
// 27/09/22 Syrup: 
// - Fixed bugs in 'setClassification' with an uncaught 'undefined'
// - Extended 'selectFolder' with the ability to optionally consume a folder constraint
// - Implemented 'Workstream' and 'Component' --->
// NOTE: Set up to have Workstreams & Components in their own folders! Decide if you want that!
// 23/09/22 Syrup: First working version of the template
//
// ### NOTES
// ~~Note 1: Meetings - I need to find a solution for multiple meetings with the same name. I could add the meeting date to the title, but creation from a "dead" link would require to manipulate that source link~~
// ~~Note 2: Ventures, Products and their children need to be created via Quick Add for now. For the former due to the folder I create via Quick Add, the latter because I have to yet identify a way to limit 'selectFolder' to the "Ventures" or "Product" folder~~
// ~~Note 3: Find a way to prepopulate notes and meetings with the 'Venture', 'Workstream', 'Product', 'Component' if the user chooses one of these as target folder~~
// ~~Note 4: Workstreams & Components are not folders at the moment - but they where in my initial concept. Decide what to do and implement as needed. All tools are in the armory now.~~
// Note 5: this.app.vault.getAllLoadedFiles().filter(i => i.children).map(folder => folder.path).filter(p => p.includes('Catalogue/')) filters folder structure by "Catalogue"
// ~~Note 6: TODO: Workflow cancellation by the user not handled - leads to folders/files named 'null' or 'Untitled'.~~
// Note 7: Not catching the case yet, when the user enters invalid characters for a note name.











// ------------ Entry point ... -------------------------------------------------------



/**
* 2. Decide what to do based on the template selected by the user
* Based on the template name ...
* - selectFolder: Prompts user to select a Folder
* - askFilename: Prompts user for a note name if the workflow was called from an 'Untitled' note
* - massage file name where applicable (i.e. for "Meeting")
* - moveFile: Move the note to its destination
* - setClassification: Set additional variables for consumption by the template where applicable
* - assign main template to var 'output'
* 
* Should the flow fail, i.e. because the user has cancelled out of the flow
* call 'deleteNote' to remove the source note - if 'deleteOnCancel' is 'true'

/** 
* 3. Write template to the destination note
**/
tR +=`${output}` 
%>
```