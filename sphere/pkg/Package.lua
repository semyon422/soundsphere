local class = require("class")
local Dependency = require("sphere.pkg.Dependency")
local Version = require("sphere.pkg.Version")

---@class sphere.Package
---@operator call: sphere.Package
---@field name string
---@field creator string?
---@field type string?
---@field desc string?
---@field version sphere.Version
---@field deps sphere.Dependency[]
local Package = class()

---@param v any
---@return string?
local function nil_or_tostring(v)
	if v == nil then
		return nil
	end
	return tostring(v)
end

---@param tbl table
function Package:new(tbl)
	self.name = tostring(assert(tbl.name, "missing package name"))
	self.creator = nil_or_tostring(tbl.creator)
	self.type = nil_or_tostring(tbl.type)
	self.desc = nil_or_tostring(tbl.desc)
	self.version = Version:parse(nil_or_tostring(tbl.version))

	---@type sphere.Dependency[]
	local deps = {}
	for i, dep_str in ipairs(tbl.deps --[=[@as string[]]=]) do
		deps[i] = Dependency:parse(dep_str)
	end
	self.deps = deps
end

return Package
