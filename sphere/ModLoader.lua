local physfs = require("physfs")
local path_util = require("path_util")
local pkg = require("pkg")
local class = require("class")

---@class sphere.ModLoader2
---@operator call: sphere.ModLoader2
local ModLoader = class()

ModLoader.modsDir = "mods"
ModLoader.mountDir = "mount" .. tostring(os.time()):sub(-4)

---@param game sphere.GameController
function ModLoader:new(game)
	self.game = game
	self.modInfos = {}
	self.mods = {}
end

function ModLoader:load()
	---@type string[]
	local items = love.filesystem.getDirectoryItems(self.modsDir)

	for _, item in ipairs(items) do
		local path = path_util.join(self.modsDir, item)
		local info = love.filesystem.getInfo(path)

		local mountPath = path_util.join(self.mountDir, item)
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
	items = love.filesystem.getDirectoryItems(self.mountDir)

	for _, item in ipairs(items) do
		local dir = self:lookupRootDir(path_util.join(self.mountDir, item))
		if dir then
			pkg.add(dir)

			local metadata_path = path_util.join(dir, "metadata.lua")
			local metadata_file = assert(love.filesystem.load(metadata_path))

			table.insert(self.modInfos, {
				metadata = metadata_file(),
				dir = dir,
			})
		end
	end
	pkg.export_lua()
	pkg.export_love()

	for _, modInfo in ipairs(self.modInfos) do
		local Mod = require(modInfo.metadata.module)
		local mod = Mod(self.game, modInfo.dir)
		self.mods[modInfo.metadata.name] = mod
		mod:load()
	end
end

---@param dir string
---@return string?
---@private
function ModLoader:lookupRootDir(dir)
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

return ModLoader
