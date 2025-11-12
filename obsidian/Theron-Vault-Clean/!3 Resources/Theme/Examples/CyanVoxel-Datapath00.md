```css
.nav-folder-title[data-path^="00"] {
  color: var(--mint);
  --nav-item-color-hover: color-mix(
    in srgb,
    var(--mint) var(--fg-contrast-amount),
    var(--contrast-color)
  );
  --nav-item-background-hover: color-mix(
    in srgb,
    var(--mint) var(--bg-contrast-amount),
    transparent
  );
  --background-modifier-border-focus: color-mix(
    in srgb,
    var(--mint) 40%,
    transparent
  );
  --nav-collapse-icon-color: color-mix(in srgb, var(--mint) 60%, transparent);
}

.nav-folder-title[data-path^="00"]:hover {
  --nav-collapse-icon-color: color-mix(
    in srgb,
    var(--mint) 60%,
    var(--contrast-color)
  );
}
.tree-item-children .nav-folder:has(.nav-folder-title[data-path^="00"]) {
  --nav-indentation-guide-color: color-mix(
    in srgb,
    var(--mint) var(--medium-contrast-amount),
    transparent
  );
}
.tree-item-children
  .nav-folder:has(.nav-folder-title[data-path^="00"])
  .nav-file-title {
  color: color-mix(
    in srgb,
    var(--mint) var(--medium-contrast-amount),
    var(--default-text-color)
  );
  --nav-item-background-hover: color-mix(
    in srgb,
    color-mix(in srgb, var(--mint) 50%, var(--highlight))
      var(--bg-contrast-amount),
    transparent
  );
  --background-modifier-border-focus: color-mix(
    in srgb,
    var(--mint) 40%,
    transparent
  );
  --nav-item-background-active: color-mix(
    in srgb,
    var(--mint) var(--active-contrast-amount),
    transparent
  );
}
```