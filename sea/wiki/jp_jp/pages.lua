---@type sea.Wiki.LanguageMetadata
local t = {
	name = "日本語",
	code = "jp_jp",
	flag = "jp",
	categories = {
		{
			name = "はじめに",
			pages = {
				{ name = "インストール", filename = "installation" },
				{ name = "ヘルプセンター", filename = "help_center" }
			}
		},
		{
			name = "ゲームクライアント",
			pages = {
				{ name = "Adding songs/charts", filename = "adding_charts" },
				{ name = "スキンの追加", filename = "adding_skins" },
				{ name = "プラグインの追加", filename = "adding_plugins" }
			}
		}
	}
}

return t
