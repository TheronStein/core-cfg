

Pane swapping/moving,

navigation functions 

outside
insdie
expanding
inside
inbetween


Grab/Send panes/tabs``

Interactive Menus for interacting with
Tabs / Workspaces

- Tabs/WOrksspaces

New
Delete
Rename

Move
Grab 


interactive bash shell windows, fzf interactively interacting with all context.



Example, swap with adjacent pane


```
local act = wezterm.action  -- Already in your file

local function swap_with_adjacent(direction)
  return wezterm.action_callback(function(window, pane)
    local tab = pane:tab()
    local panes = tab:panes()  -- List of all panes in order
    local active_idx = nil
    local target_pane = tab:get_pane_direction(direction)
    if not target_pane then
      window:toast_notification("WezTerm", "No adjacent pane in " .. direction, nil, 2000)
      return
    end

    -- Find indices of active and target panes
    for i, p in ipairs(panes) do
      if p:pane_id() == pane:pane_id() then
        active_idx = i - 1  -- 0-based
      end
      if p:pane_id() == target_pane:pane_id() then
        target_idx = i - 1
      end
    end

    if active_idx and target_idx and math.abs(active_idx - target_idx) == 1 then
      -- Simple swap if consecutive in order (common for adjacent)
      local mux = wezterm.mux
      mux.invoke_foreground_event("tab-reordered", {
        tab_id = tab:tab_id(),
        new_order = panes,  -- Rebuild order with swapped indices
      })
      -- Note: This uses a foreground event hack; for real reordering, you'd need to close/recreate or use RotatePanes for 2-pane
      -- Alternative for 2-pane: tab:perform_action(act.RotatePanes("Clockwise"), pane)
    else
      window:toast_notification("WezTerm", "Non-consecutive panes; use picker swap", nil, 2000)
    end
  end)
end

-- Add to your keys table
{
  key = "H", mods = "LEADER|SHIFT", action = swap_with_adjacent("Left"),
},
{
  key = "L", mods = "LEADER|SHIFT", action = swap_with_adjacent("Right"),
},
{
  key = "K", mods = "LEADER|SHIFT", action = swap_with_adjacent("Up"),
},
{
  key = "J", mods = "LEADER|SHIFT", action = swap_with_adjacent("Down"),
},

  ```
  a
  Desired fuctions:

- 
