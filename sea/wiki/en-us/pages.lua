---@type sea.Wiki.LanguageMetadata
local t = {
	name = "English",
	code = "en-us",
	categories = {
		{
			name = "Getting started",
			pages = {
				{ name = "Installation", filename = "installation" },
				{ name = "Help center", filename = "help_center" }
			}
		},
		{
			name = "Game client",
			pages = {
				{ name = "Adding songs/charts", filename = "adding_charts" },
				{ name = "Adding skins", filename = "adding_skins" },
				{ name = "Adding plugins", filename = "adding_plugins" },
				{ name = "Chart filters", filename = "chart_filters" }
			}
		},
	}
}

return t
