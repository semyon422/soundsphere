local class = require("class")
local path_util = require("path_util")
local http_util = require("http_util")
local fs_util = require("fs_util")
local thread = require("thread")
local physfs = require("physfs")

local DefaultUserInterface = require("ui.UserInterface")

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
---@field private themeNames string[]
---@field private game sphere.GameController
local UserInterfaceModel = class()

---@param game sphere.GameController
function UserInterfaceModel:new(game)
	self.game = game
	self.loadedThemes = {}
	self.themeNames = {"Default"}
end

function UserInterfaceModel:load()
	local pkgs = self.game.packageManager:getPackagesByType("ui")

	for _, pkg in ipairs(pkgs) do
		table.insert(self.themeNames, pkg.name)
	end

	local pkg_name = self.game.persistence.configModel.configs.settings.graphics.userInterface
	if pkg_name == "Default" then
		self:setDefaultTheme()
		return
	end

	self:setTheme(pkg_name)
end

---@private
function UserInterfaceModel:setDefaultTheme()
	self.loadedThemes["Default"] = DefaultUserInterface(self.game)
	self.activeUI = self.loadedThemes["Default"]
	self.activeUI:load()
end

---@param pkg_name string
---@private
function UserInterfaceModel:setTheme(pkg_name)
	if self.loadedThemes[pkg_name] then
		self.activeUI = self.loadedThemes[pkg_name]
		self.activeUI:load()
		return
	end

	local packageManager = self.game.packageManager

	local pkg = packageManager:getPackage(pkg_name)
	if not pkg or not pkg.types.ui then
		self:setDefaultTheme()
		return
	end

	local ok, err = xpcall(require, debug.traceback, pkg.types.ui)

    if not ok then
		print("Failed to require external UI: " .. err)
		self:setDefaultTheme()
		return
	end

	local rootDir = packageManager:getPackageDir(pkg_name)

	ok, err = pcall(function()
		self.loadedThemes[pkg_name] = err(self.game, rootDir)
	end)
    if not ok then
		print("Failed to create external UI: " .. err)
		self:setDefaultTheme()
		return
	end

	self.activeUI = self.loadedThemes[pkg_name]

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
	local pkg_name = self.game.persistence.configModel.configs.settings.graphics.userInterface
	self.activeUI:unload()
	self:setTheme(pkg_name)
	self.game.ui = self.activeUI
end

return UserInterfaceModel
