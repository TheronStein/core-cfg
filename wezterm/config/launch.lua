local paths = require("utils.paths")

return {
	-- Default program for new panes/tabs
	default_prog = { "zsh" },
	-- Workspace launcher menu with different working directories
	launch_menu = {
		{
			label = "🐚 ZShell",
			args = { "zsh", "-l" },
			cwd = paths.ZSH_CONFIG,
		},
		{
			label = "💻 Work",
			args = { "zsh", "-l" },
			cwd = paths.CORE_WORK,
		},
		{
			label = "🪟 Hyprland",
			args = { "zsh", "-l" },
			cwd = paths.HYPR_CONFIG,
		},
		{
			label = "🎨 Design",
			args = { "zsh", "-l" },
			cwd = paths.HOME .. "/Projects/design",
		},
		{
			label = "🖥️  Core",
			args = { "zsh", "-l" },
			cwd = paths.HOME .. "/.core",
		},
		{
			label = "⚙️  Config",
			args = { "zsh", "-l" },
			cwd = paths.CORE_CFG,
		},
		{
			label = "📦 Env",
			args = { "zsh", "-l" },
			cwd = paths.CORE_ENV,
		},
		{
			label = "🐳 Docker",
			args = { "zsh", "-l" },
			cwd = paths.CORE_PROJ .. "/docker",
		},
		{
			label = "📝 Notes",
			args = { "zsh", "-l" },
			cwd = paths.CORE_VAULT,
		},
		{
			label = "🎵 Music",
			args = { "zsh", "-l" },
			cwd = paths.MUSIC_TUI,
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
-- 	cwd = home .. "/.core/.sys/configs/wezterm",
-- },
