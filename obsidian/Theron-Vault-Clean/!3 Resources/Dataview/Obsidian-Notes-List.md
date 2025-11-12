https://github.com/702573N/Obsidian-Notes-List

Dataview Snippet To Show Notes In Different List Views

## Story

[](https://github.com/702573N/Obsidian-Notes-List#story)

All Obsidian users switched from some other note-taking programme (such as Evernote, Apple Notes, Standard Notes, Bear Notes) to Obsidian. When switching, many users lack a list of all notes with a small excerpt of the text and, if applicable, a thumbnail image. This Dataview snippet makes it possible to retrofit this missing view with a single line of code. All that is needed is the Dataview plugin.

## Setup

[](https://github.com/702573N/Obsidian-Notes-List#setup)

- Install "Dataview Plugin" from the external plugins
    
- Create a new folder called "notesList" or any other name and paste the files "view.js" and "view.css" into it
    
    [![Bildschirm­foto 2022-10-16 um 14 25 00](https://user-images.githubusercontent.com/59178587/196035303-72d032a9-09b2-4c98-9afa-c2b835a2b107.png)](https://user-images.githubusercontent.com/59178587/196035303-72d032a9-09b2-4c98-9afa-c2b835a2b107.png)
- Create a new note or edit an existing one and add the following code line:
    
    ````
    ```dataviewjs
    dv.view("notesList", {pages: "", view: "normal"})
    ```
    ````
    

1. If you paste the main files (js/css) into another folder then "notesList", you have to replace the name between the first quotation marks.
    
2. There are 2 different variables to set path/location as "pages", list view style as "view".
    

---

### pages:

[](https://github.com/702573N/Obsidian-Notes-List#pages)

```
pages: ""
```

Get all notes in obsidian.

```
pages: "Notes/Theology"
```

Set a custom folder to get notes from.

---

### view:

[](https://github.com/702573N/Obsidian-Notes-List#view)

```
view: "normal"
```

List view with small text preview and a preview of all attachments below like in Bear.

```
view: "compact"
```

List view with small text preview and a preview of the first attachment inside the note.

```
view: "cards"
```

List view with small cards of each note including small text preview and a preview of the first attachment inside the note.

---

## Impressions

[](https://github.com/702573N/Obsidian-Notes-List#impressions)

### Normal View

[](https://github.com/702573N/Obsidian-Notes-List#normal-view)

[![Bildschirm­foto 2022-10-16 um 14 16 45](https://user-images.githubusercontent.com/59178587/196035529-cc727ad6-36e4-4085-a6b9-65dd2091f3f9.png)](https://user-images.githubusercontent.com/59178587/196035529-cc727ad6-36e4-4085-a6b9-65dd2091f3f9.png)

---

### Compact View

[](https://github.com/702573N/Obsidian-Notes-List#compact-view)

[![Bildschirm­foto 2022-10-16 um 14 17 41](https://user-images.githubusercontent.com/59178587/196035534-8da3fd4e-646f-4f75-a8d4-544f44147aea.png)](https://user-images.githubusercontent.com/59178587/196035534-8da3fd4e-646f-4f75-a8d4-544f44147aea.png)

---

### Cards View

[](https://github.com/702573N/Obsidian-Notes-List#cards-view)

[![Bildschirm­foto 2022-10-16 um 14 18 18](https://user-images.githubusercontent.com/59178587/196035541-e28b89fe-3cd7-4f80-a3dd-6b258082710d.png)](https://user-images.githubusercontent.com/59178587/196035541-e28b89fe-3cd7-4f80-a3dd-6b258082710d.png)