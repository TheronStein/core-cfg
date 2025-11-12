
```js
let iconSpace = document.querySelectAll(".sidebar-toggle-button.mod-right");

iconSpace.

itemDiv.innerHTML =`
<div 
	class="rightdock tabheader extendtop-icon" 
	draggable="false" 
	aria-label="Hide" 
	data-tooltip-delay="300"
	data-type="rightdock-hideicon"
> 
	<div
		class="workspace-tab
	 >						
	</div>
</div>
<div class="snippetdescription">${item.description || "No description available"}</div>
`;



itemDiv.innerHTML = `
<div 
class="icon-hidedock rightdock-" 
draggable="false" 
aria-label="Hide" 
data-tooltip-delay="300"
data-type="rightdock-hideicon"
>
										${item.name}</div>
<div class="snippetdescription">${item.description || "No description available"}</div>
					`;
sidebar-toggle-button

itemDiv.innerHTML = `
<div 
class="rightdock-lowerhide-icon" 
draggable="false" 
aria-label="Hide" 
data-tooltip-delay="300"
data-type="rightdock-hideicon"
>
										${item.name}</div>
<div class="snippetdescription">${item.description || "No description available"}</div>
					`;

```

														 
```js
function renderEnhancedMenuItems() {
			const menuItems = enhancedMenu.items; // Assumes .items holds the EnhancedMenuItem instances

			// Create a container for the rendered HTML
			let container = document.createElement('div');
			container.classList.add('snippet-items-container');

			// Loop through each EnhancedMenuItem, formatting as needed
			menuItems.forEach(item => {
					let itemDiv = document.createElement('div');
					itemDiv.classList.add('snippet-item');

					// Customize item display with the properties you need (e.g., name, type)
					itemDiv.innerHTML = `
							<div class="snippet-title">${item.name}</div>
							<div class="snippet-description">${item.description || "No description available"}</div>
					`;

					container.appendChild(itemDiv);
			});

			// Append the container to your desired location in Obsidian (e.g., status bar, sidebar)
			document.body.appendChild(container); // Or use another specific element to place this
	}				 

const editor = leaf.view.editor;  
const editorPosition = editor.getCursor();  
const line_string = editor.getLine(editorPosition.line);  
const line_prefix = line_string.substring(0, editorPosition.ch);

<div>Workspace-tabs mod-top-mod-top-right-space<div>
<div>workspace-tabs</div> <- hide

.mod-sidedock:has(.mod-right-split) -workspace-tabs:not(mod-top) .workspace-tab-header-containe
														 
let container = document.createElement('div');
			container.classList.add('');

```