-- ╭──────────────────────────────────────────────────────────────╮
-- │ Comment-Box FZF-Lua Picker                                   │
-- │ Interactive picker with live preview and text input          │
-- ╰──────────────────────────────────────────────────────────────╯

local M = {}

-- Box catalog with style definitions (matching comment-box.nvim catalog)
M.box_styles = {
	{
		id = 1,
		name = "Rounded",
		tl = "╭",
		t = "─",
		tr = "╮",
		l = "│",
		r = "│",
		bl = "╰",
		b = "─",
		br = "╯",
	},
	{
		id = 2,
		name = "Classic",
		tl = "┌",
		t = "─",
		tr = "┐",
		l = "│",
		r = "│",
		bl = "└",
		b = "─",
		br = "┘",
	},
	{
		id = 3,
		name = "Classic Heavy",
		tl = "┏",
		t = "━",
		tr = "┓",
		l = "┃",
		r = "┃",
		bl = "┗",
		b = "━",
		br = "┛",
	},
	{
		id = 4,
		name = "Dashed",
		tl = "┌",
		t = "╌",
		tr = "┐",
		l = "╎",
		r = "╎",
		bl = "└",
		b = "╌",
		br = "┘",
	},
	{
		id = 5,
		name = "Dashed Heavy",
		tl = "┏",
		t = "╍",
		tr = "┓",
		l = "╏",
		r = "╏",
		bl = "┗",
		b = "╍",
		br = "┛",
	},
	{
		id = 6,
		name = "Mix Heavy/Light",
		tl = "┍",
		t = "━",
		tr = "┑",
		l = "│",
		r = "│",
		bl = "┕",
		b = "━",
		br = "┙",
	},
	{
		id = 7,
		name = "Double",
		tl = "╔",
		t = "═",
		tr = "╗",
		l = "║",
		r = "║",
		bl = "╚",
		b = "═",
		br = "╝",
	},
	{
		id = 8,
		name = "Mix Double/Single A",
		tl = "╒",
		t = "═",
		tr = "╕",
		l = "│",
		r = "│",
		bl = "╘",
		b = "═",
		br = "╛",
	},
	{
		id = 9,
		name = "Mix Double/Single B",
		tl = "╓",
		t = "─",
		tr = "╖",
		l = "║",
		r = "║",
		bl = "╙",
		b = "─",
		br = "╜",
	},
	{ id = 10, name = "ASCII", tl = "+", t = "-", tr = "+", l = "|", r = "|", bl = "+", b = "-", br = "+" },
	{
		id = 11,
		name = "Quote A",
		tl = "▄",
		t = "▄",
		tr = "▄",
		l = "█",
		r = " ",
		bl = "▀",
		b = "▀",
		br = "▀",
	},
	{ id = 12, name = "Quote B", tl = "┌", t = "─", tr = " ", l = "│", r = " ", bl = "└", b = "─", br = " " },
	{ id = 13, name = "Quote C", tl = "╓", t = "─", tr = " ", l = "║", r = " ", bl = "╙", b = "─", br = " " },
	{
		id = 14,
		name = "Marked A",
		tl = "▄",
		t = "▄",
		tr = "▄",
		l = " ",
		r = "█",
		bl = "▀",
		b = "▀",
		br = "▀",
	},
	{
		id = 15,
		name = "Marked B",
		tl = " ",
		t = "─",
		tr = "┐",
		l = " ",
		r = "│",
		bl = " ",
		b = "─",
		br = "┘",
	},
	{
		id = 16,
		name = "Marked C",
		tl = " ",
		t = "─",
		tr = "╖",
		l = " ",
		r = "║",
		bl = " ",
		b = "─",
		br = "╜",
	},
	{
		id = 17,
		name = "Vertical Enclosed A",
		tl = "▄",
		t = "▄",
		tr = "▄",
		l = "█",
		r = "█",
		bl = "▀",
		b = "▀",
		br = "▀",
	},
	{
		id = 18,
		name = "Vertical Enclosed B",
		tl = "┌",
		t = " ",
		tr = "┐",
		l = "│",
		r = "│",
		bl = "└",
		b = " ",
		br = "┘",
	},
	{
		id = 19,
		name = "Vertical Enclosed C",
		tl = "╓",
		t = " ",
		tr = "╖",
		l = "║",
		r = "║",
		bl = "╙",
		b = " ",
		br = "╜",
	},
	{
		id = 20,
		name = "Horizontal Enclosed A",
		tl = "┌",
		t = "─",
		tr = "┐",
		l = " ",
		r = " ",
		bl = "└",
		b = "─",
		br = "┘",
	},
	{
		id = 21,
		name = "Horizontal Enclosed B",
		tl = "╒",
		t = "═",
		tr = "╕",
		l = " ",
		r = " ",
		bl = "╘",
		b = "═",
		br = "╛",
	},
	{
		id = 22,
		name = "Horizontal Enclosed C",
		tl = "╒",
		t = "═",
		tr = "╕",
		l = " ",
		r = " ",
		bl = "└",
		b = "─",
		br = "┘",
	},
}

-- Line styles catalog
M.line_styles = {
	{ id = 1, name = "Simple", ls = "─", le = "─", l = "─", tl = " ", tr = " " },
	{ id = 2, name = "Rounded Corner Down", ls = "╭", le = "╮", l = "─", tl = "─", tr = "─" },
	{ id = 3, name = "Rounded Corner Up", ls = "╰", le = "╯", l = "─", tl = "─", tr = "─" },
	{ id = 4, name = "Squared Corner Down", ls = "┌", le = "┐", l = "─", tl = "─", tr = "─" },
	{ id = 5, name = "Squared Corner Up", ls = "└", le = "┘", l = "─", tl = "─", tr = "─" },
	{ id = 6, name = "Squared Title", ls = "─", le = "─", l = "─", tl = "[", tr = "]" },
	{ id = 7, name = "Rounded Title", ls = "─", le = "─", l = "─", tl = "(", tr = ")" },
	{ id = 8, name = "Spiked Title", ls = "─", le = "─", l = "─", tl = "<", tr = ">" },
	{ id = 9, name = "Simple Heavy", ls = "━", le = "━", l = "━", tl = " ", tr = " " },
	{ id = 10, name = "Confined", ls = "├", le = "┤", l = "─", tl = "┤", tr = "├" },
	{ id = 11, name = "Confined Heavy", ls = "┣", le = "┫", l = "━", tl = "┫", tr = "┣" },
	{ id = 12, name = "Weighted", ls = "╾", le = "╼", l = "─", tl = "╼", tr = "╾" },
	{ id = 13, name = "Double", ls = "═", le = "═", l = "═", tl = " ", tr = " " },
	{ id = 14, name = "Double Confined", ls = "╞", le = "╡", l = "═", tl = "╡", tr = "╞" },
	{ id = 15, name = "ASCII A", ls = "-", le = "-", l = "-", tl = " ", tr = " " },
	{ id = 16, name = "ASCII B", ls = "_", le = "_", l = "_", tl = " ", tr = " " },
	{ id = 17, name = "ASCII C", ls = "+", le = "+", l = "-", tl = "+", tr = "+" },
}

-- Alignment options
M.alignments = {
	{ id = "ll", name = "Left box, Left text", box = "left", text = "left" },
	{ id = "lc", name = "Left box, Center text", box = "left", text = "center" },
	{ id = "lr", name = "Left box, Right text", box = "left", text = "right" },
	{ id = "cl", name = "Center box, Left text", box = "center", text = "left" },
	{ id = "cc", name = "Center box, Center text", box = "center", text = "center" },
	{ id = "cr", name = "Center box, Right text", box = "center", text = "right" },
	{ id = "rl", name = "Right box, Left text", box = "right", text = "left" },
	{ id = "rc", name = "Right box, Center text", box = "right", text = "center" },
	{ id = "rr", name = "Right box, Right text", box = "right", text = "right" },
	{ id = "la", name = "Left adapted", box = "left", text = "adapted" },
	{ id = "ca", name = "Center adapted", box = "center", text = "adapted" },
	{ id = "ra", name = "Right adapted", box = "right", text = "adapted" },
}

-- Generate a preview box with sample text
function M.generate_box_preview(style, content, width)
	width = width or 50
	content = content or "Sample Comment Box"
	local lines = {}

	-- Handle multi-line content
	local content_lines = {}
	for line in content:gmatch("[^\n]+") do
		table.insert(content_lines, line)
	end
	if #content_lines == 0 then
		content_lines = { content }
	end

	-- Calculate inner width
	local inner_width = width - 2 -- Subtract left and right borders

	-- Top border
	table.insert(lines, style.tl .. string.rep(style.t, inner_width) .. style.tr)

	-- Content lines (centered)
	for _, text in ipairs(content_lines) do
		local text_len = vim.fn.strdisplaywidth(text)
		local padding_total = inner_width - text_len
		local padding_left = math.floor(padding_total / 2)
		local padding_right = padding_total - padding_left

		if padding_total < 0 then
			text = text:sub(1, inner_width - 3) .. "..."
			padding_left = 0
			padding_right = 0
		end

		table.insert(
			lines,
			style.l .. string.rep(" ", padding_left) .. text .. string.rep(" ", padding_right) .. style.r
		)
	end

	-- Bottom border
	table.insert(lines, style.bl .. string.rep(style.b, inner_width) .. style.br)

	return lines
end

-- Generate a preview line with title
function M.generate_line_preview(style, title, width)
	width = width or 50
	title = title or "Title"
	local title_len = vim.fn.strdisplaywidth(title)

	-- Calculate line segments
	local left_len = math.floor((width - title_len - 2) / 2)
	local right_len = width - title_len - 2 - left_len

	local line = style.ls
		.. string.rep(style.l, left_len - 1)
		.. style.tl
		.. " "
		.. title
		.. " "
		.. style.tr
		.. string.rep(style.l, right_len - 1)
		.. style.le

	return { line }
end

-- Main picker function
function M.pick_box(opts)
	opts = opts or {}
	local fzf = require("fzf-lua")

	-- Build entries with preview info embedded
	local entries = {}
	for _, style in ipairs(M.box_styles) do
		local entry = string.format(
			"%2d │ %-22s │ %s%s%s %s %s%s%s",
			style.id,
			style.name,
			style.tl,
			style.t,
			style.tr,
			style.l,
			style.bl,
			style.b,
			style.br
		)
		table.insert(entries, entry)
	end

	fzf.fzf_exec(entries, {
		prompt = "Comment Box Style❯ ",
		winopts = {
			height = 0.75,
			width = 0.85,
			row = 0.35,
			preview = {
				layout = "vertical",
				vertical = "down:50%",
			},
		},
		fzf_opts = {
			["--header"] = "ID │ Name                   │ Preview",
			["--header-lines"] = "0",
		},
		previewer = {
			_ctor = function()
				local previewer = require("fzf-lua.previewer.builtin").buffer_or_file:extend()

				function previewer:new(o, op, fzf_win)
					previewer.super.new(self, o, op, fzf_win)
					self.title = "Box Preview"
					return self
				end

				function previewer:populate_preview_buf(entry_str)
					local bufnr = self:get_tmp_buffer()

					-- Parse the style ID from entry
					local id = tonumber(entry_str:match("^%s*(%d+)"))
					local style = M.box_styles[id]

					if style then
						-- Generate preview with sample content
						local preview_lines = {
							"",
							"  Style: " .. style.name .. " (#" .. style.id .. ")",
							"",
						}

						-- Single line preview
						local box1 = M.generate_box_preview(style, "Single Line Comment", 40)
						for _, line in ipairs(box1) do
							table.insert(preview_lines, "  " .. line)
						end

						table.insert(preview_lines, "")

						-- Multi-line preview
						local box2 = M.generate_box_preview(
							style,
							"Multi-Line Comment\nWith Multiple Lines\nOf Content Inside",
							40
						)
						for _, line in ipairs(box2) do
							table.insert(preview_lines, "  " .. line)
						end

						table.insert(preview_lines, "")

						-- Wide preview
						local box3 = M.generate_box_preview(style, "Wide Comment Box Example", 60)
						for _, line in ipairs(box3) do
							table.insert(preview_lines, "  " .. line)
						end

						table.insert(preview_lines, "")
						table.insert(preview_lines, "  Characters used:")
						table.insert(
							preview_lines,
							string.format("  Top-Left: %s  Top: %s  Top-Right: %s", style.tl, style.t, style.tr)
						)
						table.insert(preview_lines, string.format("  Left: %s        Right: %s", style.l, style.r))
						table.insert(
							preview_lines,
							string.format("  Bot-Left: %s  Bot: %s  Bot-Right: %s", style.bl, style.b, style.br)
						)

						vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, preview_lines)
					end

					self:set_preview_buf(bufnr)
					if self.win and self.win.update_scrollbar then
						self.win:update_scrollbar()
					end
				end

				return previewer
			end,
		},
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				local id = tonumber(selected[1]:match("^%s*(%d+)"))
				local style = M.box_styles[id]

				if style then
					-- Prompt for content
					M.prompt_for_content(function(content)
						if content and content ~= "" then
							-- Prompt for alignment
							M.pick_alignment(function(alignment)
								if alignment then
									M.insert_box(style.id, content, alignment)
								end
							end)
						end
					end)
				end
			end,
			["ctrl-i"] = function(selected)
				-- Quick insert with default alignment (centered)
				if not selected or #selected == 0 then
					return
				end

				local id = tonumber(selected[1]:match("^%s*(%d+)"))
				if id then
					M.prompt_for_content(function(content)
						if content and content ~= "" then
							M.insert_box(id, content, { id = "cc" })
						end
					end)
				end
			end,
		},
	})
end

-- Line picker
function M.pick_line(opts)
	opts = opts or {}
	local fzf = require("fzf-lua")

	local entries = {}
	for _, style in ipairs(M.line_styles) do
		local preview = style.ls
			.. string.rep(style.l, 3)
			.. style.tl
			.. " title "
			.. style.tr
			.. string.rep(style.l, 3)
			.. style.le
		local entry = string.format("%2d │ %-20s │ %s", style.id, style.name, preview)
		table.insert(entries, entry)
	end

	fzf.fzf_exec(entries, {
		prompt = "Comment Line Style❯ ",
		winopts = {
			height = 0.65,
			width = 0.80,
			row = 0.35,
			preview = {
				layout = "vertical",
				vertical = "down:40%",
			},
		},
		fzf_opts = {
			["--header"] = "ID │ Name                 │ Preview",
		},
		previewer = {
			_ctor = function()
				local previewer = require("fzf-lua.previewer.builtin").buffer_or_file:extend()

				function previewer:new(o, op, fzf_win)
					previewer.super.new(self, o, op, fzf_win)
					self.title = "Line Preview"
					return self
				end

				function previewer:populate_preview_buf(entry_str)
					local bufnr = self:get_tmp_buffer()
					local id = tonumber(entry_str:match("^%s*(%d+)"))
					local style = M.line_styles[id]

					if style then
						local preview_lines = {
							"",
							"  Style: " .. style.name .. " (#" .. style.id .. ")",
							"",
						}

						-- Different width examples
						for _, width in ipairs({ 40, 60, 80 }) do
							local line = M.generate_line_preview(style, "Section Title", width)
							table.insert(preview_lines, "  " .. line[1])
							table.insert(preview_lines, "")
						end

						-- Without title
						table.insert(preview_lines, "  Without title (divider):")
						local divider = style.ls .. string.rep(style.l, 48) .. style.le
						table.insert(preview_lines, "  " .. divider)

						vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, preview_lines)
					end

					self:set_preview_buf(bufnr)
					if self.win and self.win.update_scrollbar then
						self.win:update_scrollbar()
					end
				end

				return previewer
			end,
		},
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				local id = tonumber(selected[1]:match("^%s*(%d+)"))
				if id then
					M.prompt_for_content(function(title)
						M.insert_line(id, title)
					end, "Line title (empty for divider): ")
				end
			end,
		},
	})
end

-- Alignment picker
function M.pick_alignment(callback)
	local fzf = require("fzf-lua")

	local entries = {}
	for _, align in ipairs(M.alignments) do
		table.insert(entries, string.format("%-3s │ %s", align.id, align.name))
	end

	fzf.fzf_exec(entries, {
		prompt = "Box Alignment❯ ",
		winopts = {
			height = 0.45,
			width = 0.50,
			row = 0.35,
			preview = { hidden = "hidden" },
		},
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				local id = selected[1]:match("^(%S+)")
				for _, align in ipairs(M.alignments) do
					if align.id == id then
						callback(align)
						return
					end
				end
			end,
		},
	})
end

-- Prompt for content using vim.ui.input
function M.prompt_for_content(callback, prompt_text)
	prompt_text = prompt_text or "Box content: "

	vim.ui.input({ prompt = prompt_text }, function(input)
		if input then
			callback(input)
		end
	end)
end

-- Insert box using comment-box.nvim
function M.insert_box(style_id, content, alignment)
	local cb_ok, cb = pcall(require, "comment-box")
	if not cb_ok then
		vim.notify("comment-box.nvim not found", vim.log.levels.ERROR)
		return
	end

	-- Get current cursor position
	local row = vim.api.nvim_win_get_cursor(0)[1]

	-- Insert content at current line
	vim.api.nvim_buf_set_lines(0, row, row, false, { content })

	-- Build function name based on alignment
	local func_name = alignment.id .. "box"

	-- Call the appropriate comment-box function
	if cb[func_name] then
		cb[func_name](style_id, row + 1, row + 1)
	else
		-- Fallback to ccbox (centered)
		cb.ccbox(style_id, row + 1, row + 1)
	end
end

-- Insert line using comment-box.nvim
function M.insert_line(style_id, title)
	local cb_ok, cb = pcall(require, "comment-box")
	if not cb_ok then
		vim.notify("comment-box.nvim not found", vim.log.levels.ERROR)
		return
	end

	local row = vim.api.nvim_win_get_cursor(0)[1]

	if title and title ~= "" then
		-- Insert title and create titled line
		vim.api.nvim_buf_set_lines(0, row, row, false, { title })
		cb.lcline(style_id, row + 1, row + 1)
	else
		-- Just insert a divider line
		cb.line(style_id)
	end
end

-- Main picker with both boxes and lines
function M.pick(opts)
	opts = opts or {}
	local fzf = require("fzf-lua")

	local entries = {
		"  Boxes  │ Select a box style with preview",
		"  Lines  │ Select a line/divider style with preview",
		"  Catalog │ Open the built-in comment-box catalog",
	}

	fzf.fzf_exec(entries, {
		prompt = "Comment Box❯ ",
		winopts = {
			height = 0.25,
			width = 0.50,
			row = 0.35,
			preview = { hidden = "hidden" },
		},
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				local choice = selected[1]
				if choice:match("Boxes") then
					vim.schedule(function()
						M.pick_box()
					end)
				elseif choice:match("Lines") then
					vim.schedule(function()
						M.pick_line()
					end)
				elseif choice:match("Catalog") then
					vim.schedule(function()
						local cb = require("comment-box")
						cb.catalog()
					end)
				end
			end,
		},
	})
end

-- Setup function
function M.setup(opts)
	opts = opts or {}

	-- Create user commands
	vim.api.nvim_create_user_command("CommentBoxPicker", function()
		M.pick()
	end, { desc = "Open Comment Box picker" })

	vim.api.nvim_create_user_command("CommentBoxPickBox", function()
		M.pick_box()
	end, { desc = "Pick a comment box style" })

	vim.api.nvim_create_user_command("CommentBoxPickLine", function()
		M.pick_line()
	end, { desc = "Pick a comment line style" })

	-- Optional keymaps
	if opts.keymaps ~= false then
		vim.keymap.set("n", "<leader>Cb", M.pick, { desc = "Comment Box Picker" })
		vim.keymap.set("n", "<leader>Cs", M.pick_box, { desc = "Pick Box Style" })
		vim.keymap.set("n", "<leader>Cl", M.pick_line, { desc = "Pick Line Style" })
	end
end

return M
