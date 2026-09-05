local wezterm = require("wezterm")

-- Finder-launched WezTerm on macOS has no Homebrew on PATH, so a bare
-- `fish` lookup is unreliable. Pick an absolute path that exists on this host.
local function path_exists(path)
	local file = io.open(path)
	if file then
		file:close()
		return true
	end
	return false
end

local function fish_prog()
	local candidates
	if wezterm.target_triple:find("darwin", 1, true) then
		candidates = {
			"/opt/homebrew/bin/fish", -- Apple Silicon Homebrew
			"/usr/local/bin/fish", -- Intel Homebrew
		}
	else
		candidates = {
			"/usr/bin/fish",
			"/usr/local/bin/fish",
		}
	end

	for _, path in ipairs(candidates) do
		if path_exists(path) then
			return { path }
		end
	end

	return { "fish" }
end

return {
	default_prog = fish_prog(),
	audible_bell = "Disabled",

	window_padding = {
		left = 0,
		right = 0,
		top = 5,
		bottom = 0,
	},
	enable_scroll_bar = false,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,

	font = wezterm.font("DejaVuSansM Nerd Font Mono", { weight = "Regular" }),
	font_size = 10.0,
	color_scheme = "Afterglow",
}
