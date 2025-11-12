The special meaning is also used inside the third argument {sub} of  
the |substitute()| function with the following exceptions:  
- A % inserts a percent literally without regard to 'cpoptions'.  
- magic is always set without regard to 'magic'.  
- A ~ inserts a tilde literally.  
- <CR> and \r inserts a carriage-return (CTRL-M).  
- \<CR> does not have a special meaning. It's just one of \x.  



Examples: >  
:s/a\|b/xxx\0xxx/g             modifies "a b"      to "xxxaxxx xxxbxxx"  
:s/\([abc]\)\([efg]\)/\2\1/g   modifies "af fa bg" to "fa fa gb"  
:s/abcde/abc^Mde/              modifies "abcde"    to "abc", "de" (two lines)  
:s/$/\^M/                      modifies "abcde"    to "abcde^M"  
:s/\w\+/\u\0/g                 modifies "bla bla"  to "Bla Bla"  
:s/\w\+/\L\u\0/g               modifies "BLA bla"  to "Bla Bla"  
  
Note: "\L\u" can be used to capitalize the first letter of a word.  This is  
not compatible with Vi and older versions of Vim, where the "\u" would cancel