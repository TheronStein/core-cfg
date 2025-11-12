You can reuse DataviewJS code across multiple notes by using the `dv.view()` method. This allows you to store your JavaScript logic in an external file and reference it in any note without duplicating the code. To set this up, you simply place your JavaScript code in a `.js` file within your vault (for example, `scripts/view.js`).

Then, in any note where you want to use that logic, call `dv.view("path/to/view.js")`. If you need to pass data dynamically, you can include it like this:

`dv.view("path/to/view.js", { data: value })`.

This keeps your notes modular and ensures that any changes made to the external file are automatically reflected across all notes that reference it, eliminating the need for manual updates. This approach is clean, effective, and perfect for reusing scripts in DataviewJS blocks in Obsidian.

So here's the external code (example):

function getProjectStatus(page) {
    return page.status || "No status available";
}

function getProjectTasks(page) {
    return page.file.tasks.filter(t => !t.completed);
}

exports.getProjectStatus = getProjectStatus;
exports.getProjectTasks = getProjectTasks;

And calling the script out from a note:

const utils = dv.view("scripts/view.js");
dv.table(
    ["Project", "Status", "Tasks"],
    dv.pages("#projects")
    .map(p => [p.file.link, utils.getProjectStatus(p), utils.getProjectTasks(p).length])
);

With this, you can keep your functions in an external file and use them in your notes to display project statuses and task counts dynamically.

Hope this helps.