local class = require("class")
local Version = require("sphere.pkg.Version")

---@class sphere.Dependency
---@operator call: sphere.Dependency
local Dependency = class()

---@param name string
---@param op string
---@param ver sphere.Version
function Dependency:new(name, op, ver)
	self.name = name
	self.op = op
	self.ver = ver
end

---@param dep_str string
---@return sphere.Dependency?
function Dependency:fromString(dep_str)
	local name, op, ver = dep_str:match("^(.-)([<=>]+)(.-)$")
	return Dependency(name, op, Version:fromString(ver))
end

return Dependency
