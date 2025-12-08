local wezterm = require("wezterm")
local paths = require("utils.paths")
local fio = require("utils.file_io")

local M = {}

-- File to persist tab colors
local COLORS_FILE = paths.TAB_COLORS_FILE

-- Count table entries
local function count_table(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

-- Initialize global color cache if not exists
local function ensure_color_cache()
  if not wezterm.GLOBAL.tab_colors then
    wezterm.GLOBAL.tab_colors = M.load_colors_from_file()
    wezterm.log_info(
      "Initialized tab color cache with " .. count_table(wezterm.GLOBAL.tab_colors) .. " colors"
    )
  end
end

-- Load saved tab colors from JSON file (internal use only)
function M.load_colors_from_file()
  local file = io.open(COLORS_FILE, "r")
  if not file then
    return {}
  end

  local content = file:read("*all")
  file:close()

  if not content or content == "" then
    return {}
  end

  local success, colors = pcall(function()
    return wezterm.json_parse(content)
  end)

  return success and colors or {}
end

-- Load colors (uses cache)
function M.load_colors()
  ensure_color_cache()
  return wezterm.GLOBAL.tab_colors
end

-- Save tab colors to JSON file
function M.save_colors(colors)
  fio.ensure_folder_exists(paths.TABS_DATA)

  local file = io.open(COLORS_FILE, "w")
  if not file then
    wezterm.log_error("Failed to open colors file for writing: " .. COLORS_FILE)
    return false
  end

  local json = wezterm.json_encode(colors)
  file:write(json)
  file:close()

  -- Update the cache
  wezterm.GLOBAL.tab_colors = colors

  return true
end

-- Get color for a specific tab
function M.get_tab_color(tab_id)
  local colors = M.load_colors()
  return colors[tostring(tab_id)]
end

-- Set color for a specific tab
function M.set_tab_color(tab_id, color)
  local colors = M.load_colors()
  colors[tostring(tab_id)] = color
  M.save_colors(colors)

  wezterm.log_info("Set tab color for " .. tab_id .. ": " .. tostring(color))

  -- Emit event for metadata persistence
  local tab = wezterm.mux.get_tab(tab_id)
  if tab then
    wezterm.emit("tab-color-changed", tab)
  end
end

-- Remove color for a specific tab
function M.clear_tab_color(tab_id)
  local colors = M.load_colors()
  colors[tostring(tab_id)] = nil
  M.save_colors(colors)

  wezterm.log_info("Cleared tab color for " .. tab_id)
end

-- Show the color picker browser (bash script with preview)
function M.show_color_picker(window, pane)
  local tab = window:active_tab()
  if not tab then
    return
  end

  local tab_id = tostring(tab:tab_id())

  -- Get current tab metadata for preview
  local tab_meta = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]
  local title = (tab_meta and tab_meta.title) or "Tab " .. tab_id
  local icon = (tab_meta and tab_meta.icon_key) or ""

  -- Check if in tmux workspace
  local tmux_workspace = tab_meta and tab_meta.tmux_workspace

  -- Create a callback file for the browser to write the result
  local callback_file = paths.TABS_DATA .. "/color-callback-" .. tab_id .. ".tmp"

  -- Launch the color picker browser
  window:perform_action(
    wezterm.action.SpawnCommandInNewTab({
      args = {
        paths.WEZTERM_SCRIPTS .. "/tab-color-browser/color-browser.sh",
        tab_id,
        title,
        icon,
        tmux_workspace or "",
        callback_file,
      },
    }),
    pane
  )

  -- Start watching for the callback file
  wezterm.time.call_after(0.5, function()
    M.watch_for_color_selection(window, tab_id, callback_file, 0)
  end)
end

-- Watch for color selection result from browser
function M.watch_for_color_selection(window, tab_id, callback_file, iterations)
  -- Max 60 iterations = 30 seconds
  if iterations > 60 then
    -- Cleanup and give up
    os.remove(callback_file)
    return
  end

  local file = io.open(callback_file, "r")
  if file then
    local color = file:read("*line")
    file:close()
    os.remove(callback_file)

    if color and color ~= "" then
      -- Save the color
      if color == "CLEAR" then
        M.clear_tab_color(tab_id)
        window:toast_notification("Tab Color", "Cleared custom color", nil, 2000)
      else
        M.set_tab_color(tab_id, color)
        window:toast_notification("Tab Color", "Set color to " .. color, nil, 2000)
      end

      -- Close the color picker tab to return to the original tab
      -- This causes a natural redraw showing the new color
      wezterm.time.call_after(0.2, function()
        -- Find and close the color picker tab
        local mux_window = window:mux_window()
        if mux_window then
          for _, tab in ipairs(mux_window:tabs()) do
            local panes = tab:panes()
            if #panes > 0 then
              local pane = panes[1]
              local process = pane:get_foreground_process_name()
              if process and process:match("color%-browser%.sh") then
                -- Close this tab
                tab:activate()
                wezterm.time.call_after(0.05, function()
                  window:perform_action(wezterm.action.CloseCurrentTab({ confirm = false }), pane)
                end)
                break
              end
            end
          end
        end
      end)
    end
  else
    -- File doesn't exist yet, check again in 0.5s
    wezterm.time.call_after(0.5, function()
      M.watch_for_color_selection(window, tab_id, callback_file, iterations + 1)
    end)
  end
end

-- Apply tab color (called from update-status event or format-tab-title)
-- Returns the color to use, or nil if no custom color
-- Priority: tmux workspace color > custom tab color > nil
function M.get_effective_tab_color(tab)
  local tab_id = tostring(tab.tab_id)
  local tab_meta = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]

  -- Priority 1: tmux workspace color (highest priority)
  if tab_meta and tab_meta.tmux_workspace_color then
    return tab_meta.tmux_workspace_color
  end

  -- Priority 2: custom tab color
  return M.get_tab_color(tab_id)
end

return M
