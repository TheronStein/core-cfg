local home = os.getenv("HOME")

return {
	-- Default program for new panes/tabs
	-- default_prog = { "zsh", "-l" },
	default_prog = { "zsh", "-l" },
	-- Workspace launcher menu with different working directories
	launch_menu = {
		{
			label = "🐚 ZShell",
			args = { "zsh", "-l" },
			cwd = home .. "/.core/cfg/zsh",
		},
		{
			label = "💻 Work",
			args = { "zsh", "-l" },
			cwd = home .. "/.core/work",
		},

		{
			label = "🪟 Hyprland",
			args = { "zsh", "-l" },
			cwd = home .. "/.core/cfg/hypr",
		},

		{
			label = "🎨 Design",
			args = { "zsh", "-l" },
			cwd = home .. "/Projects/design",
		},

		{
			label = "🖥️  Core",
			args = { "zsh", "-l" },
			cwd = home .. "/.core",
		},

		{
			label = "⚙️  Config",
			args = { "zsh", "-l" },
			cwd = home .. "/.core/cfg/",
		},
		{
			label = "📦 Env",
			args = { "zsh", "-l" },
			cwd = home .. "/.core/env",
		},

		{
			label = "🐳 Docker",
			args = { "zsh", "-l" },
			cwd = home .. "/.core/env",
		},

		{
			label = "📝 Notes",
			args = { "zsh", "-l" },
			cwd = home .. "/.core/vault",
		},

		{
			label = "🎵 Music",
			args = { "zsh", "-l" },
			cwd = home .. "/.core/cfg/ncspot",
		},
		{
			label = "📊 Monitoring",
			args = { "zsh", "-l" },
			cwd = home .. "/monitoring",
		},
	},
}

-- {
-- 	label = "⚙️ bash",
-- 	args = { "bash", "-l" },
-- 	cwd = home,
-- },
-- {
-- 	label = "🔧 ZSH 5.9",
-- 	args = { "zsh", "-l" },
-- 	cwd = home .. "/.core/cfg/wezterm",
-- },
