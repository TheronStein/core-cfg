![project-cards-screenshot.png](https://publish-01.obsidian.md/access/e25082da1bfe16d54e36618cd5bfee68/00%20-%20Contribute%20to%20the%20Obsidian%20Hub/02%20Attachments/project-cards-screenshot.png)

This template uses the [Dataview](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Plugins/dataview) plugin to create a live-updating view of projects or tasks. Its goal is to make Obsidian a friendlier place for genuine task management.

To use this template, you’ll need to:

1. Create the view template files.
2. Create a project note.
3. Add the view to a note.

---

## 1. Create the View

> This applies Dataview’s `dv.view()` method, which lets you create reusable code blocks and embed them in other notes. [See the Dataview documentation](https://blacksmithgu.github.io/obsidian-dataview/api/code-reference/#dvviewpath-input) for more technical detail.

Start by creating a folder in your vault to contain the template. We’ll refer to it as `project-cards` in this walkthrough, but any unique name will do.

Inside this folder, create two files to contain the code at the bottom of this page:

- [view.js](https://publish.obsidian.md/hub/03+-+Showcases+%26+Templates/Templates/Plugin-specific+templates/Dataview+templates/Project+Cards#view.js) contains the JavaScript code that generates the HTML for your list of project cards.
- [view.css](https://publish.obsidian.md/hub/03+-+Showcases+%26+Templates/Templates/Plugin-specific+templates/Dataview+templates/Project+Cards#view.css) contains the CSS styling to make your cards look pretty.

You may want to place your Dataview templates inside a folder for better organization. Example folder structure:

```
├── Views
│   └── project-cards
│       ├── view.js
│       └── view.css
```

Once these files are created, copy the code below into each one. You may want to use an external code editor for this part, such as [Visual Studio Code](https://code.visualstudio.com/).

---

## 2. Create Projects

Back in Obsidian, make a new note to serve as your first project. Any note with the following [YAML frontmatter](https://publish.obsidian.md/hub/05+-+Concepts/YAML+frontmatter) format will work:

```yaml
---
tags:     project
title:    Some Neat Project
subtitle: PROJECT-0001
status:   todo
dates:
  '2021-12-21 14:00': In progress.
links:
  'A Useful Link': https://www.google.com
---
```

- `title`: The card will show this as the name of your project.
- `subtitle`: This will appear below the title. Can be used for (e.g.) a short description of the project or a reference code.
- `status`: The card will show a colored icon to indicate the status of the project. Supported status codes: `todo`, `today`, `cont` (continuing or standing), `wait` (waiting or pending), `important`, and `done`. (Use `view.css` to add more codes and colors!)
- `dates`: Keep track of deadlines, milestones, or the latest activity. If the project has at least one date, that date will be used to sort projects. You can add any number of additional dates here, but they won’t affect [sorting](https://publish.obsidian.md/hub/03+-+Showcases+%26+Templates/Templates/Plugin-specific+templates/Dataview+templates/Project+Cards#sorting).
- `links`: Add any number of useful links here, e.g. to a Google Doc, a Wikipedia article, or the project website. These will show on the project card as clickable buttons.
- `priority`: Optional [sort](https://publish.obsidian.md/hub/03+-+Showcases+%26+Templates/Templates/Plugin-specific+templates/Dataview+templates/Project+Cards#sorting) priority, `1` thru `9`. Defaults to `9` if none is set.
- `tags`: Optional. Tagging your note as `#project` is just one convenient way for Dataview to query your project notes.

---

## 3. Embed View

Now that we have the template and a project, we can put them together. Add the following code block to a new or existing note:

```dataviewjs
dv.view( 'project-cards', {
  projects: dv.pages('#project')
});
```

This tells Dataview to select all notes with the `#project` tag, sort them in ascending order—earlier dates followed by later dates—and display them as project cards.

You can use additional Dataview queries to narrow down the results. For example, to show only projects with a status of `todo`:

```dataviewjs
dv.view( 'project-cards', {
  projects: dv.pages('#project').where( p => p.status == 'wait' )
});
```

### Sorting

Projects are sorted by the following parameters, in order of precedence:

- **Date:** Earliest to latest. The first item in the project’s `dates` list. If the project has no dates, it’s treated as the current date and time.
- **Priority:** The project’s `priority` number. Defaults to `9`.
- **Title:** The project’s `title`.

The list can be reversed by passing an `order` value of `desc`:

```dataviewjs
dv.view( 'project-cards', {
  projects: dv.pages('#project'),
  order: 'desc'
});
```

---

#Obsidian/Examples
#Obsidian/Templates
#Obsidian/DataView