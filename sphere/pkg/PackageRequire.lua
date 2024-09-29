local class = require("class")

---@class sphere.PackageRequire
---@operator call: sphere.PackageRequire
local PackageRequire = class()

---@param pkgs sphere.Package[]
function PackageRequire:require(pkgs)
	for _, pkg in ipairs(pkgs) do
		require(pkg.types.require)
	end
end

return PackageRequire
