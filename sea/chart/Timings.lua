local class = require("class")

---@alias sea.TimingsName
---| "unknown"
---| "arbitrary"
---| "sphere"
---| "simple"
---| "osumania"
---| "stepmania"
---| "quaver"
---| "bmsrank"

---@class sea.Timings
---@operator call: sea.Timings
---@field name sea.TimingsName
---@field data number
local Timings = class()

---@param name sea.TimingsName
---@param data number?
function Timings:new(name, data)
	self.name = name
	self.data = data or 0
	local v = self:encode()
	assert(v == math.floor(v))
	assert(self:validate())
end

---@return true?
---@return string?
function Timings:validate()
	local v = self.data
	local n = self.name

	if n == "arbitrary" then
		return v == 0
	elseif n == "sphere" then
		return v == 0
	elseif n == "simple" then
		return v == 0
	elseif n == "osumania" then
		v = v * 10
		return v == math.floor(v)
	elseif n == "stepmania" then
		return v == 0
	elseif n == "quaver" then
		return v == 0
	elseif n == "bmsrank" then
		return v >= 0 and v <= 3 and v == math.floor(v)
	elseif n == "unknown" then
		return v == math.floor(v)
	end

	error("invalid timings name")
end

---@param v integer
---@return sea.Timings
function Timings.decode(v)
	assert(v, "missing timings value")

	if v == 0 then
		return Timings("arbitrary")
	elseif v == 100 then
		return Timings("sphere")
	elseif v == 1000 then
		return Timings("simple")
	elseif v >= 1100 and v <= 1200 then
		return Timings("osumania", (v - 1100) / 10) -- OverallDifficulty
	elseif v == 1300 then
		return Timings("stepmania")
	elseif v == 1400 then
		return Timings("quaver")
	elseif v >= 1500 and v <= 1503 then
		return Timings("bmsrank", v - 1500) -- #RANK
	end

	return Timings("unknown", v)
end

---@param t sea.Timings
---@return integer
function Timings.encode(t)
	local v = t.data
	local n = t.name

	if n == "arbitrary" then
		return 0
	elseif n == "sphere" then
		return 100
	elseif n == "simple" then
		return 1000
	elseif n == "osumania" then
		return 1100 + v * 10
	elseif n == "stepmania" then
		return 1300
	elseif n == "quaver" then
		return 1400
	elseif n == "bmsrank" then
		return 1500 + v
	end

	return v
end

---@param t sea.Timings
function Timings:__eq(t)
	return self.name == t.name and self.data == t.data
end

return Timings
