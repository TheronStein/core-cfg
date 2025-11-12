Hello,

this is a small dvjs-table I came up with (with a bit of help from ChatGPT admittedly) that does the following things:

- for two given folders, take all notes which contain a given tag `experiment_report`, and construct a table of notes.
    - matching notes are listed as pairs,
    - if a filename is present in only one of the folders, it is only listed for said folder. For the other one, a `/` will be used
- iterate over them, and create a table with links to them. Beyond the link, the content of a specific YAML-field `type_exp` is added
- sort alphanumerically by contents of `type_exp`, then alphanumerically by filename within each set.

# Notes

- The file-structure is a bit more complicated, because this vault interfaces with [Quarto](https://quarto.org/), and therefore needs various measures to make these systems interface properly.
    
- these file-pairs are consistent in their main name, but
    
    - get prefixed with either `exp_` or `rep_` (depending on the folder)
    - get prefixed with a dynamic number of underscores `_` _before_ the prefix above (e.g. `__exp_*`)

This snippet handles all these scenarios, constructs valid links to them, and then strips the prefixes from the displayed name.

Additionally, the contents of a specific YAML

````
```dataviewjs
// Fetch pages from the experiments and reports directories
const experiments = dv.pages('"experiments"').where(p => p.tags && p.tags.includes("experiment_report"));
const reports = dv.pages('"report/exp_analyses"').where(p => p.tags && p.tags.includes("experiment_report"));

// Create maps to store file paths, cleaned names, and type_exp values
const experimentMap = new Map();
const reportMap = new Map();

// Helper function to clean names
function cleanName(fileName, prefix) {
    return fileName.replace(/^[\_]+/, "").replace(new RegExp(`^${prefix}_`), ""); // Remove leading underscores and prefix
}

// Populate experimentMap
for (const exp of experiments) {
    const cleanedName = cleanName(exp.file.name, "exp");
    const typeExp = Array.isArray(exp.type_exp) ? exp.type_exp.join(", ") : (exp.type_exp || ""); // Join list to string if necessary
    experimentMap.set(cleanedName, { path: exp.file.path, typeExp: typeExp });
}

// Populate reportMap
for (const rep of reports) {
    const cleanedName = cleanName(rep.file.name, "rep");
    const typeExp = Array.isArray(rep.type_exp) ? rep.type_exp.join(", ") : (rep.type_exp || ""); // Join list to string if necessary
    reportMap.set(cleanedName, { path: rep.file.path, typeExp: typeExp });
}

// Get all unique base names from both maps
const allBaseNames = new Set([...experimentMap.keys(), ...reportMap.keys()]);

// Generate table rows
const rows = Array.from(allBaseNames).map(name => {
    const experimentData = experimentMap.get(name);
    const reportData = reportMap.get(name);

    // Create file links or show '/' if the file doesn't exist
    const experimentLink = experimentData ? `[[${experimentData.path}|${name}]] (${experimentData.typeExp})` : "/";
    const reportLink = reportData ? `[[${reportData.path}|${name}]] (${reportData.typeExp})` : "/";

    // Debugging information
    console.log(`Name: ${name}, Experiment Data: ${JSON.stringify(experimentData)}, Report Data: ${JSON.stringify(reportData)}`);
    console.log(`Experiment Link: ${experimentLink}, Report Link: ${reportLink}`);
    
    return {
        name: name,
        experimentLink: experimentLink,
        reportLink: reportLink,
        typeExp: experimentData ? experimentData.typeExp : (reportData ? reportData.typeExp : "")
    };
});

// Sort rows by typeExp and then by name
rows.sort((a, b) => {
    // First by typeExp
    if (a.typeExp < b.typeExp) return -1;
    if (a.typeExp > b.typeExp) return 1;
    // Then by name within the same typeExp
    if (a.name < b.name) return -1;
    if (a.name > b.name) return 1;
    return 0;
});

// Display the table
dv.table(["Experiment", "Report"], rows.map(row => [row.experimentLink, row.reportLink]));
```
````