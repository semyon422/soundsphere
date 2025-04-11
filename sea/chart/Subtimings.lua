local class = require("class")

---@alias sea.SubtimingsName
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
	end

	return false
end

---@param v integer
---@param tn sea.TimingsName
---@return sea.Subtimings
function Subtimings.decode(v, tn)
	assert(v, "missing subtimings value")

	if tn == "simple" then
		return Subtimings("window", v / 1000) -- hit and miss window in seconds
	elseif tn == "osumania" then
		return Subtimings("scorev", v)
	elseif tn == "stepmania" then
		if v >= 1 and v <= 9 then
			return Subtimings("etternaj", v)
		end
		error("invalid stepmania subtimings")
		-- TODO: other stepmania judgements
	elseif tn == "lunatic" then
		if v == 0 then
			return Subtimings("lunatic")
		end
		error("invalid bmsrank subtimings")
		-- TODO: other bms judgements
	end

	return Subtimings("none")
end

---@param t sea.Subtimings
---@return integer
function Subtimings.encode(t)
	local v = t.data
	local n = t.name

	if n == "window" then
		return math.floor(v * 1000)
	elseif n == "scorev" then
		return v
	elseif n == "etternaj" then
		return v
	elseif n == "lunatic" then
		return v
	end

	return v
end

return Subtimings
