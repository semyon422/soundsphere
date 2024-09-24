local physfs = require("physfs")
local path_util = require("path_util")
local class = require("class")
local toml = require("toml")
local stbl = require("stbl")

---@class sphere.PackageLoader
---@operator call: sphere.PackageLoader
local PackageLoader = class()

PackageLoader.pkgsDir = "userdata/pkg"
PackageLoader.mountDir = "mount" .. tostring(os.time()):sub(-4)

function PackageLoader:new()
	self.packages = {}
end

function PackageLoader:load()
	---@type string[]
	local items = love.filesystem.getDirectoryItems(self.pkgsDir)

	for _, item in ipairs(items) do
		local path = path_util.join(self.pkgsDir, item)
		local info = love.filesystem.getInfo(path)

		local mountPath = path_util.join(self.mountDir, item)
		if info.type == "directory" or info.type == "symlink" or
			(info.type == "file" and item:match("%.zip$"))
		then
			local ok, err = physfs.mount(path, mountPath, false)
			if not ok then
				print(err)
			else
				self:readPackage(mountPath)
			end
		end
	end
end

---@param mountPath string
---@private
function PackageLoader:readPackage(mountPath)
	local dir = self:lookupRootDir(mountPath)
	if not dir then
		return
	end

	local metadata_path = path_util.join(dir, "pkg.toml")
	local data = love.filesystem.read(metadata_path)

	---@type table
	local metadata = toml.parse(data)

	print("package loaded: " .. stbl.encode(metadata))
	table.insert(self.packages, {
		metadata = metadata,
		dir = dir,
	})
end

---@param dir string
---@return string?
---@private
function PackageLoader:lookupRootDir(dir)
	local path = path_util.join(dir, "pkg.toml")
	if love.filesystem.getInfo(path, "file") then
		return dir
	end

	---@type string[]
	local items = love.filesystem.getDirectoryItems(dir)
	for _, item in ipairs(items) do
		local _dir = path_util.join(dir, item)
		local _path = path_util.join(dir, item, "pkg.toml")
		local dir_info = love.filesystem.getInfo(_dir, "directory")
		local file_info = love.filesystem.getInfo(_path, "file")
		if dir_info and file_info then
			return _dir
		end
	end
end

return PackageLoader
