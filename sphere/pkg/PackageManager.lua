local class = require("class")
local PackageMounter = require("sphere.pkg.PackageMounter")
local PackageLoader = require("sphere.pkg.PackageLoader")
local PackageDownloader = require("sphere.pkg.PackageDownloader")

---@class sphere.PackageManager
---@operator call: sphere.PackageManager
local PackageManager = class()

PackageManager.pkgs_path = "userdata/pkg"

function PackageManager:new()
	self.mounter = PackageMounter()
	self.loader = PackageLoader()
	self.packageDownloader = PackageDownloader(self.pkgs_path)
end

function PackageManager:load()
	self.mounter:unmount()
	self.mounter:mount(self.pkgs_path)
	self.loader:unload()
	self.loader:load(self.mounter.paths, self.mounter.real_paths)
	self.packages = self.loader:getPackages()
end

---@return sphere.Package[]
function PackageManager:getPackages()
	return self.packages
end

---@return sphere.Package?
function PackageManager:getPackage(name)
	return self.loader.packages[name]
end

---@return string?
function PackageManager:getPackageDir(name)
	return self.loader.dirs[name]
end

---@return string?
function PackageManager:getPackageRealPath(name)
	return self.mounter.real_paths[self:getPackageDir(name)]
end

---@param _type string
---@return sphere.Package[]
function PackageManager:getPackagesByType(_type)
	---@type sphere.Package[]
	local pkgs = {}
	for _, pkg in pairs(self:getPackages()) do
		if pkg.types[_type] then
			table.insert(pkgs, pkg)
		end
	end
	return pkgs
end

return PackageManager
