local M = {}

local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

-- Default configuration for toggleable panes
local default_opts = {
  direction = "Right", -- Direction to split the pane
  size = { Percent = 30 }, -- Size of the split pane
  launch_command = { "zsh", "-i", "-c", "exec /home/theron/.core/.sys/tools/rust/cargo/bin/spotify_player" }, -- Command to run on first launch (nil = default shell)
  global_across_windows = true, -- If true, show the pane
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

  -- Determine behavior based on pane existence and focus
  if spotify_pane_exists then
    -- Check if spotify pane is in the current tab
    if spotify_tab and spotify_tab:tab_id() == current_tab_id then
      -- Spotify is in current tab: kill it
      wezterm.log_info("Spotify pane is in current tab. Killing spotify pane.")

      -- Unzoom before doing anything
      current_tab_obj:set_zoomed(false)

      -- Activate the spotify pane (must be active to close it)
      spotify_pane_obj:activate()

      -- Close the current pane (which is now the spotify pane)
      window:perform_action(act.CloseCurrentPane({ confirm = false }), pane)

      -- Reset state
      reset_window_state(state)
    else
      -- Spotify is in a different tab: activate it
      wezterm.log_info("Spotify pane is in different tab. Activating it.")

      -- Track this pane as the new invoker
      state.invoker_id = current_pane_id
      state.invoker_tab_id = current_tab_id

      -- Activate the spotify pane (switches to its tab)
      spotify_pane_obj:activate()

      -- Apply zoom settings
      if
        (state.zoomed and config.zoom.remember_zoomed) or config.zoom.auto_zoom_toggle_terminal
      then
        local term_tab = spotify_pane_obj:tab()
        term_tab:set_zoomed(true)
      end
    end
  else
    -- Spotify doesn't exist: create it
    wezterm.log_info("Spotify pane not found. Creating a new one.")

    -- Track the invoker
    state.invoker_id = current_pane_id
    state.invoker_tab_id = current_tab_id

    -- Split to create spotify pane at the root of the tab
    local split_args = {
      direction = config.direction,
      size = config.size,
      top_level = true, -- Split at tab root for full height
    }

    -- Add command if specified
    if config.launch_command then
      -- Handle both string and table launch commands
      if type(config.launch_command) == "table" then
        split_args.command = { args = config.launch_command }
      else
        split_args.command = { args = { config.launch_command } }
      end
    end

    window:perform_action(act.SplitPane(split_args), pane)

    -- Get the newly created pane
    local new_pane = window:active_pane()
    if new_pane then
      state.pane_id = new_pane:pane_id()
      wezterm.log_info(
        "Created new spotify pane ["
          .. session_id
          .. "]. ID: "
          .. state.pane_id
          .. ", Invoker ID: "
          .. state.invoker_id
      )

      -- Return focus to invoker pane
      pane:activate()

      -- Optionally zoom the invoker after creation
      if config.zoom.auto_zoom_invoker_pane then
        current_tab_obj:set_zoomed(true)
      end
    else
      wezterm.log_error("Failed to create spotify pane [" .. session_id .. "]")
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
