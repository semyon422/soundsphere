local class = require("class")

---@alias sea.SubtimingsName
---| "unknown"
---| "none"
---| "window"
---| "scorev"
---| "etternaj"
---| "lunatic"

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

	if n == "window" then
		v = v * 1000
		return v >= 0 and v <= 1000 and v == math.floor(v)
	elseif n == "scorev" then
		return v == 1 or v == 2
	elseif n == "etternaj" then
		return v >= 1 and v <= 9
	elseif n == "lunatic" then
		return v == 0
	elseif n == "none" then
		return v == 0
	elseif n == "unknown" then
		return v == math.floor(v)
	end

	return false
end

---@param v integer
---@return sea.Subtimings
function Subtimings.decode(v)
	assert(v, "missing subtimings value")

	if v == 0 then
		return Subtimings("none")
	elseif v >= 1000 and v <= 2000 then
		return Subtimings("window", (v - 1000) / 1000)
	elseif v >= 2101 and v <= 2102 then
		return Subtimings("scorev", v - 2100)
	elseif v >= 2201 and v <= 2209 then
		return Subtimings("etternaj", v - 2200)
	elseif v == 2300 then
		return Subtimings("lunatic")
	end

	return Subtimings("unknown", v)
end

---@param t sea.Subtimings
---@return integer
function Subtimings.encode(t)
	local v = t.data
	local n = t.name

	if n == "none" then
		return 0
	elseif n == "window" then
		return 1000 + math.floor(v * 1000)
	elseif n == "scorev" then
		return 2100 + v
	elseif n == "etternaj" then
		return 2200 + v
	elseif n == "lunatic" then
		return 2300
	end

	return v
end

return Subtimings
