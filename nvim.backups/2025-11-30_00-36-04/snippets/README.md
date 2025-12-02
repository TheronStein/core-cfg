# Custom Snippets Guide

## How to use snippets

1. Start typing the **prefix** (e.g., `pr` for print)
2. You'll see it in the completion menu
3. Accept it with `<C-y>` (default blink.cmp accept key)
4. Press `<Tab>` to jump between placeholders (`${1}`, `${2}`, etc.)
5. Press `<S-Tab>` to jump backwards

## Snippet format

```json
{
  "Snippet Name": {
    "prefix": "trigger",
    "body": [
      "line 1 with ${1:placeholder}",
      "line 2 with ${2:another}",
      "final cursor position ${0}"
    ],
    "description": "Shows in completion menu"
  }
}
```

## Placeholders

- `${1:default}` - First tab stop with default text
- `${2}` - Second tab stop
- `${0}` - Final cursor position
- `$1` can be used multiple times for mirrored text

## Add your own

1. Create `<filetype>.json` in this directory
2. Add snippets following the format above
3. Restart Neovim or reload config
4. They'll appear in completion automatically

## Examples by language

### Lua
- `pr` - print()
- `pi` - print(vim.inspect())
- `fn` - function definition
- `for` - for loop
- `forp` - for pairs loop

### JavaScript/TypeScript
- `cl` - console.log()
- `af` - arrow function
- `aaf` - async arrow function
- `tc` - try/catch
- `imp` - import statement

### Python
- `pr` - print()
- `pf` - print f-string
- `def` - function
- `class` - class definition
- `try` - try/except

### Go
- `pr` - fmt.Println()
- `iferr` - if err != nil
- `fn` - function
- `forr` - range loop

## Friendly snippets

You also have access to hundreds of snippets from friendly-snippets.
Type common abbreviations like `fn`, `for`, `if`, etc. to see them.
