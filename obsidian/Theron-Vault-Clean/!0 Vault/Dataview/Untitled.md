```js
<%*
		let flag = await tp.system.suggester(suggestionlist,suggestionlist)
			let target = ""
			let namefile1 = await tp.system.prompt("what is the name of the source", "")
%>
```

```js



// Inside your plugin’s main function
this.registerEvent(this.app.workspace.on('active-leaf-change', async ()=> {

            const activeFile=this.app.workspace.getActiveFile();
            // Check if the active file matches your target note's name
            if (activeFile && activeFile.name===nameInput) {
                await loadSnippets();
					}
		}));
}

```


```js
const anotherPlugin = app.plugins.plugins["plugin-id"]; // Replace "plugin-id" with the actual ID of the plugin
const renderedSnippets = anotherPlugin.getRenderedSnippets();
```


```js
import { App, Modal } from "obsidian";

import { EnhancedMenuItem } from "MySnippets/Plugin";

// Inside your plugin’s main function
this.registerEvent(this.app.workspace.on('active-leaf-change', async ()=> {

            const activeFile=this.app.workspace.getActiveFile();
            // Check if the active file matches your target note's name
            if (activeFile && activeFile.name===nameInput) {
                await loadSnippets();
					}
		}));
}

function loadSnippets() {
	        function changeSnippetStatus() {
          const isEnabled = customCss.enabledSnippets.has(snippet);
          customCss.setCssEnabledStatus(snippet, !isEnabled);
        }
}

export Class SnippetItem extends EnhancedMenuItem {
	super(app);
	this.onSubmit = onSubmit;
}
```


## Old Code

```dv
const {globalFunc} = customJS;
let {items} = input;
```


```blank
async function reloadSnippets() { 
	const configPath = app.vault.adapter.getFullPath(".obsidian/config.json"); 
	const configData = JSON.parse(await app.vault.adapter.read(configPath)); 
	// Update enabled snippets list and apply them 
	app.customCss.enabledSnippets = configData.enabledCssSnippets; 
	app.customCss.recomputeAndApplyCustomCSS(); 

```