[Lucide](https://lucide.dev/icons/) and custom Obsidian icons can be used alongside detailed elements to provide a visual representation of a feature.

**Example:** In the ribbon on the left, select **Create new canvas** ( ![lucide-layout-dashboard.svg > icon](https://publish-01.obsidian.md/access/f786db9fac45774fa4f0d8112e232d67/Attachments/icons/lucide-layout-dashboard.svg) ) to create a canvas in the same folder as the active file.

**Guidelines for icons**

- Store icons in the `Attachments/icons` folder.
- Add the prefix `lucide-` before the Lucide icon name.
- Add the prefix `obsidian-icon-` before the Obsidian icon name.

**Example:** The icon for creating a new canvas should be named `lucide-layout-dashboard`.

- Use the SVG version of the icons available.
- Icons should be `18` pixels in width, `18` pixels in height, and have a stroke width of `1.5`. You can adjust these settings in the SVG data.

Adjusting size and stroke in an SVG

```html
<svg xmlns="http://www.w3.org/2000/svg" width="WIDTH" height="HEIGHT" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="STROKE-WIDTH" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-layout-dashboard"><rect width="7" height="9" x="3" y="3" rx="1"/><rect width="7" height="5" x="14" y="3" rx="1"/><rect width="7" height="9" x="14" y="12" rx="1"/><rect width="7" height="5" x="3" y="16" rx="1"/></svg>
```

- Utilize the `icon` anchor in embedded images, to tweak the spacing around the icon so that it aligns neatly with the text in the vicinity.
- Icons should be surrounded by parenthesis. ( ![lucide-cog.svg > icon](https://publish-01.obsidian.md/access/f786db9fac45774fa4f0d8112e232d67/Attachments/icons/lucide-cog.svg) )

**Example**: `( ![[lucide-cog.svg#icon]] )`