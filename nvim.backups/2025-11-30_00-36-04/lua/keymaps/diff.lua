-- File comparison and diff utilities
local M = {}

-- Detect which picker is available
local function get_picker()
	local has_fzf, fzf = pcall(require, "fzf-lua")
	if has_fzf then
		return "fzf-lua", fzf
	end

	local has_telescope, telescope = pcall(require, "telescope.builtin")
	if has_telescope then
		return "telescope", telescope
	end

	return "vim", nil
end

-- Get list of loaded buffers
local function get_buffers()
	local buffers = {}
	local current_buf = vim.api.nvim_get_current_buf()

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
			local name = vim.api.nvim_buf_get_name(buf)
			if name ~= "" then
				table.insert(buffers, {
					bufnr = buf,
					filename = vim.fn.fnamemodify(name, ":t"),
					path = name,
					is_current = buf == current_buf,
				})
			end
		end
	end
	return buffers
end

-- FZF-Lua implementation
local function compare_buffers_fzf()
	local fzf = require("fzf-lua")
	local buffers = get_buffers()

	if #buffers < 2 then
		vim.notify("Need at least 2 buffers to compare", vim.log.levels.WARN)
		return
	end

	local first_buffer = nil

	-- Convert buffers to fzf entries
	local function make_entries(buffers)
		local entries = {}
		for _, buf in ipairs(buffers) do
			local display = buf.filename .. (buf.is_current and " (current)" or "")
			table.insert(entries, display)
		end
		return entries
	end

	-- First picker
	fzf.fzf_exec(make_entries(buffers), {
		prompt = "Select First Buffer> ",
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				-- Find the selected buffer
				local selection = selected[1]:match("^([^%s]+)")
				for _, buf in ipairs(buffers) do
					if buf.filename == selection then
						first_buffer = buf
						break
					end
				end

				if not first_buffer then
					return
				end

				-- Second picker
				vim.schedule(function()
					fzf.fzf_exec(make_entries(buffers), {
						prompt = "Select Second Buffer (comparing with " .. first_buffer.filename .. ")> ",
						actions = {
							["default"] = function(selected2)
								if not selected2 or #selected2 == 0 then
									return
								end

								local selection2 = selected2[1]:match("^([^%s]+)")
								local second_buffer = nil

								for _, buf in ipairs(buffers) do
									if buf.filename == selection2 then
										second_buffer = buf
										break
									end
								end

								if not second_buffer then
									return
								end

								if first_buffer.bufnr == second_buffer.bufnr then
									vim.notify("Cannot compare buffer with itself", vim.log.levels.WARN)
									return
								end

								-- Open buffers in diff mode
								vim.schedule(function()
									vim.cmd("only")
									vim.cmd("edit " .. vim.fn.fnameescape(first_buffer.path))
									vim.cmd("diffthis")
									vim.cmd("vsplit " .. vim.fn.fnameescape(second_buffer.path))
									vim.cmd("diffthis")

									vim.notify(
										"Comparing: " .. first_buffer.filename .. " ↔ " .. second_buffer.filename,
										vim.log.levels.INFO
									)
								end)
							end,
						},
					})
				end)
			end,
		},
	})
end

-- Telescope implementation (fallback)
local function compare_buffers_telescope()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local buffers = get_buffers()
	if #buffers < 2 then
		vim.notify("Need at least 2 buffers to compare", vim.log.levels.WARN)
		return
	end

	local first_buffer = nil

	pickers
		.new({}, {
			prompt_title = "Select First Buffer",
			finder = finders.new_table({
				results = buffers,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.filename .. " " .. (entry.is_current and "(current)" or ""),
						ordinal = entry.filename,
						path = entry.path,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					first_buffer = selection.value

					vim.schedule(function()
						pickers
							.new({}, {
								prompt_title = "Select Second Buffer (comparing with " .. first_buffer.filename .. ")",
								finder = finders.new_table({
									results = buffers,
									entry_maker = function(entry)
										return {
											value = entry,
											display = entry.filename
												.. " "
												.. (entry.is_current and "(current)" or ""),
											ordinal = entry.filename,
											path = entry.path,
										}
									end,
								}),
								sorter = conf.generic_sorter({}),
								attach_mappings = function(prompt_bufnr2, map2)
									actions.select_default:replace(function()
										local selection2 = action_state.get_selected_entry()
										actions.close(prompt_bufnr2)

										if first_buffer.bufnr == selection2.value.bufnr then
											vim.notify("Cannot compare buffer with itself", vim.log.levels.WARN)
											return
										end

										vim.schedule(function()
											vim.cmd("only")
											vim.cmd("edit " .. vim.fn.fnameescape(first_buffer.path))
											vim.cmd("diffthis")
											vim.cmd("vsplit " .. vim.fn.fnameescape(selection2.value.path))
											vim.cmd("diffthis")

											vim.notify(
												"Comparing: "
													.. first_buffer.filename
													.. " ↔ "
													.. selection2.value.filename,
												vim.log.levels.INFO
											)
										end)
									end)
									return true
								end,
							})
							:find()
					end)
				end)
				return true
			end,
		})
		:find()
end

-- Vim UI Select fallback
local function compare_buffers_vim()
	local buffers = get_buffers()

	if #buffers < 2 then
		vim.notify("Need at least 2 buffers to compare", vim.log.levels.WARN)
		return
	end

	local first_buffer = nil

	-- First selection
	vim.ui.select(buffers, {
		prompt = "Select First Buffer:",
		format_item = function(buf)
			return buf.filename .. (buf.is_current and " (current)" or "")
		end,
	}, function(choice1)
		if not choice1 then
			return
		end
		first_buffer = choice1

		-- Second selection
		vim.ui.select(buffers, {
			prompt = "Select Second Buffer (comparing with " .. first_buffer.filename .. "):",
			format_item = function(buf)
				return buf.filename .. (buf.is_current and " (current)" or "")
			end,
		}, function(choice2)
			if not choice2 then
				return
			end

			if first_buffer.bufnr == choice2.bufnr then
				vim.notify("Cannot compare buffer with itself", vim.log.levels.WARN)
				return
			end

			vim.schedule(function()
				vim.cmd("only")
				vim.cmd("edit " .. vim.fn.fnameescape(first_buffer.path))
				vim.cmd("diffthis")
				vim.cmd("vsplit " .. vim.fn.fnameescape(choice2.path))
				vim.cmd("diffthis")

				vim.notify(
					"Comparing: " .. first_buffer.filename .. " ↔ " .. choice2.filename,
					vim.log.levels.INFO
				)
			end)
		end)
	end)
end

-- Main compare function with picker detection
M.compare_buffers = function()
	local picker_type, picker = get_picker()

	if picker_type == "fzf-lua" then
		compare_buffers_fzf()
	elseif picker_type == "telescope" then
		compare_buffers_telescope()
	else
		compare_buffers_vim()
	end
end

-- Git diff with fzf-lua
local function git_diff_fzf()
	local fzf = require("fzf-lua")
	local buffers = get_buffers()

	if #buffers < 2 then
		vim.notify("Need at least 2 buffers to compare", vim.log.levels.WARN)
		return
	end

	local first_file = nil

	local function make_entries(buffers)
		local entries = {}
		for _, buf in ipairs(buffers) do
			table.insert(entries, buf.filename)
		end
		return entries
	end

	-- First picker
	fzf.fzf_exec(make_entries(buffers), {
		prompt = "Git Diff - Select First File> ",
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end

				local selection = selected[1]
				for _, buf in ipairs(buffers) do
					if buf.filename == selection then
						first_file = buf.path
						break
					end
				end

				if not first_file then
					return
				end

				-- Second picker with preview
				vim.schedule(function()
					fzf.fzf_exec(make_entries(buffers), {
						prompt = "Git Diff - Select Second File> ",
						previewer = "builtin",
						preview = fzf.shell.raw_preview_action_cmd(function(items)
							local second_file = nil
							for _, buf in ipairs(buffers) do
								if buf.filename == items[1] then
									second_file = buf.path
									break
								end
							end
							if second_file then
								return string.format(
									"git diff --no-index --color=always %s %s",
									vim.fn.shellescape(first_file),
									vim.fn.shellescape(second_file)
								)
							end
							return "echo 'Select a file'"
						end),
						actions = {
							["default"] = function(selected2)
								if not selected2 or #selected2 == 0 then
									return
								end

								local second_file = nil
								for _, buf in ipairs(buffers) do
									if buf.filename == selected2[1] then
										second_file = buf.path
										break
									end
								end

								if not second_file then
									return
								end

								vim.schedule(function()
									local diff_output = vim.fn.system({
										"git",
										"diff",
										"--no-index",
										first_file,
										second_file,
									})

									vim.cmd("enew")
									local buf = vim.api.nvim_get_current_buf()
									vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(diff_output, "\n"))
									vim.bo[buf].buftype = "nofile"
									vim.bo[buf].bufhidden = "wipe"
									vim.bo[buf].filetype = "diff"
									vim.bo[buf].modifiable = false

									local f1 = vim.fn.fnamemodify(first_file, ":t")
									local f2 = vim.fn.fnamemodify(second_file, ":t")
									vim.api.nvim_buf_set_name(buf, "diff: " .. f1 .. " ↔ " .. f2)
								end)
							end,
						},
					})
				end)
			end,
		},
	})
end

-- Git diff with telescope (fallback)
local function git_diff_telescope()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	local buffers = get_buffers()
	if #buffers < 2 then
		vim.notify("Need at least 2 buffers to compare", vim.log.levels.WARN)
		return
	end

	local first_file = nil

	pickers
		.new({}, {
			prompt_title = "Git Diff - Select First File",
			finder = finders.new_table({
				results = buffers,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.filename,
						ordinal = entry.filename,
						path = entry.path,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					first_file = selection.value.path

					vim.schedule(function()
						pickers
							.new({}, {
								prompt_title = "Git Diff - Select Second File",
								finder = finders.new_table({
									results = buffers,
									entry_maker = function(entry)
										return {
											value = entry,
											display = entry.filename,
											ordinal = entry.filename,
											path = entry.path,
										}
									end,
								}),
								sorter = conf.generic_sorter({}),
								previewer = previewers.new_termopen_previewer({
									get_command = function(entry)
										return {
											"git",
											"diff",
											"--no-index",
											"--color=always",
											first_file,
											entry.value.path,
										}
									end,
								}),
								attach_mappings = function(prompt_bufnr2, map2)
									actions.select_default:replace(function()
										local selection2 = action_state.get_selected_entry()
										actions.close(prompt_bufnr2)

										vim.schedule(function()
											local diff_output = vim.fn.system({
												"git",
												"diff",
												"--no-index",
												first_file,
												selection2.value.path,
											})

											vim.cmd("enew")
											local buf = vim.api.nvim_get_current_buf()
											vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(diff_output, "\n"))
											vim.bo[buf].buftype = "nofile"
											vim.bo[buf].bufhidden = "wipe"
											vim.bo[buf].filetype = "diff"
											vim.bo[buf].modifiable = false

											local f1 = vim.fn.fnamemodify(first_file, ":t")
											local f2 = vim.fn.fnamemodify(selection2.value.path, ":t")
											vim.api.nvim_buf_set_name(buf, "diff: " .. f1 .. " ↔ " .. f2)
										end)
									end)
									return true
								end,
							})
							:find()
					end)
				end)
				return true
			end,
		})
		:find()
end

-- Git diff with vim.ui.select fallback
local function git_diff_vim()
	local buffers = get_buffers()

	if #buffers < 2 then
		vim.notify("Need at least 2 buffers to compare", vim.log.levels.WARN)
		return
	end

	local first_file = nil

	vim.ui.select(buffers, {
		prompt = "Git Diff - Select First File:",
		format_item = function(buf)
			return buf.filename
		end,
	}, function(choice1)
		if not choice1 then
			return
		end
		first_file = choice1.path

		vim.ui.select(buffers, {
			prompt = "Git Diff - Select Second File:",
			format_item = function(buf)
				return buf.filename
			end,
		}, function(choice2)
			if not choice2 then
				return
			end

			vim.schedule(function()
				local diff_output = vim.fn.system({
					"git",
					"diff",
					"--no-index",
					first_file,
					choice2.path,
				})

				vim.cmd("enew")
				local buf = vim.api.nvim_get_current_buf()
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(diff_output, "\n"))
				vim.bo[buf].buftype = "nofile"
				vim.bo[buf].bufhidden = "wipe"
				vim.bo[buf].filetype = "diff"
				vim.bo[buf].modifiable = false

				local f1 = vim.fn.fnamemodify(first_file, ":t")
				local f2 = vim.fn.fnamemodify(choice2.path, ":t")
				vim.api.nvim_buf_set_name(buf, "diff: " .. f1 .. " ↔ " .. f2)
			end)
		end)
	end)
end

-- Main git diff function with picker detection
M.git_diff_files = function()
	local picker_type, picker = get_picker()

	if picker_type == "fzf-lua" then
		git_diff_fzf()
	elseif picker_type == "telescope" then
		git_diff_telescope()
	else
		git_diff_vim()
	end
end

-- Exit diff mode
M.diff_off = function()
	vim.cmd("diffoff!")
	vim.notify("Diff mode disabled", vim.log.levels.INFO)
end

-- Setup keymaps
M.setup = function()
	-- Compare two buffers in diff mode
	vim.keymap.set("n", "<leader>dc", M.compare_buffers, { desc = "Compare two buffers (diff mode)" })

	-- Compare using git diff
	vim.keymap.set("n", "<leader>dg", M.git_diff_files, { desc = "Git diff two files" })

	-- Exit diff mode
	vim.keymap.set("n", "<leader>do", M.diff_off, { desc = "Diff off (exit diff mode)" })

	-- Additional diff navigation keymaps (only active in diff mode)
	vim.keymap.set("n", "]c", function()
		if vim.wo.diff then
			return "]c"
		end
		return "<Plug>(GitGutterNextHunk)"
	end, { expr = true, desc = "Next diff/hunk" })

	vim.keymap.set("n", "[c", function()
		if vim.wo.diff then
			return "[c"
		end
		return "<Plug>(GitGutterPrevHunk)"
	end, { expr = true, desc = "Previous diff/hunk" })
end

return M
