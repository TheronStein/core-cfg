Embedded styles are included inside another option in between `#[` and `]`. Each changes the style of following text until the next embedded style or the end of the text.

For example, to put some text in red and blue in `status-left`:

```
set -g status-left 'default #[fg=red] red #[fg=blue] blue'
```

Because this is long it is also necessary to also increase the `status-left-length` option:

```
set -g status-left-length 100
```

Or embedded styles can be used conditionally, for example to show `P` in red if the prefix has been pressed or in the default style if not:

```
set -g status-left '#{?client_prefix,#[bg=red],}P#[default] [#{session_name}] '
```