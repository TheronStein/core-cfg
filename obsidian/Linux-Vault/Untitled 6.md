### 1. **Basic Syntax Highlighting**

You can try using a Vim syntax file for ACS if one exists. You can manually install it:

mkdir -p ~/.config/nvim/syntax

And place a file like `acs.vim` in there. Then, in your `filetype.vim`:

au BufRead,BufNewFile *.acs set filetype=acs
