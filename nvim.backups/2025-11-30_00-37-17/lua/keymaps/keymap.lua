---@class core.keymap
local M = {}

M.meta = {
	desc = "Better `vim.keymap` with support for filetypes and LSP clients",
	needs_setup = false,
}

---@class core.keymap.set.Opts: vim.keymap.set.Opts
---@field ft? string|string[] Filetype(s) to set the keymap for.
---@field lsp? vim.lsp.get_clients.Filter Set for buffers with LSP clients matching this filter.
---@field enabled? boolean|fun(buf?:number): boolean condition to enable the keymap.

---@class core.keymap.del.Opts: vim.keymap.del.Opts
---@field buffer? boolean|number If true or 0, use the current buffer.
---@field ft? string|string[] Filetype(s) to set the keymap for.
---@field lsp? vim.lsp.get_clients.Filter Set for buffers with LSP clients matching this filter.

---@class core.Keymap
---@field mode string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
---@field lhs string           Left-hand side |{lhs}| of the mapping.
---@field rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---@field opts? snacks.keymap.set.Opts
---@field enabled fun(buf?:number): boolean

local by_ft = {} ---@type table<string, table<string,snacks.Keymap>>
local by_lsp = {} ---@type table<string, table<string,snacks.Keymap>>
local valid = {
	buffer = true,
	desc = true,
	callback = true,
	remap = true,
	silent = true,
	expr = true,
	nowait = true,
	unique = true,
	script = true,
	replace_keycodes = true,
	noremap = true,
}
