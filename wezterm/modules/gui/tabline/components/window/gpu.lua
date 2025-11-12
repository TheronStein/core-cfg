local wezterm = require('wezterm')
local custom_icons = require('modules.custom_icons')

local last_update_time = 0
local last_result = ''

return {
  default_opts = {
    throttle = 10,
    icon = custom_icons.md_graphics_card,
    show_label = false,
  },
  update = function(window, opts)
    local current_time = os.time()
    if current_time - last_update_time < opts.throttle then
      return last_result
    end
    
    local effective_config = window:effective_config()
    local gpus = wezterm.gui.enumerate_gpus()
    local gpu_info = 'Unknown'
    
    if #gpus > 0 then
      local frontend = effective_config.front_end or 'Unknown'
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
    
    last_update_time = current_time
    last_result = gpu_info
    
    if opts.show_label then
      return 'GPU: ' .. gpu_info
    else
      return gpu_info
    end
  end,
}
