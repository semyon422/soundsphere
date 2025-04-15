local class = require("class")

---@alias sea.HealthsName
---| "unknown"
---| "simple"

---@class sea.Healths
---@operator call: sea.Healths
---@field name sea.HealthsName
---@field data number
local Healths = class()

---@param name sea.HealthsName
---@param data any?
function Healths:new(name, data)
	self.name = name
	self.data = data
	local v = self:encode()
	assert(v == math.floor(v), "invalid")
	assert(self:validate(), "invalid")
end

---@return boolean
function Healths:validate()
	local v = self.data
	local n = self.name

	if n == "simple" then
		return v >= 0 and v <= 100 and v == math.floor(v)
	end

	return false
end

---@param v integer
---@return sea.Healths
function Healths.decode(v)
	assert(v, "missing healths value")

	if v >= 0 and v <= 100 then
		return Healths("simple", v)
	end

	return Healths("unknown", v)
end

---@param t sea.Healths
---@return integer
function Healths.encode(t)
	local v = t.data

	if t.name == "simple" then
		return v
	end

	return v
end

return Healths
