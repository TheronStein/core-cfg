> [!Info]
> This is an extra step the creator used to define his templates.

```js
/**
* Searches the position of a "Venture" or "Catalogue" in the file path
**/
function searchStringInArray (str, strArray) {
    for (let regi=0; regi<strArray.length; regi++) {
        if (strArray[regi].match(str)) return regi;
    }
    return -1;
}

/**
* 'setClassification' prepares additional values for population
* into the template:
* root_label, root_link, parent_link and parent_label
* can be used in a template via a Templater directive.
* See template "New Note.md" for an example.
* 
* For "Ventures" set 'project' and 'workstream' from path
* For "Catalogue" entries set 'product' and 'component' from path
*
* NOTE: Depending on a global variable (newFolder) that is not passed 
* to the function is bad practice, as is setting global vars from within
* a function ( root_category, root_label, parent_category, parent_label)
**/
function setClassification() {
	root_category = root_link = root_label = parent_category = parent_link = parent_label = "";
	pElements = tp.file.path(relative = true).split("/");
	pSize = pElements.length;
	setCategories = 0;
	if ( ( typePosition = searchStringInArray( "Venture", pElements ) ) > -1  ){
		root_label = "Venture::";
		parent_label = "Workstream::";
		setCategories =1;	
	} else if ( ( typePosition = searchStringInArray( "Catalogue", pElements ) ) > -1  ){
		root_label = "Product::";
		parent_label = "Component::";
		setCategories =1;	
	}
	if ( setCategories === 1 ){
		// root_category is the folder name underneath "Venture" or "Catalogue"
		if ( ! pElements[typePosition+1].startsWith( tp.file.title )) {
			//root_link = "[[" + pElements[ typePosition + 1 ] + "]]";
			root_category = pElements[ typePosition + 1 ];
			root_link = "[[" + root_category  + "]]";
		}
		// parent_category is the folder holding the new note, unless that would be 
		// the root_category already.
		if ( (pSize -2 > typePosition +1) && ! pElements[pSize -2].startsWith( tp.file.title ) ){
			parent_category = pElements[pSize -2];
			parent_link = "[[" + parent_category  + "]]";
		}
	}
}
```