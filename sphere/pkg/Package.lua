local class = require("class")
local Dependency = require("sphere.pkg.Dependency")
local Version = require("sphere.pkg.Version")

---@class sphere.Package
---@operator call: sphere.Package
---@field name string
---@field version sphere.Version
---@field deps sphere.Dependency[]
---@field desc string
local Package = class()

---@param tbl table
function Package:new(tbl)
	self.name = tostring(tbl.name)
	self.version = Version:fromString(tbl.version)
	self.desc = tostring(tbl.version)

	---@type sphere.Dependency[]
	local deps = {}
	for i, dep_str in ipairs(tbl.deps --[=[@as string[]]=]) do
		deps[i] = Dependency:fromString(dep_str)
	end
	self.deps = deps
end

return Package
