local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- Configuration for different key types and locations
M.ssh_keys = {
	"~/.ssh/id_rsa",
	"~/.ssh/id_ed25519",
	"~/.ssh/id_ecdsa",
}

-- Function to add all available SSH keys
function M.add_all_ssh_keys()
	local commands = {}

	-- Start SSH agent if needed
	table.insert(commands, act.SendString('eval "$(ssh-agent -s)" 2>/dev/null\n'))
	table.insert(commands, act.Sleep(200))

	-- Try to add each key
	for _, key in ipairs(M.ssh_keys) do
		table.insert(commands, act.SendString("ssh-add " .. key .. " 2>/dev/null\n"))
		table.insert(commands, act.Sleep(100))
	end

	return act.Multiple(commands)
end

-- Function to setup complete environment for secure sessions
function M.setup_secure_environment()
	return act.Multiple({
		-- SSH agent
		act.SendString('eval "$(ssh-agent -s)" 2>/dev/null\n'),
		act.Sleep(200),

		-- Add SSH keys
		M.add_all_ssh_keys(),

		-- GPG setup
		act.SendString("export GPG_TTY=$(tty)\n"),
		act.SendString("gpg-connect-agent updatestartuptty /bye 2>/dev/null\n"),

		-- Optional: Load any custom environment
		act.SendString("source ~/.ssh_env 2>/dev/null || true\n"),
	})
end

return M
