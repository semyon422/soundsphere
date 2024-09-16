local class = require("class")
local path_util = require("path_util")
local http_util = require("http_util")
local fs_util = require("fs_util")
local thread = require("thread")
local physfs = require("physfs")
local pkg = require("pkg")

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
---@field private themeRoots {[string]: string}
---@field private themeNames string[]
---@field private game sphere.GameController
local UserInterfaceModel = class()

UserInterfaceModel.themesDirectory = "userdata/ui_themes"
UserInterfaceModel.themesMount = "theme_mount" .. tostring(os.time()):sub(-4)

UserInterfaceModel.externalThemes = {
	{
		name = "osu!",
		url = "https://codeload.github.com/Thetan-ILW/osu_ui/zip/refs/heads/main",
		github = "https://github.com/Thetan-ILW/osu_ui",
	},
}

---@param game sphere.GameController
function UserInterfaceModel:new(game)
	self.game = game
	self.loadedThemes = {}
	self.installedThemes = {}
	self.themeRoots = {}
	self.themeNames = { "Default" }
end

function UserInterfaceModel:load()
	love.filesystem.createDirectory(self.themesDirectory)

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
			end
		end
	end

	---@type string[]
	items = love.filesystem.getDirectoryItems(self.themesMount)

	for _, item in ipairs(items) do
		local dir = self:lookupRootDir(path_util.join(self.themesMount, item))
		if dir then
			pkg.add(dir)

			local metadata_path = path_util.join(dir, "metadata.lua")
			local metadata_file = assert(love.filesystem.load(metadata_path))
			---@type sphere.UserInterfaceMetadata
			local metadata = metadata_file()

			self.installedThemes[metadata.name] = metadata
			self.themeRoots[metadata.name] = dir
			table.insert(self.themeNames, metadata.name)
		end
	end
	pkg.export_lua()
	pkg.export_love()

	local graphics_config = self.game.persistence.configModel.configs.settings.graphics
	local ui_name = graphics_config.userInterface

	if ui_name == "Default" then
		self:setDefaultTheme()
		return
	end

	self:setTheme(ui_name)
end

---@param dir string
---@return string?
---@private
function UserInterfaceModel:lookupRootDir(dir)
	local path = path_util.join(dir, "metadata.lua")
	if love.filesystem.getInfo(path, "file") then
		return dir
	end

	---@type string[]
	local items = love.filesystem.getDirectoryItems(dir)
	for _, item in ipairs(items) do
		local _dir = path_util.join(dir, item)
		local _path = path_util.join(dir, item, "metadata.lua")
		local dir_info = love.filesystem.getInfo(_dir, "directory")
		local file_info = love.filesystem.getInfo(_path, "file")
		if dir_info and file_info then
			return _dir
		end
	end
end

---@private
function UserInterfaceModel:setDefaultTheme()
	self.loadedThemes["Default"] = DefaultUserInterface(self.game)
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

	local rootDir = self.themeRoots[metadata.name]

	if metadata.config then
		self.game.persistence:openAndReadThemeConfig(metadata.config, rootDir)
	end

	ok, err = pcall(function()
		self.loadedThemes[metadata.name] = err(self.game, rootDir)
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
	local graphics_config = self.game.persistence.configModel.configs.settings.graphics
	local ui_name = graphics_config.userInterface
	self.activeUI:unload()
	self:setTheme(ui_name)
	self.game.ui = self.activeUI
end

function UserInterfaceModel:downloadTheme(theme_info)
	print(("Downloading: %s"):format(theme_info.url))
	theme_info.status = "Downloading"

	theme_info.isDownloading = true
	local data, code, headers, status_line = fs_util.downloadAsync(theme_info.url)
	theme_info.isDownloading = false

	if code == 302 then
		print(require("inspect")(headers))
	end

	if not data then
		theme_info.status = status_line
		return
	end

	local filename = theme_info.url:match("^.+/(.-)$")
	for header, value in pairs(headers) do
		header = header:lower()
		if header == "content-disposition" then
			local cd = http_util.parse_content_disposition(value)
			filename = cd.filename or filename
		end
	end

	filename = path_util.fix_illegal(filename)

	print(("Downloaded: %s"):format(filename))
	if not filename:find("%.zip$") then
		theme_info.status = "Unsupported file type"
		print("Unsupported file type")
		return
	end

	local filedata = love.filesystem.newFileData(data, filename)
	local path = path_util.join(self.themesDirectory, filename)
	love.filesystem.write(path, filedata)

	theme_info.status = "Done! Restart the game."
end
UserInterfaceModel.downloadTheme = thread.coro(UserInterfaceModel.downloadTheme)

return UserInterfaceModel
