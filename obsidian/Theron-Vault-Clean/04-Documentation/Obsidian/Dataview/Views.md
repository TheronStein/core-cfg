> [!Important]
> This article references the #projView example. 

## Make Custom Mark/Highlighting Element
### `dv.view(path, input)`

Complex function which allows for custom views. Will attempt to load a JavaScript file at the given path, passing it `dv` and `input` and allowing it to execute. This allows for you to re-use custom view code across multiple pages. Note that this is an asynchronous function since it involves file I/O - make sure to `await` the result!

`await dv.view("views/custom", { arg1: ..., arg2: ... });`

If you want to also include custom CSS in your view, you can instead pass a path to a folder containing `view.js` and `view.css`; the CSS will be added to the view automatically:

`views/custom  -> view.js  -> view.css`

View scripts have access to the `dv` object (the API object), and an `input` object which is exactly whatever the second argument of `dv.view()` was.

Bear in mind, `dv.view()` cannot read from directories starting with a dot, like `.views`. Example of an incorrect usage:

`await dv.view(".views/view1", { arg1: 'a', arg2: 'b' });`

Attempting this will yield the following exception:

`Dataview: custom view not found for '.views/view1/view.js' or '.views/view1.js'.`

Also note, directory paths always originate from the vault root.

#### Example

In this example, we have a custom script file named `view1.js` in the `scripts` directory.

**File:** `scripts/view1.js`

``console.log(`Loading view1`);  function foo(...args) {   console.log('foo is called with args', ...args); } foo(input)``

And we have an Obsidian document located under `projects`. We'll call `dv.view()` from this document using the `scripts/view1.js` path.

**Document:** `projects/customViews.md`

`await dv.view("scripts/view1", { arg1: 'a', arg2: 'b' })` 

When the above script is executed, it will print the following:

`Loading view1 foo is called with args {arg1: 'a', arg2: 'b'}`