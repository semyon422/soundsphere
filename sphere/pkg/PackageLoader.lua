local path_util = require("path_util")
local class = require("class")
local json = require("json")
local stbl = require("stbl")
local Package = require("sphere.pkg.Package")

---@class sphere.PackageLoader
---@operator call: sphere.PackageLoader
local PackageLoader = class()

---@param paths string[]
---@param real_paths {[string]: string}?
function PackageLoader:load(paths, real_paths)
	---@type {[string]: sphere.Package}
	self.packages = {}
	---@type {[string]: string}
	self.dirs = {}
	---@type {[string]: string}
	self.real_paths = {}

	for _, path in ipairs(paths) do
		local real_path = real_paths and real_paths[path]
		self:loadPackage(path, real_path)
	end
end

---@param path string
---@param real_path string?
---@private
function PackageLoader:loadPackage(path, real_path)
	local root_path = self:lookupRootDir(path)
	if not root_path then
		return
	end

	local metadata_path = path_util.join(root_path, "pkg.json")
	local data = love.filesystem.read(metadata_path)

	local pkg = Package(json.decode(data))
	local name = pkg.name

	local existing_pkg = self.packages[name]
	if existing_pkg then
		error(("package '%s' duplicate:\n%s\n%s"):format(
			name,
			real_path,
			self.real_paths[name]
		))
		return
	end

	self.packages[name] = pkg
	self.dirs[name] = root_path
	self.real_paths[name] = real_path

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
