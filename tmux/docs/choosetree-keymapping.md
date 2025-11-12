2aee ### Changm shortcut keys in tree mode

[](https://github.com/tmux/tmux/wiki/Recipes#change-shortcut-keys-in-tree-mode)

This assigns the shortcut keys by the window index for the current session rather than by line number and uses `a` to `z` for higher numbers rather than `M-a` to `M-z`. Note that this replaces the existing uses for the `a` to `z` keys.

    bind w run -C { choose-tree -ZwK "##{?##{!=:#{session_name},##{session_name}},,##{?window_format,##{?##{e|<:##{window_index},10},##{window_index},##{?##{e|<:##{window_index},36},##{a:##{e|+:##{e|-:##{window_index},10},97}},}},}}" }

### Toggle table of contents Pages 11

- [Home](https://github.com/tmux/tmux/wiki)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [Advanced Use](https://github.com/tmux/tmux/wiki/Advanced-Use)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [Clipboard](https://github.com/tmux/tmux/wiki/Clipboard)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [Contributing](https://github.com/tmux/tmux/wiki/Contributing)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [Control Mode](https://github.com/tmux/tmux/wiki/Control-Mode)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [FAQ](https://github.com/tmux/tmux/wiki/FAQ)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [Formats](https://github.com/tmux/tmux/wiki/Formats)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [Installing](https://github.com/tmux/tmux/wiki/Installing)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [Modifier Keys](https://github.com/tmux/tmux/wiki/Modifier-Keys)

  ### Uh oh!

  There was an error while loading. [Please reload this page](https://github.com/tmux/tmux/wiki/Recipes).

- [Recipes](https://github.com/tmux/tmux/wiki/Recipes)
  - [Configuration file recipes](https://github.com/tmux/tmux/wiki/Recipes#configuration-file-recipes)
  - [Create new panes in the same working directory](https://github.com/tmux/tmux/wiki/Recipes#create-new-panes-in-the-same-working-directory)
  - [Prevent pane movement wrapping](https://github.com/tmux/tmux/wiki/Recipes#prevent-pane-movement-wrapping)
  - [Send Up and Down keys for the mouse wheel](https://github.com/tmux/tmux/wiki/Recipes#send-up-and-down-keys-for-the-mouse-wheel)
  - [Make C-b w binding only show the one session](https://github.com/tmux/tmux/wiki/Recipes#make-c-b-w-binding-only-show-the-one-session)
  - [Create a new pane to copy](https://github.com/tmux/tmux/wiki/Recipes#create-a-new-pane-to-copy)
  - [C-DoubleClick to open emacs(1)](https://github.com/tmux/tmux/wiki/Recipes#c-doubleclick-to-open-emacs1)
  - [Change shortcut keys in tree mode](https://github.com/tmux/tmux/wiki/Recipes#change-shortcut-keys-in-tree-mode)

##### Clone this wiki locally

## Footer

[](https://github.com/)

[](https://github.com/)© 2025 GitHub, Inc.

### Footer navigation

- [](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
