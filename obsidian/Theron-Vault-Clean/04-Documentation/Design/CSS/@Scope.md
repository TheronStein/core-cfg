  
[#software-engineering](https://publish.obsidian.md/#software-engineering)  

[#software-engineering/css](https://publish.obsidian.md/#software-engineering/css)

see more

[An introduction to @scope in CSS (fullystacked.net)](https://fullystacked.net/posts/scope-in-css/)

If you have a paragraph within `.content`, it won't be selected (if you have a browser that supports `@scope` you can look at the [CodePen example](https://codepen.io/cssgrid/pen/abRepXJ)).

A `@scope` can have as many "holes" as you want:

```css
@scope (.component) to (.content, .slot, .child-component) {
  p {
    color: red;
  }
}
```

```html
<div class="component">
  <p>In scope.</p>
  <div class="content">
    <p>Out of scope.</p>
  </div>
  <div>
    <p>In scope.</p>
  </div>
   <div class="slot">
    <p>Out of scope.</p>
  </div>
   <div class="child-component">
    <p>Out of scope.</p>
  </div>
   <div>
    <p>In scope.</p>
  </div>
</div>
```