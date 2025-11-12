A block is a unit of text in your note, such as a paragraph, block quote, or list item.

You can link to a block by adding `#^` at the end of your link destination followed by a unique block identifier. For example, `[[2023-01-01#^37066d]]`.

Fortunately, you don't need to know the identifier. When you type the caret (`^`), you can select the block from a list of suggestions to insert the correct identifier.

**Searching for blocks across the vault**

You can also search for blocks to link to from across your vault using the `[[^^block]]` syntax. However, more items qualify as blocks compared to [heading links](https://help.obsidian.md/Linking+notes+and+files/Internal+links#Link to a heading in a note) to a heading in a note, so this list will be much longer.

> [!Info]- Screenshot of searching for a block link
> ![[Link to a block in a note-20241028203240613.webp]]

You can also create human-readable block identifiers by adding a blank space followed by the identifier. Block identifiers can only consist of Latin letters, numbers, and dashes.

For example, add `^quote-of-the-day` at the end of a block:

```md
"You do not rise to the level of your goals. You fall to the level of your systems." by James Clear ^quote-of-the-day
```

Now you can link to the block by typing `[[2023-01-01#^quote-of-the-day]]`.

Interoperability

Block references are specific to Obsidian and not part of the standard Markdown format. Links containing block references won't work outside of Obsidian.

#Obsidian/Link/Block
#Obsidian/Snippet