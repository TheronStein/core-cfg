[The Beginner’s Guide to DATAVIEW Obsidian Plugin — 10 areas where things can go wrong and how to fix them ](https://denisetodd.medium.com/obsidian-dataview-for-beginners-a-checklist-to-help-fix-your-dataview-queries-11acc57f1e48)

### [Embed /include dataview from other file](https://forum.obsidian.md/t/embed-include-dataview-from-other-file/50127)

SrcContext:: "Bug"

### [Reuseable Query](https://forum.obsidian.md/t/dataview-reuse-dql-queries/44370/7)

SrcContext:: Example

### [Dataview that Presents Files from Current File as Table](https://forum.obsidian.md/t/dataview-that-presents-files-from-current-file-as-table/46329)

SrcContext:: "Example", "Bug"

A table related to data in the current file:

```css
# Planning a party

## Part 1 - Location
- [x ] Check budget
- [ x] Align with X
- [ ] Book location

## Part 2 - Invites
- [x] Design invitations
- [ ] Make a list of guests
```

```undefined
Heading | items completed | overall items
Part 1 - Location | 2 | 3
Part 2 - Invites | 1 | 2
```

```sql
TABLE WITHOUT ID
	Heading,
	length(filter(rows.Tasks, (r) => r.completed)) AS "items completed",
	length(rows.Tasks) AS "overall items"
WHERE file.path = this.file.path
FLATTEN file.tasks as Tasks
GROUP BY meta(Tasks.section).subpath AS Heading
```