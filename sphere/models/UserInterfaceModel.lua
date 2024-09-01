local class = require("class")

local DefaultUserInterface = require("sphere.ui.UserInterface")

---@class sphere.UserInterfaceModel
---@operator call: sphere.UserInterfaceModel
---@field themes table<string, sphere.IUserInterface>
---@field activeTheme sphere.IUserInterface
local UserInterfaceModel = class()

UserInterfaceModel.themesDirectory = "userdata/ui_themes"

---@param persistence sphere.Persistence
---@param game sphere.GameController
function UserInterfaceModel:new(persistence, game)
	self.themes = {
		["Default"] = DefaultUserInterface(persistence, game)
	}

	local dirs = love.filesystem.getDirectoryItems(self.themesDirectory)

	for _, theme_dir in ipairs(dirs) do
		local theme_file, err = love.filesystem.load(("%s/%s/init.lua"):format(self.themesDirectory, theme_dir))

		if err then
			error(err)
		end

		--local theme = theme_file()
		---@cast theme sphere.IUserInterface
		--self.themes[theme.name] = theme
	end
end

function UserInterfaceModel:load()
	self.activeTheme = self.themes["Default"]
	self.activeTheme:load()
end

function UserInterfaceModel:getActiveTheme()
	return self.activeTheme
end

return UserInterfaceModel
