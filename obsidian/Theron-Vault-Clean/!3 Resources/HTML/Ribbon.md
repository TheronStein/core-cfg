```html
.workspace-ribbon side-dock-ribbon mod-left

/* initial and hidden state styles */
.workspace-ribbon.side-dock-ribbon.mod-left.is-collapsed,
.workspace-ribbon.side-dock-ribbon.mod-left {
    position: absolute; 
    left: -20px; /* Move the element to the left to hide it */
    opacity: 0; 
    transition: left 0.5s ease-out 0.2s, opacity 0.5s ease-out 0.2s; 
}

/* styles when hovered to show the element */
.workspace-ribbon.side-dock-ribbon.mod-left.is-collapsed:hover,
.workspace-ribbon.side-dock-ribbon.mod-left:hover {
    left: 0; /* Move the element to its visible position */
    opacity: 1; 
    transition: left 0.2s ease-out 0s, opacity 0.2s ease-out 0s; 
}

/* remove the space reserved for the toggle button at the top of the side-dock-ribbon */
.mod-macos .workspace-ribbon.side-dock-ribbon.mod-left::before {
    display: none;
}

/* adapt to windows system */
.mod-windows .workspace-ribbon.side-dock-ribbon.mod-left {
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    margin-top: 0px;
    width: 44px;
    height: calc(100% - 42px - var(--tab-outline-width));
}


.mod-windows .workspace-ribbon.side-dock-ribbon.mod-left.is-collapsed {
    height: 100%;
}


-Ribbon Bar Height Altering (Size Reduce/Pull up from height) 
Raises bar from the bottom.
.side-dock-actions {
    position: relative;
    bottom: -8px;
    gap: 4px;
}

:not(.is-tablet) .side-dock-ribbon-action {
    height: 32px;
}

.is-tablet .side-dock-ribbon-action {
    height: 44px;
}

.side-dock-settings {
    height: 0px;
    margin-top: 0px;
}

- Pushes the file explorer to the right to accomodate for the bar expanding out.
.nav-files-container.node-insert-event.show-unsupported {
    position: relative;
    padding-left: 24px;
}

# MacOS/iPad Styling

```css
/* adapt to macos system */
.mod-macos .workspace-ribbon.side-dock-ribbon.mod-left {
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    width: 44px;
    height: calc(100% - 82px - var(--tab-outline-width));
}

.mod-macos .workspace-ribbon.side-dock-ribbon.mod-left.is-collapsed {
    height: calc(100% - 40px - var(--tab-outline-width));
}

/* adapt to ipad */
.is-tablet .workspace-ribbon.side-dock-ribbon.mod-left {
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
}

```
```