-- local function is_vim(pane)
-- 	return pane:get_user_vars().IS_NVIM == "true"
-- end

-- Helper function to check if we're at pane edge
local function is_vim(pane)
	-- Check if the pane is running nvim
	local process_name = pane:get_foreground_process_name()
	return process_name and (process_name:find("nvim") or process_name:find("vim"))
end
