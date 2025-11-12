## 

### `dv.el(element, text)`

Render arbitrary text in the given html element.

`dv.el("b", "This is some bold text");`

You can specify custom classes to add to the element via `cls`, and additional attributes via `attr`:

`dv.el("b", "This is some text", { cls: "dataview dataview-class", attr: { alt: "Nice!" } });`