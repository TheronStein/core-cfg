async function addToNote(p_tp, p_strNoteBaseName, p_strSection, p_bAppend, p_strPrefix, p_strSuffix, p_strPrompt, p_strDefaultEntry, p_bMultiLine)
{
	// Get the note - the assumption is that it has a unique name otherwise we would need to know a precise path
	let tfNoteToUpdate;
	app.vault.getFiles().map(tfCheck => { if(tfCheck.basename == p_strNoteBaseName) tfNoteToUpdate = tfCheck; });


	// Notify and end if a note of that name has not been found
	if (!tfNoteToUpdate)
	{
		new Notice(`❌ Note Identification Error:\n${p_strNoteBaseName} not found!`);
		return;
	}


	// Read the current content of the daily note
	const CURRENT_CONTENT = await app.vault.read(tfNoteToUpdate);
	
	
	// Find the position of the section
	// Initialise to the start of the content
	let intSplitIndex = 0
	// If no section is specified, we need to accommodate this
	if(p_strSection.length == 0)
	{
		// If we are appending to the end, we'll set the split index to the end of the content
		if(p_bAppend) intSplitIndex = CURRENT_CONTENT.length;
		// If we are prepending, the default of zero will give us the start of the content
	}
	// A section is specified, so we need to find it and set the split
	else
	{
		// Check if the section marker exists, and exit with a notice if it does not
		if (CURRENT_CONTENT.indexOf(p_strSection) === -1)
		{
			new Notice(`❌ Section Identification Error:\nSection '${p_strSection}' not found in note '${p_strNoteBaseName}'.`);
			return;
		}
		
		// If we are appending, the split should be after the end of the section string
		if(p_bAppend) intSplitIndex = CURRENT_CONTENT.indexOf(p_strSection) + p_strSection.length;
		// If we are appending, the split should be at the section string
		else intSplitIndex = CURRENT_CONTENT.indexOf(p_strSection);
	}
	
	
	// Get user input
	const USER_INPUT = await p_tp.system.prompt(p_strPrompt, p_strDefaultEntry, true, p_bMultiLine);
	
	
	// Rebuild the note content
	// Start with the piece before the split
	let strContent = CURRENT_CONTENT.slice(0, intSplitIndex);
	// At the split, if we are appending we need a newline before
	if(p_bAppend) strContent = strContent + "\n" + p_strPrefix + USER_INPUT + p_strSuffix + CURRENT_CONTENT.slice(intSplitIndex);
	// At the split, if we are prepending we need a newline after
	else strContent = strContent + p_strPrefix + USER_INPUT + p_strSuffix + "\n" + CURRENT_CONTENT.slice(intSplitIndex);
	
	
	// Write updated content back to the daily note
	await app.vault.modify(tfNoteToUpdate, strContent);
	
	
	// Visual feedback on completion via a notice
	new Notice(`${p_strNoteBaseName} updated`);
	return;
}

module.exports = addToNote;
