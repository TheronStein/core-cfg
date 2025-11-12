```dataviewjs
/*
    Table of Contents Script > Version 1
    This version requires the plugins:
        https://github.com/LostPaul/obsidian-folder-notes
        https://github.com/blacksmithgu/obsidian-dataview
    Create a new folder, right-click, and create folder note.
    Click inside the folder note and paste the code below.
    Inside that folder, place the files you want the table of
    contents to display. Make sure each file contains headers.
*/
let count               = 0;
const path_base         = dv.current().file.path
const path_targ         = path_base.substr(0, path_base.lastIndexOf("/"));
const path_sub          = ""
const filter_page       = '"' + path_targ + "" + path_sub + '"';
const filter_folder     = path_targ + path_sub;
let p = dv.pages(filter_page)
    .where(p => p.file.name != dv.current().file.name) // Filter out the current page
    .where(p => p.file.folder == filter_folder) // Filter out folders
    .sort(p => p.file.path)
    .forEach(p =>
    {
        dv.header(4, p.file.name); // display page name as header
        const cache = this.app.metadataCache.getCache(p.file.path);
        if (cache)
        {
            const headings = cache.headings; // get headings from cache
            if ( typeof headings === 'undefined') {
                dv.el("div", '⭕ No Subheaders Found', { cls: "toc_results_none_subheader" });
                dv.el("div", "<br />");
                return;
            }
            if (headings)
            {
                const houtput = headings.slice(0) // exclude the first heading
                .filter(h => h.level <= 6)
                .map(h =>
                {
                    let file_head       = h.heading
                    const header_skip   = file_head.replace(/ /g,"_").toLowerCase();
                    if (header_skip === "table_of_contents" || header_skip === "toc")
                    {
                        return ""
                    }
                    count++;
                    // Determine indentation based on heading level
                    let indent          = " ".repeat(h.level);
                    const file_name     = p.file.name;
                    
                    // remove backticks and tag symbols
                    file_head           = file_head.replace(/`/g, '');
                    file_head           = file_head.replace(/#/g, '');
                    const file_title    = h.heading.split('#')[0];

                    let objLink       = "[[" + file_name + "#" + file_head + "|" + file_title + "]]";

                    if ( h.level == 1 )
                        return indent + "- " + objLink + "";
                    else if ( h.level == 2 )
                        return indent + " - <span class='toc_h2'>" + objLink + "</span>";
                    else if ( h.level == 3 )
                        return indent + "  - <span class='toc_h3'>" + objLink + "</span>";
                    else if ( h.level == 4 )
                        return indent + "   - <span class='toc_h4'>" + objLink + "</span>";
                    else if ( h.level == 5 )
                        return indent + "    - <span class='toc_h5'>" + objLink + "</span>";
                    else if ( h.level == 6 )
                        return indent + "     - <span class='toc_h6'>" + objLink + "</span>";
                    else
                        return 'No Result'
                })
                .join("\n")

                dv.el("div", houtput);
                dv.el("div", "<br />");
            }
        }
    });

    /*
        display NO RESULTS
    */

    if (count === 0)
    {
        const rootNode = dv.el("div", "No results", { cls: "toc_results_none" });
        rootNode.setAttribute("style", "text-align:center;");
    }
```