[](https://github.com/tmux/tmux/wiki/Recipes#make-c-b-w-binding-only-show-the-one-session)

This makes the `C-b w` tree mode binding only show windows in the attached session.

```
bind w run 'tmux choose-tree -Nwf"##{==:##{session_name},#{session_name}}"'
```