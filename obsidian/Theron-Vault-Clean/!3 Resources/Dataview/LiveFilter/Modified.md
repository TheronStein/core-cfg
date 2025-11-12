```js
const tp = app.plugins.plugins["templater-obsidian"].templater.current_functions_object;
const checkMark = "✅ ";

let current = dv.current();
let currentFile = app.vault.getAbstractFileByPath(current.file.path);

const changeFilter = async(prop) => {
	let propName = "filter-" + prop
	let values = pages.map(p => p[prop])
	values = [...new Set(values)]
	values.unshift("all")
	const config = {
	  "suggestions": ["Done", ...values],
	  "values": ["Done", ...values],
	  "responses": []
	};
	
	let response;
	while (response !== "Done") {
	response = await tp.system.suggester(config.suggestions, config.values, true, "Selection");
	if (response !== "Done") {	
		let rIndex = config.responses.indexOf(response);
		if (rIndex > -1) {
				config.responses.splice(rIndex, 1);					
		} else {				
			config.responses.push(response);
		}
		let vIndex = config.values.indexOf(response);
		let suggestion = config.suggestions[vIndex];
		if (suggestion.startsWith(checkMark)) {
			config.suggestions[vIndex] = suggestion.replace(checkMark,"");
		} else {
			config.suggestions[vIndex] = checkMark + suggestion;
		}
	}
}
    app.fileManager.processFrontMatter(currentFile, (frontmatter) => { 
		frontmatter[propName] = config.responses
	})
}

const button_status = dv.el('button', 'status' + '(' + current['filter-status'] + ')');
button_status.onclick = async() => {
	await changeFilter("status");
}
const button_genres = dv.el('button', 'genres' + '(' + current['filter-genres'] + ')');
button_genres.onclick = async() => {
	await changeFilter("genres");
}
const button_type = dv.el('button', 'type' + '(' + current['filter-type'] + ')');
button_type.onclick = async() => {
	await changeFilter("type");
}
const button_score = dv.el('button', 'score' + '(' + current['filter-score'] + ')');
button_score.onclick = async() => {
	await changeFilter("score");
}
const button_langue = dv.el('button', 'langue' + '(' + current['filter-langue'] + ')');
button_langue.onclick = async() => {
	await changeFilter("langue");
}

const filterFunction = async(prop) => {
  let propName = "filter-" + prop
  let filter = current[propName]
  if (typeof(filter)=="object" && !filter.includes("all") && filter.length != 0) {
	  filteredPages = filteredPages.filter(p => filter.includes(p[prop]))
  }
}

let pages = dv.pages('"04.1📚 Ressources/films"').sort(p => p.file.name)
let filteredPages = pages

// Apply filters
await filterFunction("status");
await filterFunction("type");
await filterFunction("support");
await filterFunction("score");

// Add filter buttons
dv.span(button_status, button_genres, button_type, button_score, button_langue);

dv.paragraph("Nombre de jeux : " + filteredPages.length)

let headers = ["Cover","Name", "status", "type", "genres", "score","langue"]
let rows = filteredPages.map(p => ["![|60](" + p.cover + ")",p.file.link, p.status, p.type + ", " + p.genres, p.score, p.langue])
dv.table(headers, rows)
```