```js
async renderList(dv) {
  // Add CSS class to Dataview div block.
  dv.container.className += " my-css-class";

  // Render a list.
  const div = dv.el("div", "Here is my list: ", {
    container: dv.container,
    cls: "my-class-for-list",
  });
  const ul = dv.el("ul", "", {
    container: div,
  });
  ul.innerText = ""; // a "bug" into Dataview add an extra span everywhere when there is an empty string, here we remove it.

  for (let index = 0; index < 10; index++)
    dv.el("li", index, { container: ul, cls: "my-class-for-item" });
}
```

