-- plugins/qmk.lua (or wherever your plugins are)
return {
	"codethread/qmk.nvim",
	ft = "c", -- Only load for C files
	config = function()
		-- Detect keyboard type from current file path
		local function get_keyboard_config()
			local filepath = vim.fn.expand("%:p")

			if filepath:match("sk71pro") then
				return {
					name = "LAYOUT_71_ansi",
					layout = {
						"x x x x x x x x x x x x x",
						"x x x x x x x x x x x x x x x",
						"x x x x x x x x x x x x x x x",
						"x x x x x x x x x x x x _ x x",
						"x _ x x x x x x x x x x x x x",
						"x x x _ _ _ x _ _ _ x x x x x",
					},
				}
			elseif filepath:match("mf34") then
				return {
					name = "LAYOUT",
					layout = {
						"x x x x x x x",
						"x x x x x x x",
						"x x x x x x _",
						"_ _ _ x x x x",
						"_ _ x x x x _",
						"x x x _ x x x",
					},
				}
			else
				return {
					name = "LAYOUT",
					layout = { "x x x x" },
				}
			end
		end

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*.c",
			callback = function()
				local config = get_keyboard_config()
				require("qmk").setup(vim.tbl_extend("force", config, {
					variant = "qmk",
					auto_format_pattern = "*keymap.c",
					comment_preview = {
						position = "top",
						keymap_overrides = {
							["_______"] = "_____",
							KC_TRNS = "_____",
							KC_NO = "XXXXX",
						},
					},
				}))
			end,
		})
	end,
}
