---
topic: tmux
category: advanced
subjects: commands, parsing
url: https://github.com/tmux/tmux/wiki/Advanced-Use#command-parsing
---

When tmux reads a configuration file, it is processed in two broad steps: parsing and execution. The parsing process is:

1. Configuration file directives are handled, for example `%if`. These are described in the next section.
    
2. The command is parsed and split into a set of arguments. For example take the command:
    
    ```
    new -A -sfoo top
    ```
    

3. It is first split up into a list of four: `new`, `-A`, `-sfoo` and `top`.
    
4. This list is processed again and tmux looks up the command, so it knows it is `new-session` with arguments `-A`, `-s foo` and `top`.
    
5. The command is placed at the end of a command queue.
    

Once all of the configuration file is parsed, execution takes place: the commands are executed from the command queue in order.

A similar process takes place for commands read from the command prompt or as an argument to another command (such as `if-shell`). These are pretty much the same as a configuration file with only one line.

For commands run from the shell, steps 1 and 2 are skipped - configuration file directives are not supported, and the shell splits the command into arguments before giving it to tmux.

This split into parsing and execution does not often have any visible effect but occasionally it matters. The most obvious effect is on environment variable expansion:

```
setenv -g FOO bar
display $FOO
```

This will not work as expected, because the `set-environment` command takes place during execution and the expansion of `FOO` takes place during parsing. However, this will work:

```
FOO=bar
display $FOO
```

Because both `FOO=bar` and expansion of `FOO` happen during parsing. Similarly this will work:

```
setenv -g FOO bar
display '#{FOO}'
```

Although the `set-environment` happens during execution, `FOO` is not used until `display-message` is executed and expands its argument as a format.

Care must be taken with commands that take another command as an argument, because there may be multiple parsing stages.