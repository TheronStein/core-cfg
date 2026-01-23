-- ╓────────────────────────────────────────────────────────────╖
-- ║ Seamless Tmux/Neovim/WezTerm Navigation                   ║
-- ║ Supports: Normal, Insert, Visual, and Terminal modes      ║
-- ║ Works with Claude Code terminal splits                    ║
-- ╙────────────────────────────────────────────────────────────╜

local M = {}
local mod_string = "<C-S-"
-- ─────────────────────────────────────────────────────────────
-- Environment Detection
-- ─────────────────────────────────────────────────────────────

--- Check if we're running inside tmux
---@return boolean
local function is_tmux()
	return vim.env.TMUX ~= nil
end

--- Check if tmux pane is at the specified edge
---@param direction string "left"|"right"|"up"|"down"
---@return boolean
local function is_tmux_at_edge(direction)
	if not is_tmux() then
		return false
	end

	local handle =
		io.popen("tmux display-message -p '#{pane_at_left}:#{pane_at_right}:#{pane_at_top}:#{pane_at_bottom}'")
	if not handle then
		return false
	end

	local result = handle:read("*a")
	handle:close()

	local left, right, top, bottom = result:match("(%d+):(%d+):(%d+):(%d+)")
	if not left then
		return false
	end

	local edge_map = {
		left = left == "1",
		right = right == "1",
		up = top == "1",
		down = bottom == "1",
	}

	return edge_map[direction] or false
end

-- ─────────────────────────────────────────────────────────────
-- Navigation Logic
-- ─────────────────────────────────────────────────────────────

--- Signal the terminal emulator to navigate its panes
--- Used when at vim edge and not in tmux
---@param direction string "left"|"right"|"up"|"down"
local function signal_terminal(direction)
	-- Direction to WezTerm/Kitty direction names
	local dir_map = {
		left = "Left",
		right = "Right",
		up = "Up",
		down = "Down",
	}
	local term_dir = dir_map[direction]

	-- Detect terminal type
	local term_program = vim.env.TERM_PROGRAM or ""

	if term_program == "WezTerm" then
		-- WezTerm: Use OSC 1337 SetUserVar
		local encoded = vim.fn.system("echo -n '" .. term_dir .. "' | base64"):gsub("\n", "")
		io.write("\027]1337;SetUserVar=navigate_wezterm=" .. encoded .. "\007")
		io.flush()
	elseif term_program == "kitty" then
		-- Kitty: Try remote control first, fallback to CSI
		local kitty_listen = vim.env.KITTY_LISTEN_ON
		if kitty_listen and kitty_listen ~= "" then
			local kitty_dir_map = { Up = "top", Down = "bottom", Left = "left", Right = "right" }
			vim.fn.system("kitty @ focus-window --match 'neighbor:" .. kitty_dir_map[term_dir] .. "' 2>/dev/null")
		else
			-- Fallback to CSI arrows
			local csi_map = { Up = "\027[1;6A", Down = "\027[1;6B", Left = "\027[1;6D", Right = "\027[1;6C" }
			io.write(csi_map[term_dir])
			io.flush()
		end
	elseif term_program == "ghostty" then
		-- Ghostty: CSI arrows
		local csi_map = { Up = "\027[1;6A", Down = "\027[1;6B", Left = "\027[1;6D", Right = "\027[1;6C" }
		io.write(csi_map[term_dir])
		io.flush()
	end
end

--- Navigate between vim windows, tmux panes, and WezTerm panes
--- Handles terminal mode properly for Claude Code integration
---@param direction string "left"|"right"|"up"|"down"
local function navigate(direction)
	-- Map direction to vim wincmd keys
	local vim_direction = {
		left = "h",
		down = "j",
		up = "k",
		right = "l",
	}

	-- Get current window before attempting navigation
	local win_before = vim.api.nvim_get_current_win()

	-- Try to move within vim
	vim.cmd("wincmd " .. vim_direction[direction])

	-- Check if we actually moved
	local win_after = vim.api.nvim_get_current_win()

	-- If we didn't move in vim, try external navigation
	if win_before == win_after then
		if is_tmux() then
			-- In tmux: use smart-navigate.sh which handles tmux panes and terminal signaling
			local tmux_direction = {
				left = "L",
				down = "D",
				up = "U",
				right = "R",
			}
			-- Call smart-navigate.sh which handles edge detection and terminal signaling
			-- Pass --from-vim to skip vim detection (we already know we're at vim edge)
			local tmux_conf = vim.env.TMUX_CONF or vim.fn.expand("~/.tmux")
			vim.fn.system(tmux_conf .. "/utils/navigation/smart-navigate.sh " .. tmux_direction[direction] .. " --from-vim")
		else
			-- Not in tmux: signal terminal directly to navigate its panes
			signal_terminal(direction)
		end
	end
end

local nav_keys = {
	up = mod_string .. "w>",
	down = mod_string .. "s>",
	left = mod_string .. "a>",
	right = mod_string .. "d>",
}

--- Create a navigation function for terminal mode
--- Exits terminal mode first, then navigates
---@param direction string "left"|"right"|"up"|"down"
---@return function
local function terminal_navigate(direction)
	return function()
		-- Exit terminal mode first
		local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
		vim.api.nvim_feedkeys(keys, "n", false)
		-- Schedule navigation after terminal mode exit
		vim.schedule(function()
			navigate(direction)
		end)
	end
end

--- Create a navigation function for normal/insert/visual modes
---@param direction string "left"|"right"|"up"|"down"
---@return function
local function normal_navigate(direction)
	return function()
		navigate(direction)
	end
end

-- ─────────────────────────────────────────────────────────────
-- Keybind Setup
-- ─────────────────────────────────────────────────────────────

function M.setup()
	local map = vim.keymap.set
	local opts = { noremap = true, silent = true }

	-- ═══════════════════════════════════════════════════════════
	-- WASD Navigation (Primary - Ergonomic Layout)
	-- Ctrl+Shift+W/A/S/D for Up/Left/Down/Right
	-- ═══════════════════════════════════════════════════════════

	-- Normal, Insert, Visual modes
	map(
		{ "n", "i", "v" },
		nav_keys.up,
		normal_navigate("up"),
		vim.tbl_extend("force", opts, { desc = "Navigate Up (tmux aware)" })
	)
	map(
		{ "n", "i", "v" },
		nav_keys.left,
		normal_navigate("left"),
		vim.tbl_extend("force", opts, { desc = "Navigate Left (tmux aware)" })
	)
	map(
		{ "n", "i", "v" },
		nav_keys.down,
		normal_navigate("down"),
		vim.tbl_extend("force", opts, { desc = "Navigate Down (tmux aware)" })
	)
	map(
		{ "n", "i", "v" },
		nav_keys.right,
		normal_navigate("right"),
		vim.tbl_extend("force", opts, { desc = "Navigate Right (tmux aware)" })
	)

	-- Terminal mode (special handling for Claude Code split)
	map(
		"t",
		nav_keys.up,
		terminal_navigate("up"),
		vim.tbl_extend("force", opts, { desc = "Navigate Up from terminal" })
	)
	map(
		"t",
		nav_keys.left,
		terminal_navigate("left"),
		vim.tbl_extend("force", opts, { desc = "Navigate Left from terminal" })
	)
	map(
		"t",
		nav_keys.down,
		terminal_navigate("down"),
		vim.tbl_extend("force", opts, { desc = "Navigate Down from terminal" })
	)
	map(
		"t",
		nav_keys.right,
		terminal_navigate("right"),
		vim.tbl_extend("force", opts, { desc = "Navigate Right from terminal" })
	)

	-- ═══════════════════════════════════════════════════════════
	-- IJKL Navigation (Alternative - Vim-style Layout)
	-- Ctrl+Shift+I/J/K/L for Up/Left/Down/Right
	-- ═══════════════════════════════════════════════════════════

	-- -- Normal, Insert, Visual modes
	-- map(
	-- 	{ "n", "i", "v" },
	-- 	"<C-S-i>",
	-- 	normal_navigate("up"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Up (tmux aware)" })
	-- )
	-- map(
	-- 	{ "n", "i", "v" },
	-- 	"<C-S-j>",
	-- 	normal_navigate("left"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Left (tmux aware)" })
	-- )
	-- map(
	-- 	{ "n", "i", "v" },
	-- 	"<C-S-k>",
	-- 	normal_navigate("down"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Down (tmux aware)" })
	-- )
	-- map(
	-- 	{ "n", "i", "v" },
	-- 	"<C-S-l>",
	-- 	normal_navigate("right"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Right (tmux aware)" })
	-- )
	--
	-- -- Terminal mode
	-- map("t", "<C-S-i>", terminal_navigate("up"), vim.tbl_extend("force", opts, { desc = "Navigate Up from terminal" }))
	-- map(
	-- 	"t",
	-- 	"<C-S-j>",
	-- 	terminal_navigate("left"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Left from terminal" })
	-- )
	-- map(
	-- 	"t",
	-- 	"<C-S-k>",
	-- 	terminal_navigate("down"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Down from terminal" })
	-- )
	-- map(
	-- 	"t",
	-- 	"<C-S-l>",
	-- 	terminal_navigate("right"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Right from terminal" })
	-- )
	--
	-- ═══════════════════════════════════════════════════════════
	-- Alt+Arrow Navigation (Universal fallback)
	-- Works when Ctrl+Shift combinations are intercepted by terminal
	-- ═══════════════════════════════════════════════════════════

	-- -- Normal, Insert, Visual modes
	-- map({ "n", "i", "v" }, "<M-Up>", normal_navigate("up"), vim.tbl_extend("force", opts, { desc = "Navigate Up" }))
	-- map(
	-- 	{ "n", "i", "v" },
	-- 	"<M-a>",
	-- 	normal_navigate("left"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Left" })
	-- )
	-- map(
	-- 	{ "n", "i", "v" },
	-- 	"<M->",
	-- 	normal_navigate("down"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Down" })
	-- )
	-- map(
	-- 	{ "n", "i", "v" },
	-- 	"<M-Right>",
	-- 	normal_navigate("right"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Right" })
	-- )
	--
	-- -- Terminal mode
	-- map("t", "<M-Up>", terminal_navigate("up"), vim.tbl_extend("force", opts, { desc = "Navigate Up from terminal" }))
	-- map(
	-- 	"t",
	-- 	"<M-Left>",
	-- 	terminal_navigate("left"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Left from terminal" })
	-- )
	-- map(
	-- 	"t",
	-- 	"<M-Down>",
	-- 	terminal_navigate("down"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Down from terminal" })
	-- )
	-- map(
	-- 	"t",
	-- 	"<M-Right>",
	-- 	terminal_navigate("right"),
	-- 	vim.tbl_extend("force", opts, { desc = "Navigate Right from terminal" })
	-- )
	--
	-- ═══════════════════════════════════════════════════════════
	-- Quick escape from terminal mode
	-- ═══════════════════════════════════════════════════════════

	map("t", "<C-\\><C-\\>", "<C-\\><C-n>", vim.tbl_extend("force", opts, { desc = "Exit terminal mode" }))
	map("t", "<Esc><Esc>", "<C-\\><C-n>", vim.tbl_extend("force", opts, { desc = "Exit terminal mode (double Esc)" }))

	-- ═══════════════════════════════════════════════════════════
	-- Claude Code specific: Quick focus toggle
	-- ═══════════════════════════════════════════════════════════

	-- Jump to Claude Code window (rightmost) or back to code
	map({ "n", "t" }, "<localleader><tab>", function()
		local wins = vim.api.nvim_tabpage_list_wins(0)
		if #wins < 2 then
			return
		end

		local current_win = vim.api.nvim_get_current_win()
		local current_buf = vim.api.nvim_win_get_buf(current_win)
		local current_buftype = vim.bo[current_buf].buftype

		-- If we're in a terminal (Claude Code), go to the first non-terminal window
		if current_buftype == "terminal" then
			for _, win in ipairs(wins) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].buftype ~= "terminal" then
					-- Exit terminal mode first if needed
					if vim.fn.mode() == "t" then
						local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
						vim.api.nvim_feedkeys(keys, "n", false)
					end
					vim.schedule(function()
						vim.api.nvim_set_current_win(win)
					end)
					return
				end
			end
		else
			-- We're in code, go to the terminal window (Claude Code)
			for _, win in ipairs(wins) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].buftype == "terminal" then
					vim.api.nvim_set_current_win(win)
					-- Enter terminal mode
					vim.cmd("startinsert")
					return
				end
			end
		end
	end, vim.tbl_extend("force", opts, { desc = "Toggle focus: Claude Code <-> Code" }))
end

-- ─────────────────────────────────────────────────────────────
-- Exports
-- ─────────────────────────────────────────────────────────────

M.navigate = navigate
M.is_tmux = is_tmux

return M
