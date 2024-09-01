local class = require("class")
local physfs = require("physfs")

local DefaultUserInterface = require("sphere.ui.UserInterface")

---@class sphere.UserInterfaceMetadata
---@field name string
---@field directory string
---@field mountDirectory string
---@field initFile fun(): sphere.IUserInterface
---@field configFileName string

---@class sphere.UserInterfaceModel
---@operator call: sphere.UserInterfaceModel
---@field private themes table<string, sphere.IUserInterface>
---@field private installedThemes table<string, sphere.UserInterfaceMetadata>
---@field private themeNames string[]
---@field private activeTheme sphere.IUserInterface
---@field private game sphere.GameController
---@field private persistence sphere.Persistence
local UserInterfaceModel = class()

UserInterfaceModel.themesDirectory = "userdata/ui_themes"

---@param persistence sphere.Persistence
---@param game sphere.GameController
function UserInterfaceModel:new(persistence, game)
	self.persistence = persistence
	self.game = game
	self.themes = {}
	self.installedThemes = {}
	self.themeNames = { "Default" }

	local dirs = love.filesystem.getDirectoryItems(self.themesDirectory)

	for _, theme_dir in ipairs(dirs) do
		local dir = ("%s/%s"):format(self.themesDirectory, theme_dir)
		local metadata_file, err = love.filesystem.load(("%s/metadata.lua"):format(dir))

		if err then
			error(err)
		end

		local metadata = metadata_file()
		---@cast metadata sphere.UserInterfaceMetadata
		metadata.directory = dir
		metadata.initFile = love.filesystem.load(("%s/init.lua"):format(dir, theme_dir))
		self.installedThemes[metadata.name] = metadata
		table.insert(self.themeNames, metadata.name)
	end
end

---@private
function UserInterfaceModel:setDefaultTheme()
	self.themes["Default"] = DefaultUserInterface(self.persistence, self.game)
	self.activeTheme = self.themes["Default"]
	self.activeTheme:load()
end

function UserInterfaceModel:load()
	local graphics_config = self.persistence.configModel.configs.settings.graphics
	local ui_name = graphics_config.userInterface

	if ui_name == "Default" then
		self:setDefaultTheme()
		return
	end

	local metadata = self.installedThemes[ui_name]

	if not metadata then
		self:setDefaultTheme()
		return
	end

	local source = love.filesystem.getSource()
	local success, err = physfs.mount(source .. "/" .. metadata.directory .. "/", metadata.mountDirectory, false)
    success = success and true or false

    if not success then
    	error(err)
    end

    local ui, err = metadata.initFile()

    if err then
		--- TODO: Do not crash the game. Instead, load default UI and show error on the screen
		error("Failed to load external UI: " .. err)
		return
	end

	self.themes[metadata.name] = ui(self.persistence, self.game)
	self.activeTheme = self.themes[metadata.name]
	self.activeTheme:load()
end

function UserInterfaceModel:getActiveTheme()
	return self.activeTheme
end

return UserInterfaceModel
