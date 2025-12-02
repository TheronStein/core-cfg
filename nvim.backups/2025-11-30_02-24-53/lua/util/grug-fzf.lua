return {
	"MagicDuck/grug-far.nvim",
	opts = { headerMaxWidth = 80 },
	cmd = { "GrugFar", "GrugFarWithin" },
	keys = {
		{
			"<leader>sr",
			function()
				local grug = require("grug-far")
				local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
				grug.open({
					transient = true,
					prefills = {
						filesFilter = ext and ext ~= "" and "*." .. ext or nil,
					},
				})
			end,
			mode = { "n", "v" },
			desc = "Search and Replace",
		},
		{
			"<leader>sR",
			function()
				local grug = require("grug-far")
				grug.open({ transient = true })
			end,
			mode = { "n", "v" },
			desc = "Search and Replace (all files)",
		},
		{
			"<leader>sw",
			function()
				local grug = require("grug-far")
				grug.open({
					transient = true,
					prefills = {
						search = vim.fn.expand("<cword>"),
					},
				})
			end,
			desc = "Search word under cursor",
		},
		{
			"<localleader>sW",
			function()
				local grug = require("grug-far")
				local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
				grug.open({
					transient = true,
					prefills = {
						search = vim.fn.expand("<cword>"),
						filesFilter = ext and ext ~= "" and "*." .. ext or nil,
					},
				})
			end,
			desc = "Search word (current filetype)",
		},
		{
			"<leader>sf",
			function()
				local grug = require("grug-far")
				grug.open({
					transient = true,
					prefills = {
						paths = vim.fn.expand("%"),
					},
				})
			end,
			mode = { "n", "v" },
			desc = "Search in current file",
		},
		{
			"<leader>sb",
			function()
				local grug = require("grug-far")
				local buffers = vim.api.nvim_list_bufs()
				local paths = {}
				for _, buf in ipairs(buffers) do
					if vim.api.nvim_buf_is_loaded(buf) then
						local path = vim.api.nvim_buf_get_name(buf)
						if path ~= "" then
							table.insert(paths, path)
						end
					end
				end
				grug.open({
					transient = true,
					prefills = {
						paths = table.concat(paths, " "),
					},
				})
			end,
			desc = "Search in open buffers",
		},
		{
			"<leader>sv",
			function()
				local grug = require("grug-far")
				grug.open({
					transient = true,
					prefills = {
						search = vim.fn.getreg("v"),
					},
				})
			end,
			mode = { "v" },
			desc = "Search visual selection",
		},
	},
}
