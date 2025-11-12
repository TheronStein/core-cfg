> I use this template for smaller locations like Buildings, Lots, etc. for my D&D campaigns.

Template uses [Templater](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Plugins/templater-obsidian) and [Dataview](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Plugins/dataview) plugins. As well as my [Kanban](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/CSS+Snippets/Kanban+(SlRvb)) snippet, and some [ITS Theme](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Themes/ITS+Theme) cssclasses, but neither of these snippets are _required_ to use template, just makes it look nice.

The query template for these notes are here: [Locale Dataview Query Template](https://publish.obsidian.md/hub/03+-+Showcases+%26+Templates/Templates/Plugin-specific+templates/Dataview+templates/Locale+Dataview+Query+Template)

---

`Number:` is usually the number of the location on that map or just the order that I might want to see this note sorted in when I use a dataview query to pull up multiple Locale notes.

`Location::` is often a link to another location note where this Locale note is located. For example if this Locale note was for a `Store`, the location would be what city it's located in: `Location:: [[City Name]].`

---

```markdown
---
alias: <% tp.file.title %>
tags: Campaign, Location
cssclass: kanban, k-o

Number: 
Notes: 
- 
---
<i>(Location:: )</i>

## <% tp.file.title %>

> (Description:: )

- Bullet list notes about location
```

Image using the [D&D WOTC](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/CSS+Snippets/All+Alternate+Themes+(ITS+Theme)#D D WOTC) Alternate Theme Snippet.

[![T-DnD--Locale.png](https://raw.githubusercontent.com/SlRvb/Obsidian--ITS-Theme/main/Images/Note-Showcase/T-DnD--Locale.png)](https://raw.githubusercontent.com/SlRvb/Obsidian--ITS-Theme/main/Images/Note-Showcase/T-DnD--Locale.png)