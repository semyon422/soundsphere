local class = require("class")
local PackageMounter = require("sphere.pkg.PackageMounter")
local PackageLoader = require("sphere.pkg.PackageLoader")
local PackageDownloader = require("sphere.pkg.PackageDownloader")
local PackageRequire = require("sphere.pkg.PackageRequire")

---@class sphere.PackageManager
---@operator call: sphere.PackageManager
local PackageManager = class()

PackageManager.pkgs_path = "userdata/pkg"

function PackageManager:new()
	self.mounter = PackageMounter()
	self.loader = PackageLoader()
	self.packageDownloader = PackageDownloader(self.pkgs_path)
	self.packageRequire = PackageRequire()
end

function PackageManager:load()
	self.mounter:unmount()
	self.mounter:mount(self.pkgs_path)
	self.loader:removeLua()
	self.loader:load(self.mounter.paths, self.mounter.real_paths)
	self.loader:addLua()
	self.packages = self.loader:getPackages()
	self.packageRequire:require(self:getPackagesByType("require"))
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
	return self.loader.real_paths[name]
end

---@param _type string
---@return sphere.Package[]
function PackageManager:getPackagesByType(_type)
	return self.loader:getPackagesByType(_type)
end

return PackageManager
