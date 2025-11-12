Obsidian supports HTML to allow you to display your notes the way you want, or even [embed web pages](https://help.obsidian.md/Editing+and+formatting/Embed+web+pages). Allowing HTML inside your notes comes with risks. To prevent malicious code from doing harm, Obsidian _sanitizes_ any HTML in your notes.

> [!Example]
> The `<script>` element normally lets you run JavaScript whenever it loads. If Obsidian didn't sanitize HTML, an attacker could convince you to paste a text containing JavaScript that extracts sensitive information from your computer and sends it back to them.

That said, since Markdown syntax does not support all forms of styling, using sanitized HTML can be yet another way of enhancing the quality of your notes. We've included some of the more common usages of HTML.

More details on using `<iframe>` can be found in [Embed web pages](https://help.obsidian.md/Editing+and+formatting/Embed+web+pages).

### Comments

[Markdown comments](https://help.obsidian.md/Editing+and+formatting/Basic+formatting+syntax#Comments) are the preferred way of adding hidden comments within your notes. However some methods of converting Markdown notes, such as [Pandoc](https://pandoc.org), have limited support of Markdown comments. In those instances, you can use a `<!-- HTML Comment -->` instead!

### Underline

If you need to quickly underline an item in your notes, you can use `<u>Example</u>` to create your underlined text.

### Span/Div

Span and div tags can be used to apply custom classes from a [CSS snippet](https://help.obsidian.md/Extending+Obsidian/CSS+snippets), or custom defined styling, onto a selected area of text. For example, using `<span style="font-family: cursive">your text</span>` can allow you to quickly change your font.

## Strikethrough

Need to strike ~~some text~~? Use `<s>this</s>` to strike it out.

#Obsidian/Formatting/HTML