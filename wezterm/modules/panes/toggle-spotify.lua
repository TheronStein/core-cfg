local M = {}

local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

-- Default configuration for toggleable panes
local default_opts = {
  direction = "Right", -- Direction to split the pane
  size = { Percent = 30 }, -- Size of the split pane
  launch_command = {
    "zsh",
    "-i",
    "-c",
    "exec /home/theron/.core/.sys/tools/rust/cargo/bin/spotify_player",
  }, -- Command to run on first launch (nil = default shell)
  zoom = {
    auto_zoom_toggle_terminal = false, -- Automatically zoom toggle terminal pane
    auto_zoom_invoker_pane = false, -- Automatically zoom invoker pane
    remember_zoomed = true, -- Re-zoom the toggle pane if it was zoomed before switching away
  },
}

local session_states = {} -- { [session_id] = { [window_id] = { pane_id = -1, invoker_id = -1, invoker_tab_id = -1, zoomed = false }, ... }, ... }

-- Get state key based on configuration
local function get_state_key(window, opts)
  if opts.global_across_windows then
    return "global"
  else
    return window:window_id()
  end
end

-- Get or initialize state for a session and window
local function get_session_state(session_id, window, opts)
  -- Initialize session storage if needed
  if not session_states[session_id] then
    session_states[session_id] = {}
  end

  local key = get_state_key(window, opts)
  if not session_states[session_id][key] then
    wezterm.log_info(
      "Initializing toggle_terminal state for session: " .. session_id .. ", key: " .. tostring(key)
    )
    session_states[session_id][key] = {
      pane_id = -1,
      invoker_id = -1,
      invoker_tab_id = -1,
      zoomed = false,
    }
  end
  return session_states[session_id][key]
end

--- Resets the state
local function reset_window_state(state)
  state.pane_id = -1
  state.invoker_id = -1
  state.invoker_tab_id = -1
  state.zoomed = false
end

-- Find the terminal pane in any tab of the current window
local function find_spotify_pane_in_window(window, spotify_pane_id)
  local mux_window = window:mux_window()
  for _, tab in ipairs(mux_window:tabs()) do
    for _, pane in ipairs(tab:panes()) do
      if pane:pane_id() == spotify_pane_id then
        return pane, tab
      end
    end
  end
  return nil, nil
end

local function toggle_spotify_pane(session_id, opts, window, pane)
  -- Merge with defaults
  opts = opts or default_opts
  local config = {}
  for k, v in pairs(default_opts) do
    if type(v) == "table" then
      config[k] = {}
      for k2, v2 in pairs(v) do
        config[k][k2] = (opts[k] and opts[k][k2]) or v2
      end
    else
      config[k] = opts[k] or v
    end
  end

  -- Validate pane and tab
  if not pane then
    wezterm.log_error("Invalid pane passed to toggle_spotify_pane")
    return
  end

  local current_pane_id = pane:pane_id()
  local current_tab_obj = pane:tab()

  if not current_tab_obj then
    wezterm.log_error("Could not get tab for pane " .. current_pane_id)
    return
  end

  local current_tab_id = current_tab_obj:tab_id()

  wezterm.log_info(
    "Toggle spotify[" .. session_id .. "] action triggered in tab_id: " .. current_tab_id
  )

  -- Get state for this session and window (or global)
  local state = get_session_state(session_id, window, config)

  local spotify_pane_obj = nil
  local spotify_pane_exists = false
  local spotify_tab = nil

  -- Safely check if the tracked pane ID exists
  if state.pane_id ~= -1 then
    local success, result = pcall(mux.get_pane, state.pane_id)
    if success and result then
      spotify_pane_obj = result
      spotify_pane_exists = true
      -- Find which tab it's in
      _, spotify_tab = find_spotify_pane_in_window(window, state.pane_id)
      wezterm.log_info("Found existing spotify pane ID: " .. state.pane_id)
    else
      -- Pane closed or pcall failed
      wezterm.log_info(
        "spotify pane ID " .. tostring(state.pane_id) .. " no longer exists. Resetting state."
      )
      reset_window_state(state)
    end
  end

  -- Determine behavior based on pane/tab existence
  if spotify_pane_exists then
    -- Spotify tab exists: KILL the entire tab
    wezterm.log_info("Spotify tab exists. Killing tab with ID: " .. tostring(spotify_tab:tab_id()))

    -- Activate a different tab before closing (to avoid closing the window)
    local mux_window = window:mux_window()
    local tabs = mux_window:tabs()

    -- Find a different tab to activate
    for _, tab in ipairs(tabs) do
      if tab:tab_id() ~= spotify_tab:tab_id() then
        tab:activate()
        break
      end
    end

    -- Close the spotify tab
    spotify_tab:activate()
    window:perform_action(act.CloseCurrentTab({ confirm = false }), spotify_pane_obj)

    -- Reset state
    reset_window_state(state)
    wezterm.log_info("Spotify tab closed")
  else
    -- Spotify doesn't exist: create it in a new tab
    wezterm.log_info("Spotify tab not found. Creating a new tab.")

    -- Create a new tab with spotify player
    window:perform_action(
      act.SpawnCommandInNewTab({
        args = config.launch_command,
        cwd = wezterm.home_dir .. "/.core/.sys/cfg/media/spotify_player",
      }),
      pane
    )

    -- Get the newly created tab and pane
    local new_pane = window:active_pane()
    if new_pane then
      state.pane_id = new_pane:pane_id()
      wezterm.log_info("Created new spotify tab. Pane ID: " .. state.pane_id)

      -- Load and apply the spotify template if it exists
      local tab_templates = require("modules.tabs.tab_templates")
      local templates = tab_templates.load_templates()

      if templates and templates.spotify then
        local template = templates.spotify
        wezterm.log_info("Applying spotify template")

        -- Initialize custom_tabs if needed
        if not wezterm.GLOBAL.custom_tabs then
          wezterm.GLOBAL.custom_tabs = {}
        end

        -- Apply template to the new tab
        local tab_id = tostring(window:active_tab():tab_id())
        wezterm.GLOBAL.custom_tabs[tab_id] = {
          title = template.title,
          icon_key = template.icon,
        }

        -- Apply tab color if saved
        if template.color then
          local tab_color_picker = require("modules.tabs.tab_color_picker")
          tab_color_picker.set_tab_color(tab_id, template.color)
          wezterm.log_info("Applied spotify template color: " .. template.color)
        end
      else
        wezterm.log_info("No spotify template found, using defaults")
      end
    else
      wezterm.log_error("Failed to create spotify tab")
      reset_window_state(state)
    end
  end
end

function M.create(session_id, opts)
  return function(window, pane)
    toggle_spotify_pane(session_id, opts, window, pane)
  end
end

-- Backward compatibility: default toggle_spotify function
function M.toggle_spotify(window, pane)
  toggle_spotify_pane("default", default_opts, window, pane)
end

return M
