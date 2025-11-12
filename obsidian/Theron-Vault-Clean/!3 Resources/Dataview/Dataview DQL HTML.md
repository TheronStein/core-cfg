
ul has-list-bullet
li data-line dir="auto"
span list-bullet
img internal-embed media-embed image-embed is-loaded

```js
$("ul.el-ul").addclass("has-list-bullet");
$("ul.has-list-bullet li").each.addData(data-line());
```

```dataviewcode
table without id ("![](" + imgName + ")") as imgName, file.link as Directory
from 
where img
sort file.date des

// Start building an HTML string for a list
let htmlList = "<ul class="has-list-bullet">"; // Corrected the syntax here

// Append each image as a list item
images.forEach(image => {
    htmlList += `<li data-line="${image.count}"><div src="${image.path}" alt="${firstName} ${lastName}"></li>`;
});

// Close the list
htmlList += "</ul>"; // Corrected the syntax here

// Render the HTML list into the note
dv.el("div", htmlList, {as: "html"});
```
 

```html
<div data-block-language="dataviewjs" class="el-lang-dataviewjs el-div" data-tag-name="div">
<div class="block-language-dataviewjs node-insert-event" style="overflow-x: auto;">
<p dir="auto">
<span data-tag-name="ul" class="el-ul">
<ul>
	<li dir="auto">
		<span alt="Webdata/src/res/imgs/str/bst/Katarina Hartvola/202406062015421.jpg" src="Webdata/src/res/imgs/str/bst/Katarina Hartvola/202406062015421.jpg" class="internal-embed media-embed image-embed is-loaded">
			<img alt="Webdata/src/res/imgs/str/bst/Katarina Hartvola/202406062015421.jpg" src="app://eb3d210f6e9189232abb408ede9adb3a0c37/C:/Users/thero/Dropbox/Vaults/Dropbox-Vault/Vault/Webdata/src/res/imgs/str/bst/Katarina%20Hartvola/202406062015421.jpg?1717966279000" referrerpolicy="no-referrer">
		</span>
	</li>
	<li dir="auto">
		<span alt="Webdata/src/res/imgs/str/bst/Katarina Hartvola/2024060620122711.jpg" src="Webdata/src/res/imgs/str/bst/Katarina Hartvola/2024060620122711.jpg" class="internal-embed media-embed image-embed is-loaded">
			<img alt="Webdata/src/res/imgs/str/bst/Katarina Hartvola/2024060620122711.jpg" src="app://eb3d210f6e9189232abb408ede9adb3a0c37/C:/Users/thero/Dropbox/Vaults/Dropbox-Vault/Vault/Webdata/src/res/imgs/str/bst/Katarina%20Hartvola/2024060620122711.jpg?1717966163000" referrerpolicy="no-referrer">
		</span>
	</li>
</ul>

<span data-tag-name="ul" class="el-ul">
<ul>
	<li dir="auto">
		<span alt="Webdata/src/res/imgs/str/bst/Katarina Hartvola/202406062015421.jpg" src="Webdata/src/res/imgs/str/bst/Katarina Hartvola/202406062015421.jpg" class="internal-embed media-embed image-embed is-loaded">
			<img alt="Webdata/src/res/imgs/str/bst/Katarina Hartvola/202406062015421.jpg" src="app://eb3d210f6e9189232abb408ede9adb3a0c37/C:/Users/thero/Dropbox/Vaults/Dropbox-Vault/Vault/Webdata/src/res/imgs/str/bst/Katarina%20Hartvola/202406062015421.jpg?1717966279000" referrerpolicy="no-referrer">
		</span>
	</li>
	<li dir="auto">
		<span alt="Webdata/src/res/imgs/str/bst/Katarina Hartvola/2024060620122711.jpg" src="Webdata/src/res/imgs/str/bst/Katarina Hartvola/2024060620122711.jpg" class="internal-embed media-embed image-embed is-loaded">
			<img alt="Webdata/src/res/imgs/str/bst/Katarina Hartvola/2024060620122711.jpg" src="app://eb3d210f6e9189232abb408ede9adb3a0c37/C:/Users/thero/Dropbox/Vaults/Dropbox-Vault/Vault/Webdata/src/res/imgs/str/bst/Katarina%20Hartvola/2024060620122711.jpg?1717966163000" referrerpolicy="no-referrer">
		</span>
	</li>
</ul>
```