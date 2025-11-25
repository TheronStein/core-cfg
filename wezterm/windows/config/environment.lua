-- set_environment_variables = env_vars,
-- unix_domains = unix_domains,
-- ssh_domains = ssh_domains,

-- local env_helper = require("util.env_builder")
set_environment_variables = require("utils.core.env_builder").init()

ssh_domains = {
	{
		-- This name identifies the domain
		name = "chaoscore",
		-- The hostname or address to connect to. Will be used to match settings
		-- from your ssh config file
		remote_address = "chaoscore.org",
		-- The username to use on the remote host
		username = "theron",
		-- Use WezTerm's built-in multiplexing
		multiplexing = "WezTerm",
		remote_wezterm_path = "/usr/local/bin/wezterm",
	},
	{
		-- This name identifies the domain
		name = "rampage",
		-- The hostname or address to connect to. Will be used to match settings
		-- from your ssh config file
		remote_address = "chaoscore.org",
		-- The username to use on the remote host
		username = "rampage",
		-- Use WezTerm's built-in multiplexing
		multiplexing = "WezTerm",
		remote_wezterm_path = "/usr/local/bin/wezterm",
	},

-- local unix_domains = {
-- 	{
-- 		name = "ASUSFX",
-- 		socket_path = runtime_dir .. "/asusfx.sock",
-- 	},
-- 	{
-- 		name = "CORE",
-- 		socket_path = runtime_dir .. "/core.sock",
-- 	},
-- 	{
-- 		name = "XRX",
-- 		socket_path = runtime_dir .. "/xrx.sock",
-- 	},
-- }

}

return {
	set_environment_variables = require("utils.core.env_builder").init(),
	-- unix_domains = unix_domains,
	ssh_domains = ssh_domains,
}
