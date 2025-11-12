local wezterm = require 'wezterm'

local function setup(config)
  -- Optional: Set update interval to 1 second (default anyway)
  config.status_update_interval = 1000

  -- Hook the update-status event
  wezterm.on('update-status', function(window, pane)
    local effective_config = window:effective_config()

    -- Current domain
    local domain = pane:get_domain_name() or 'Unknown'

    -- Prefer EGL
    local egl = effective_config.prefer_egl and 'Yes' or 'No'

    -- Wayland enabled/disabled
    local wayland = effective_config.enable_wayland and 'Enabled' or 'Disabled'

    -- Target FPS (no runtime FPS API; this is the configured max)
    local fps = effective_config.max_fps or 60

    -- Frontend
    local frontend = effective_config.front_end or 'Unknown'

    -- GPU info
    local gpus = wezterm.gui.enumerate_gpus()
    local gpu_info = 'Unknown'
    if #gpus > 0 then
      if frontend == 'WebGpu' and effective_config.webgpu_preferred_adapter then
        -- Match preferred adapter for WebGpu
        local preferred = effective_config.webgpu_preferred_adapter
        for _, gpu in ipairs(gpus) do
          if gpu.device == preferred.device and gpu.backend == preferred.backend then
            gpu_info = gpu.name
            break
          end
        end
      else
        -- Fallback to first GPU
        gpu_info = gpus[1].name
      end
    end

    -- System RAM usage (e.g., "Used: 8G / 16G")
    local ram = 'Unknown'
    local success, stdout, stderr = wezterm.run_child_process { 'free', '-h' }
    if success then
      for line in stdout:gmatch("[^\r\n]+") do
        if line:match("^Mem:") then
          local used = line:match("%S+%s+%S+%s+(%S+)")
          local total = line:match("(%S+)%s+%S+%s+%S+%s+%S+%s+%S+%s+%S+")
          ram = string.format('Used: %s / %s', used, total)
          break
        end
      end
    end

    -- System CPU usage (approximate % from top; assumes Linux)
    local cpu = 'Unknown'
    local success, stdout, stderr = wezterm.run_child_process { 'top', '-bn1' }
    if success then
      for line in stdout:gmatch("[^\r\n]+") do
        if line:match("^%%Cpu") then
          local usage = line:match("%%Cpu%(s%):%s+(%d+%.%d+) us")
          cpu = usage .. '%'
          break
        end
      end
    end

    -- Format and set the status (use wezterm.format for colors/styles if desired)
    local status = wezterm.format {
      { Text = string.format('Domain: %s | EGL: %s | Wayland: %s | FPS (max): %d | Frontend: %s | GPU: %s | RAM: %s | CPU: %s',
        domain, egl, wayland, fps, frontend, gpu_info, ram, cpu) },
    }
    window:set_right_status(status)
  end)
end

return setup
