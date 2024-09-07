local class = require("class")
local path_util = require("path_util")
local physfs = require("physfs")
local pkg = require("pkg")

local DefaultUserInterface = require("ui")

---@class sphere.UserInterfaceMetadata
---@field name string
---@field version number
---@field module string
---@field config string

---@class sphere.UserInterfaceModel
---@operator call: sphere.UserInterfaceModel
---@field activeUI sphere.IUserInterface
---@field private loadedThemes {[string]: sphere.IUserInterface}
---@field private installedThemes {[string]: sphere.UserInterfaceMetadata}
---@field private mountPaths {[string]: string}
---@field private themeNames string[]
---@field private game sphere.GameController
---@field private persistence sphere.Persistence
local UserInterfaceModel = class()

UserInterfaceModel.themesDirectory = "userdata/ui_themes"
UserInterfaceModel.themesMount = "theme_mount"

---@param persistence sphere.Persistence
---@param game sphere.GameController
function UserInterfaceModel:new(persistence, game)
	self.persistence = persistence
	self.game = game
	self.loadedThemes = {}
	self.installedThemes = {}
	self.mountPaths = {}
	self.themeNames = { "Default" }
end

function UserInterfaceModel:load()
	---@type string[]
	local items = love.filesystem.getDirectoryItems(self.themesDirectory)

	for _, item in ipairs(items) do
		local path = path_util.join(self.themesDirectory, item)
		local info = love.filesystem.getInfo(path)

		local mountPath = path_util.join(self.themesMount, item)
		if info.type == "directory" or info.type == "symlink" or
			(info.type == "file" and item:match("%.zip$"))
		then
			local ok, err = physfs.mount(path, mountPath, false)
			if not ok then
				print(err)
			else
				pkg.add(mountPath)
			end
		end
	end
	pkg.export_lua()
	pkg.export_love()

	---@type string[]
	items = love.filesystem.getDirectoryItems(self.themesMount)

	for _, item in ipairs(items) do
		local dir = path_util.join(self.themesMount, item)
		local metadataPath = path_util.join(self.themesMount, item, "metadata.lua")

		local metadata_file = assert(love.filesystem.load(metadataPath))
		---@type sphere.UserInterfaceMetadata
		local metadata = metadata_file()

		self.installedThemes[metadata.name] = metadata
		self.mountPaths[metadata.name] = dir
		table.insert(self.themeNames, metadata.name)
	end

	local graphics_config = self.persistence.configModel.configs.settings.graphics
	local ui_name = graphics_config.userInterface

	if ui_name == "Default" then
		self:setDefaultTheme()
		return
	end

	self:setTheme(ui_name)
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

	local ok, err = xpcall(require, debug.traceback, metadata.module)

    if not ok then
		--- TODO: Do not crash the game. Instead, load default UI and show error on the screen
		print("Failed to require external UI: " .. err)
		self:setDefaultTheme()
		return
	end

	local mountPath = self.mountPaths[metadata.name]

	if metadata.config then
		self.persistence:openAndReadThemeConfig(metadata.config, mountPath)
	end

	ok, err = pcall(function()
		self.loadedThemes[metadata.name] = err(self.persistence, self.game, mountPath)
	end)
    if not ok then
		print("Failed to create external UI: " .. err)
		self:setDefaultTheme()
		return
	end

	self.activeUI = self.loadedThemes[metadata.name]

	ok, err = pcall(function()
		self.activeUI:load()
	end)
    if not ok then
		print("Failed to load external UI: " .. err)
		self:setDefaultTheme()
		return
	end
end

function UserInterfaceModel:switchTheme()
	local graphics_config = self.persistence.configModel.configs.settings.graphics
	local ui_name = graphics_config.userInterface
	self.activeUI:unload()
	self:setTheme(ui_name)
	self.game.ui = self.activeUI
end

return UserInterfaceModel
