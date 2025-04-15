local class = require("class")

---@alias sea.SubtimingsName
---| "unknown"
---| "scorev"

---@class sea.Subtimings
---@operator call: sea.Subtimings
---@field name sea.SubtimingsName
---@field data number
local Subtimings = class()

---@param name sea.SubtimingsName
---@param data number?
function Subtimings:new(name, data)
	self.name = name
	self.data = data or 0
	local v = self:encode()
	assert(v == math.floor(v), "invalid")
	assert(self:validate(), "invalid")
end

---@return boolean
function Subtimings:validate()
	local v = self.data
	local n = self.name

	if n == "scorev" then
		return v == 1 or v == 2
	elseif n == "unknown" then
		return v == math.floor(v)
	end

	return false
end

---@param v integer
---@return sea.Subtimings
function Subtimings.decode(v)
	assert(v, "missing subtimings value")

	if v == 1101 or v == 1102 then
		return Subtimings("scorev", v - 1100)
	end

	return Subtimings("unknown", v)
end

---@param t sea.Subtimings
---@return integer
function Subtimings.encode(t)
	local v = t.data
	local n = t.name

	if n == "scorev" then
		return 1100 + v
	end

	return v
end

return Subtimings
