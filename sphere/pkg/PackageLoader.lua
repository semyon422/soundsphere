local physfs = require("physfs")
local path_util = require("path_util")
local class = require("class")
local json = require("json")
local stbl = require("stbl")
local Package = require("sphere.pkg.Package")

---@class sphere.PackageLoader
---@operator call: sphere.PackageLoader
local PackageLoader = class()

PackageLoader.pkgsDir = "userdata/pkg"
PackageLoader.mountDir = "mount" .. tostring(os.time()):sub(-4)

function PackageLoader:new()
	---@type {[string]: sphere.Package}
	self.packages = {}
	---@type {[string]: string}
	self.dirs = {}
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

	local metadata_path = path_util.join(dir, "pkg.json")
	local data = love.filesystem.read(metadata_path)

	local pkg = Package(json.decode(data))
	if self.packages[pkg.name] then
		error("package duplicate: " .. stbl.encode(pkg))
		return
	end

	self.packages[pkg.name] = pkg
	self.dirs[pkg.name] = dir

	print("package loaded: " .. stbl.encode(pkg))
end

---@param dir string
---@return string?
---@private
function PackageLoader:lookupRootDir(dir)
	local path = path_util.join(dir, "pkg.json")
	if love.filesystem.getInfo(path, "file") then
		return dir
	end

	---@type string[]
	local items = love.filesystem.getDirectoryItems(dir)
	for _, item in ipairs(items) do
		local _dir = path_util.join(dir, item)
		local _path = path_util.join(dir, item, "pkg.json")
		local dir_info = love.filesystem.getInfo(_dir, "directory")
		local file_info = love.filesystem.getInfo(_path, "file")
		if dir_info and file_info then
			return _dir
		end
	end
end

return PackageLoader
