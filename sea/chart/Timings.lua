local class = require("class")
local table_util = require("table_util")

---@class sea.Timings
---@operator call: sea.Timings
---@field name string
---@field data any?
local Timings = class()

local lr2 = {
	[0] = "easy",
	[1] = "normal",
	[2] = "hard",
	[3] = "veryhard",
}
local _lr2 = table_util.invert(lr2)

---@param name string
---@param data any?
function Timings:new(name, data)
	self.name = name
	self.data = data
end

---@param t integer
function Timings:decode(t)
	if t >= 0 and t <= 500 then
		return Timings("simple", t)
	elseif t >= 1100 and t <= 1200 then
		return Timings("osumania", (t - 1100) / 10)
	elseif t >= 1304 and t <= 1309 then
		return Timings("etterna", t - 1300)
	elseif t == 1400 then
		return Timings("quaver")
	elseif t >= 1500 and t <= 1503 then
		return Timings("lr2", lr2[t - 1500])
	end
	return Timings("unknown", t)
end

---@return integer
function Timings:encode()
	local v = self.data
	if self.name == "simple" then
		return v
	elseif self.name == "osumania" then
		return v * 10 + 1100
	elseif self.name == "etterna" then
		return v + 1300
	elseif self.name == "quaver" then
		return 1400
	elseif self.name == "lr2" then
		return _lr2[v] + 1500
	end
	return v
end

return Timings
