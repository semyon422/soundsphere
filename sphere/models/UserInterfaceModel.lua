local class = require("class")
local physfs = require("physfs")

local DefaultUserInterface = require("ui")

---@class sphere.UserInterfaceMetadata
---@field name string
---@field directory string
---@field mountDirectory string
---@field initFile fun(): sphere.IUserInterface
---@field configFileName string

---@class sphere.UserInterfaceModel
---@operator call: sphere.UserInterfaceModel
---@field activeUI sphere.IUserInterface
---@field private loadedThemes table<string, sphere.IUserInterface>
---@field private installedThemes table<string, sphere.UserInterfaceMetadata>
---@field private themeNames string[]
---@field private game sphere.GameController
---@field private persistence sphere.Persistence
local UserInterfaceModel = class()

UserInterfaceModel.themesDirectory = "userdata/ui_themes"

---@param persistence sphere.Persistence
---@param game sphere.GameController
function UserInterfaceModel:new(persistence, game)
	self.persistence = persistence
	self.game = game
	self.loadedThemes = {}
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
	self.loadedThemes["Default"] = DefaultUserInterface(self.persistence, self.game)
	self.activeUI = self.loadedThemes["Default"]
	self.activeUI:load()
end

---@param ui_name string
---@private
function UserInterfaceModel:setTheme(ui_name)
	if self.loadedThemes[ui_name] then
		self.activeUI = self.loadedThemes[ui_name]
		self.activeUI:load()
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

	if metadata.configFileName then
		self.persistence:openAndReadThemeConfig(metadata.configFileName, metadata.directory)
	end

	self.loadedThemes[metadata.name] = ui(self.persistence, self.game)
	self.activeUI = self.loadedThemes[metadata.name]
	self.activeUI:load()
end

function UserInterfaceModel:load()
	local graphics_config = self.persistence.configModel.configs.settings.graphics
	local ui_name = graphics_config.userInterface

	if ui_name == "Default" then
		self:setDefaultTheme()
		return
	end

	self:setTheme(ui_name)
end

function UserInterfaceModel:switchTheme()
	local graphics_config = self.persistence.configModel.configs.settings.graphics
	local ui_name = graphics_config.userInterface
	self.activeUI:unload()
	self:setTheme(ui_name)
	self.game.ui = self.activeUI
end

return UserInterfaceModel
