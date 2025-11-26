[fg.yazi: yazi plugin for rg search with fzf file preview](https://gitee.com/DreamMaoMao/fg.yazi)

# fg.yazi

[https://github.com/user-attachments/assets/05101a7c-33af-4899-8763-0af905266098](https://gitee.com/link?target=https%3A%2F%2Fgithub.com%2Fuser-attachments%2Fassets%2F05101a7c-33af-4899-8763-0af905266098)

A Yazi plugin for searching file content or filenames using `ripgrep` with `fzf` preview. Supports opening a specified line of search results through nvim or locating files in yazi.

> \[!NOTE\] The latest main branch of Yazi is required at the moment.
> 
> Support shell: `bash`, `zsh` ,`fish` ,`nushell`

## [](https://gitee.com/DreamMaoMao/fg.yazi#dependencies)Dependencies

- fzf
- ripgrep
- bat
- nullshell(only windows need)

## [](https://gitee.com/DreamMaoMao/fg.yazi#install)Install

```
git clone https://github.com/DreamMaoMao/fg.yazi.git ~/.config/yazi/plugins/fg.yazi
```

```
git clone https://gitee.com/DreamMaoMao/fg.yazi.git $env:APPDATA\yazi\config\plugins\fg.yazi
```

## [](https://gitee.com/DreamMaoMao/fg.yazi#usage)Usage

### [](https://gitee.com/DreamMaoMao/fg.yazi#options)Options

- nvim: open selected file in nvim and jump to the match line
- jump: reach file in yazi
- menu: open option menu to select the action(default)

```
require("fg"):setup({
    default_action = "menu", -- nvim, jump
})
```

This option uses `ripgrep` to output all the lines of all files, and then uses `fzf` to fuzzy matching.

```
[[manager.prepend_keymap]]
on   = [ "f","g" ]
run  = "plugin fg"
desc = "find file by content (fuzzy match)"
```

The following option passes the input to `ripgrep` for a match search, reusing the `rg` search each time the input is changed. This is useful for searching in large folders due to increased speed, but it does not support fuzzy matching.

```
[[manager.prepend_keymap]]
on   = [ "f","G" ]
run  = "plugin fg -- rg"
desc = "find file by content (ripgrep match)"
```

```
[[manager.prepend_keymap]]
on   = [ "f","f" ]
run  = "plugin fg -- fzf"
desc = "find file by filename"
```
