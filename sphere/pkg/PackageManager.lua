local class = require("class")
local PackageMounter = require("sphere.pkg.PackageMounter")
local PackageLoader = require("sphere.pkg.PackageLoader")

---@class sphere.PackageManager
---@operator call: sphere.PackageManager
local PackageManager = class()

function PackageManager:new()
	self.mounter = PackageMounter("userdata/pkg")
	self.loader = PackageLoader()
end

function PackageManager:load()
	self.mounter:unmount()
	self.mounter:mount()
	self.loader:load(self.mounter.paths, self.mounter.real_paths)
end

---@return {[string]: sphere.Package}
function PackageManager:getPackages()
	return self.loader.packages
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
	return self.mounter.real_paths[name]
end

---@param _type string
---@return sphere.Package[]
function PackageManager:getPackagesByType(_type)
	---@type sphere.Package[]
	local pkgs = {}
	for _, pkg in pairs(self:getPackages()) do
		if pkg.type == _type then
			table.insert(pkgs, pkg)
		end
	end
	return pkgs
end

return PackageManager
