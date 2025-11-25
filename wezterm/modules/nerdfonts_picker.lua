local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- Load icon names from file if it exists, otherwise use a curated list
local function load_icon_names()
  local data_file = wezterm.config_dir .. "/.data/wezterm_nerdfont_names.txt"
  local file = io.open(data_file, "r")

  if file then
    local icons = {}
    for line in file:lines() do
      if line and line ~= "" then
        table.insert(icons, line)
      end
    end
    file:close()
    wezterm.log_info("Loaded " .. #icons .. " nerdfonts from " .. data_file)
    return icons
  else
    wezterm.log_warn("Nerdfonts data file not found, using curated list. Run: ~/.core/.sys/configs/wezterm/scripts/scrape-nerdfonts.sh")
    -- Fallback to curated list
    return {
      "cod_terminal", "cod_file", "cod_folder", "cod_git_branch", "cod_git_commit",
      "cod_account", "cod_add", "cod_archive", "cod_arrow_down", "cod_arrow_up",
      "fa_code", "fa_folder", "fa_folder_open", "fa_file", "fa_git", "fa_github",
      "fa_home", "fa_cog", "fa_search", "fa_heart", "fa_star", "fa_check", "fa_times",
      "fa_lock", "fa_unlock", "fa_user", "fa_terminal", "fa_bug", "fa_wrench",
      "dev_git", "dev_github_badge", "dev_linux", "dev_rust", "dev_python",
      "dev_javascript", "dev_typescript", "dev_react", "dev_nodejs", "dev_docker",
      "oct_terminal", "oct_file", "oct_folder", "oct_repo", "oct_git_branch",
      "pl_left_hard_divider", "pl_right_hard_divider", "pl_left_soft_divider", "pl_right_soft_divider",
      "seti_lua", "seti_json", "seti_config", "seti_markdown",
      "md_check", "md_close", "md_folder", "md_home", "md_settings",
    }
  end
end

function M.show_picker(window, pane)
  local nf = wezterm.nerdfonts
  local icon_names = load_icon_names()
  local choices = {}

  for _, name in ipairs(icon_names) do
    -- Use pcall to safely access icons (some might not exist)
    local success, icon = pcall(function() return nf[name] end)
    if success and icon then
      table.insert(choices, {label = icon .. '  ' .. name})
    end
  end

  table.sort(choices, function(a, b)
    -- Sort by name (after the icon)
    local a_name = a.label:match('%s+(.+)$')
    local b_name = b.label:match('%s+(.+)$')
    return (a_name or a.label) < (b_name or b.label)
  end)

  wezterm.log_info("Showing " .. #choices .. " nerdfonts in picker")

  window:perform_action(
    act.InputSelector {
      title = 'Nerd Fonts (' .. #choices .. ' icons)',
      choices = choices,
      fuzzy = true,
      description = 'Select icon to copy: ',
      action = wezterm.action_callback(function(win, p, id, label)
        if label then
          local icon = label:match('^(%S+)')
          local name = label:match('%s+(.+)$')
          win:copy_to_clipboard(icon)
          win:toast_notification("WezTerm", "Copied: " .. (name or icon), nil, 2000)
        end
      end),
    },
    pane
  )
end

return M
