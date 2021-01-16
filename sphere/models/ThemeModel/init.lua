local Class = require("aqua.util.Class")
local json = require("json")
local Theme = require("sphere.models.ThemeModel.Theme")

local ThemeModel = Class:new()

ThemeModel.construct = function(self)
	self.theme = Theme:new()
end

ThemeModel.path = "userdata/themes"

ThemeModel.load = function(self)
	self.themes = {}
	self.config = self.configModel:getConfig("settings")
	return self:lookup(self.path)
end

ThemeModel.lookup = function(self, directoryPath)
	for _, itemName in pairs(love.filesystem.getDirectoryItems(directoryPath)) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info.type == "directory" or info.type == "symlink" then
			local info = love.filesystem.getInfo(path .. "/metadata.json")
			if info then
				self:loadMetaData(path, "metadata.json")
			end
		end
	end
end

ThemeModel.loadMetaData = function(self, path, fileName)
	local file = io.open(path .. "/" .. fileName, "r")
	local jsonObject = json.decode(file:read("*all"))
	file:close()

	local theme = Theme:new()

	theme.name = jsonObject.name
	theme.path = path
	theme:load()

	local themes = self.themes
	themes[#themes + 1] = theme
end

ThemeModel.getThemes = function(self)
	return self.themes
end

ThemeModel.setDefaultTheme = function(self, theme)
	self.theme = theme
	self.config.general.theme = theme.path
end

ThemeModel.getTheme = function(self)
	if love.keyboard.isDown("lshift") then
		return self.themes[1]
	end

	local configValue = self.config.general.theme

	if configValue then
		for _, theme in ipairs(self.themes) do
			if theme.path == configValue then
				self.theme = theme
				return theme
			end
		end
	end

	self:setDefaultTheme(self.themes[1] or self.theme)

	return self.theme
end

return ThemeModel
