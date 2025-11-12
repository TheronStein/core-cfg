[](https://github.com/tmux/tmux/wiki/Recipes#change-shortcut-keys-in-tree-mode)

This assigns the shortcut keys by the window index for the current session rather than by line number and uses `a` to `z` for higher numbers rather than `M-a` to `M-z`. Note that this replaces the existing uses for the `a` to `z` keys.

```
bind w run -C { choose-tree -ZwK "##{?##{!=:#{session_name},##{session_name}},,##{?window_format,##{?##{e|<:##{window_index},10},##{window_index},##{?##{e|<:##{window_index},36},##{a:##{e|+:##{e|-:##{window_index},10},97}},}},}}" }
```
