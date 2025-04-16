---@type sea.Wiki.LanguageMetadata
local t = {
	name = "繁體中文",
	code = "zh_tw",
	flag = "ch",
	categories = {
		{
			name = "開始使用",
			pages = {
				{ name = "主頁", filename = "main_page" },
				{ name = "安裝", filename = "installation" },
				{ name = "幫助中心", filename = "help_center" }
			}
		},
		{
			name = "遊戲客戶端",
			pages = {
				{ name = "Adding songs/charts", filename = "adding_charts" },
				{ name = "新增皮膚", filename = "adding_skins" },
				{ name = "添加插件", filename = "adding_plugins" }
			}
		}
	}
}

return t
