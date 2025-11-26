[steps] can be one of the following values:

    n: Move the cursor n lines up or down, negative for up, positive for down.
    n%: Move the cursor n% of the screen height up or down, negative for up, positive for down.
    "top": Move the cursor to the top (first file).
    "bot": Move the cursor to the bottom (last file).
    "prev": Go to the previous file, or the bottom if the cursor is at the top.
    "next": Go to the next file, or the top if the cursor is at the bottom.


## Key notation

You can specify one or more keys in the on of each keybinding rule, and each key can be represented with the following notations:
Notation	Description	Notation	Description
a - z	Lowercase letters	A - Z	Uppercase letters
<Space>	Space key	<Backspace>	Backspace key
<Enter>	Enter key	-	-
<Left>	Left arrow key	<Right>	Right arrow key
<Up>	Up arrow key	<Down>	Down arrow key
<Home>	Home key	<End>	End key
<PageUp>	PageUp key	<PageDown>	PageDown key
<Tab>	Tab key	<BackTab>	Shift + Tab key
<Delete>	Delete key	<Insert>	Insert key
<F1> - <F19>	Function keys	<Esc>	Escape key

You can combine the following modifiers for the keys above:
Modifier	Description
<S-…>	Shift key.
<C-…>	Ctrl key.
<A-…>	Alt/Meta key.
<D-…>	Command/Windows/Super key.

For example:

    <C-a> for Ctrl + a.
    <C-S-b> or <C-B> for Ctrl + Shift + b.
