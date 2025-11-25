local wezterm = require("wezterm")

return {
	update = function(window)
		local pane = window:active_pane()
		if not pane then
			return wezterm.hostname()
		end

		local cwd_uri = pane:get_current_working_dir()
		local hostname = ""

		if cwd_uri == nil then
			hostname = wezterm.hostname()
		elseif type(cwd_uri) == "userdata" then
			hostname = cwd_uri.host or wezterm.hostname()
		else
			cwd_uri = cwd_uri:sub(8)
			local slash = cwd_uri:find("/")
			if slash then
				hostname = cwd_uri:sub(1, slash - 1)
			end
		end

		local dot = hostname:find("[.]")
		if dot then
			hostname = hostname:sub(1, dot - 1)
		end

		return hostname
	end,
}

-- local docker_name = hostname:find('docker-')
-- if docker_name then
--   hostname = hostname:sub(8)
--   local icon = wezterm.nerdfonts.md_docker
--   util.overwrite_icon(opts, icon)
--   return hostname
-- end
--
--     if opts.icons_enabled then
-- if hostname = 'arch-asusfx' then
--       local icon = wezterm.nerdfonts.linux_archlinux
-- elseif hostname = 'chaoscore' then
--       local icon = ' '  -- Custom icon for chaoscore
-- else
--       local icon = opts.domain_to_icon.default
-- end
--
