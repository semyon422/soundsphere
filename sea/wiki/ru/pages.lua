---@type sea.Wiki.LanguageMetadata
local t = {
	name = "Русский",
	code = "ru",
	flag = "ru",
	categories = {
		{
			name = "Знакомство",
			pages = {
				{ name = "Главная страница", filename = "main_page" },
				{ name = "Установка", filename = "installation" },
				{ name = "Помощь", filename = "help_center" }
			}
		},
		{
			name = "Игровой клиент",
			pages = {
				{ name = "Добавление карт/музыки", filename = "adding_charts" },
				{ name = "Добавление скинов", filename = "adding_skins" },
				{ name = "Добавление плагинов", filename = "adding_plugins" }
			}
		}
	}
}

return t
