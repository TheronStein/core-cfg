local wezterm = require("wezterm")
local act = wezterm.action
local M = {}

-- Reference to session manager for navigation
local session_manager = nil

-- Try to load optional modules
local function safe_require(module_name)
	local ok, mod = pcall(require, module_name)
	return ok and mod or nil
end

local tab_templates = safe_require("modules.tabs.tab_templates")
local bookmarks = safe_require("modules.sessions.bookmarks")
local tab_rename = safe_require("modules.tabs.tab_rename")
local tab_tmux_browser = safe_require("modules.tabs.tab_tmux_browser")
local tmux_sessions = safe_require("modules.tmux.sessions")

-- ============================================
-- MAIN TAB MANAGEMENT MENU (FLAT STRUCTURE)
-- ============================================

function M.show_main_menu(window, pane)
	local current_tab = window:active_tab()

	local choices = {
		{ id = "session_manager", label = "← Back to Session Manager" },
		{ id = "separator0", label = "─────────────────────────────" },

		-- MANAGEMENT CATEGORY
		{ id = "management_separator", label = "─── 📑 MANAGEMENT ───" },
		{ id = "set_cwd", label = "📂 Set Tab CWD" },
		{ id = "rename", label = "✏️  Rename Tab with Icon" },
		{ id = "move", label = "📤 Move Tab to Workspace" },
		{ id = "grab", label = "📥 Grab Tab from Workspace" },

		-- TEMPLATES & TMUX CATEGORY
		{ id = "templates_separator", label = "─── 🎨 TEMPLATES & TMUX ───" },
		{ id = "template_tmux_browser", label = "📋 Browse Templates & Tmux Sessions" },
		{ id = "template_save", label = "💾 Save Current Tab as Template" },
		{ id = "template_load", label = "📂 Load Template" },
		{ id = "template_delete", label = "🗑️  Delete Template" },
		{ id = "tmux_attach", label = "📺 Attach to Tmux Session" },
		{ id = "tmux_create", label = "➕ Create New Tmux Session" },

		-- BOOKMARKS CATEGORY
		{ id = "bookmarks_separator", label = "─── 🔖 BOOKMARKS ───" },
		{ id = "bookmark_jump", label = "📍 Jump to Bookmark" },
		{ id = "bookmark_add", label = "➕ Add Bookmark" },
		{ id = "bookmark_remove", label = "➖ Remove Bookmark" },
		{ id = "bookmark_list", label = "📋 List Bookmarks" },
	}

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				-- Navigation
				if id == "session_manager" then
					if not session_manager then
						session_manager = require("modules.sessions.manager")
					end
					session_manager.show_menu(win, p)

				-- Management actions
				elseif id == "set_cwd" then
					if tab_templates then
						tab_templates.set_tab_cwd(win, p)
					end
				elseif id == "rename" then
					if tab_rename then
						tab_rename.rename_tab(win, p)
					end
				elseif id == "move" then
					if not session_manager then
						session_manager = require("modules.sessions.manager")
					end
					session_manager.move_tab_to_workspace(win, p)
				elseif id == "grab" then
					if not session_manager then
						session_manager = require("modules.sessions.manager")
					end
					session_manager.grab_tab_from_workspace(win, p)

				-- Template and Tmux actions
				elseif id == "template_tmux_browser" then
					if tab_tmux_browser then
						tab_tmux_browser.show_browser(win, p)
					end
				elseif id == "template_save" then
					if tab_templates then
						tab_templates.save_current_tab_as_template(win, p)
					end
				elseif id == "template_load" then
					if tab_templates then
						tab_templates.show_bash_list(win, p)
					end
				elseif id == "template_delete" then
					if tab_templates then
						tab_templates.delete_template(win, p)
					end
				elseif id == "tmux_attach" then
					if tmux_sessions then
						tmux_sessions.show_workspace_then_session_selector(win, p)
					end
				elseif id == "tmux_create" then
					if tmux_sessions then
						tmux_sessions.prompt_create_session(win, p)
					end

				-- Bookmark actions
				elseif id == "bookmark_jump" then
					if bookmarks then
						bookmarks.jump_to_bookmark(win, p)
					end
				elseif id == "bookmark_add" then
					if bookmarks then
						bookmarks.add_bookmark(win, p)
					end
				elseif id == "bookmark_remove" then
					if bookmarks then
						bookmarks.remove_bookmark(win, p)
					end
				elseif id == "bookmark_list" then
					if bookmarks then
						bookmarks.list_bookmarks(win, p)
					end
				end
			end),
			title = "📑 Tab Management",
			choices = choices,
			fuzzy = false,
		}),
		pane
	)
end

return M
