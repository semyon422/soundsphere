local class = require("class")

local ThemeModel = class()

ThemeModel.path = "userdata/themes"

function ThemeModel:load()
	self.themes = {}
	self.config = self.configModel.configs.settings
	-- return self:lookup(self.path)
end

function ThemeModel:lookup(directoryPath)
	for _, itemName in pairs(love.filesystem.getDirectoryItems(directoryPath)) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info.type == "directory" or info.type == "symlink" then
			local UserTheme = require(path:gsub("/", "."))
			local userTheme = UserTheme()
			userTheme.path = path
			userTheme:load()

			local themes = self.themes
			themes[#themes + 1] = userTheme
		end
	end
end

function ThemeModel:getThemes()
	return self.themes
end

function ThemeModel:setDefaultTheme(theme)
	-- self.theme = theme
	-- self.config.general.theme = theme.path
end

function ThemeModel:getTheme()
	-- if love.keyboard.isDown("lshift") then
	-- 	return self.themes[1] or self.theme
	-- end

	-- local configValue = self.config.general.theme

	-- if configValue then
	-- 	for _, theme in ipairs(self.themes) do
	-- 		if theme.path == configValue then
	-- 			self.theme = theme
	-- 			return theme
	-- 		end
	-- 	end
	-- end

	-- self:setDefaultTheme(self.themes[1] or self.theme)

	return self.theme
end

return ThemeModel
