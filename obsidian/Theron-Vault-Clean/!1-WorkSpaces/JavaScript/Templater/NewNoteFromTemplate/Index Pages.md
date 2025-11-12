---
Resource URL: https://github.com/SilentVoid13/Templater/discussions/1001
---


### code

## Food

```

---
title: <%tp.file.title%>
aliases: <%tp.file.title%> Index
datecreated: <%tp.file.creation_date("YYYY-MM-DD")%>
datemodified: <%tp.date.now("YYYY-MM-DD")%>
---
%% to update page select all, delete, and call  [[MD Index Pages]] Template %%

# <%tp.file.title%> Index

Made

<%* const made = DataviewAPI.pages("[[" + tp.file.title + "]]" + 'and #made') 
.where(p => p.file.name !="Main Page" && !p.file.folder.includes("Admin/Templates")) 
.sort(p => p.file.name, 'asc') 
.map(p => p.file.link); 
const listMade = DataviewAPI.markdownList(made); 
-%> 
<%- listMade -%>

To Try
<%* const toTry = DataviewAPI.pages("[[" + tp.file.title + "]]" + 'and !#made')
.where(p => p.file.name !="Main Page" && p.file.folder.includes("Recipes"))
.sort(p => p.file.name, 'asc') 
.map(p => p.file.link); 
const listToTry = DataviewAPI.markdownList(toTry); 
-%> 
<%- listToTry -%>

Reference
<%* const reference = DataviewAPI.pages("[[" + tp.file.title + "]]") 
.where(p => p.file.folder.includes("Reference"))
.sort(p => p.file.name, 'asc') 
.map(p => p.file.link); 
const listReference = DataviewAPI.markdownList(reference); 
-%> 
<%- listReference -%>

```

## Film

```

---
datecreated: <%tp.file.creation_date("YYYY-MM-DD")%>
aliases: "<%tp.file.title%>"
imdbsearch: https://www.imdb.com/find?q=<%tp.file.title.replace(/\s+/g, "+")%>&s=names
lbsearch: https://letterboxd.com/search/cast-crew/<%tp.file.title.replace(/\s+/g, "+")%>/
---

%%
This will only work if there is an aliases field in the director's page - so this page adds one.
To update this page later, select everything from "Saw" to the end of the file and call the [[MD Update Director Page]]
%%

# <%tp.file.title%>
[search on imdb](https://www.imdb.com/find?q=<%tp.file.title.replace(/\s+/g, "+")%>&s=names)   [search on letterboxd](https://letterboxd.com/search/cast-crew/<%tp.file.title.replace(/\s+/g, "+")%>/)

---

_last updated: \<\%\+ tp.file.last_modified_date("YYYY-MM-DD HH:mm")\%\>_

---
Saw

<%*
const FilmsSeen = DataviewAPI.pages('#filmtitle and #saw')
  .where (p => tp.frontmatter.aliases?.includes(p.director) || p.director?.includes(tp.file.title) || p.director?.includes(tp.frontmatter.aliases))
  .sort(p => p.file.name, 'asc')
  .map(k => k.file.link + "   •   " + k.genre);
const ListFilmsSeen = DataviewAPI.markdownList(FilmsSeen);
-%>
<% ListFilmsSeen -%>

---
Not Seen

<%*
const Films = DataviewAPI.pages('#filmtitle and !#saw')
 .where (p => tp.frontmatter.aliases?.includes(p.director) || p.director?.includes(tp.file.title) || p.director?.includes(tp.frontmatter.aliases))
  .sort(p => p.file.name, 'asc')
  .map(k => k.file.link + "   •   " + k.genre + "   •   " + k.runtime + " mins");
const ListFilms = DataviewAPI.markdownList(Films);
-%>
<% ListFilms -%>


---

ALL films, sorted by date, most recent first

<%*
const FilmsAll = DataviewAPI.pages('#filmtitle')
  .where (p => tp.frontmatter.aliases?.includes(p.director) || p.director?.includes(tp.file.title) || p.director?.includes(tp.frontmatter.aliases))
  .sort(p => p.filmyear, 'desc')
  .map(k => k.file.link + "   •   " + k.genre + "   •   " + k.runtime + " mins");
const ListFilmsAll = DataviewAPI.markdownList(FilmsAll);
-%>
<% ListFilmsAll -%>
```