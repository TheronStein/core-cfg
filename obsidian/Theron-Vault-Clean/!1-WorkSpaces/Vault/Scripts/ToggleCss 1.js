module.exports = async (params) => {
    console.log("Initialized");
    document.querySelectorAll('[]')
    
    console.log(
    [...document.querySelectorAll('*')]
    .filter(elm => [...elm.attributes].some(
      attrib => attrib.name.startsWith('data-path="Y')
    ))
);;
    document.queryselector('').element.appendChild();
    const snippetName = "HideMounts.css";
    const snippetPath = app.customCss.getSnippetPath(snippetName);

    if (!snippetPath) {
        new Notice(`Snippet ${snippetName} not found`);
    }

const isSnippetsEnabled = app.customCss.enabledSnippets.has(snippetName)
        ? true
        : false;

if (isSnippetsEnabled) {
        app.customCss.setCssEnabledStatus(snippetName, false);
        app.customCss.requestLoadSnippets();
} else {
        console.log("fwefwef");
        app.customCss.setCssEnabledStatus(snippetName, true);
        app.customCss.requestLoadSnippets();
    }
};
