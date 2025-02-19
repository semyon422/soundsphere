local class = require("class")
local table_util = require("table_util")

---@class sea.Healths
---@operator call: sea.Healths
---@field name string
---@field data any?
local Healths = class()

local lr2 = {
	[0] = "easy",
	[1] = "normal",
	[2] = "hard",
	[3] = "veryhard",
}
local _lr2 = table_util.invert(lr2)

---@param name string
---@param data any?
function Healths:new(name, data)
	self.name = name
	self.data = data
end

---@param t integer
---@return sea.Healths
function Healths.decode(t)
	if t >= 0 and t <= 500 then
		return Healths("simple", t)
	elseif t >= 1100 and t <= 1200 then
		return Healths("osumania", (t - 1100) / 10)
	elseif t >= 1304 and t <= 1309 then
		return Healths("etterna", t - 1300)
	elseif t == 1400 then
		return Healths("quaver")
	elseif t >= 1500 and t <= 1503 then
		return Healths("lr2", lr2[t - 1500])
	end
	return Healths("unknown", t)
end

---@param t sea.Healths
---@return integer
function Healths.encode(t)
	local v = t.data
	if t.name == "simple" then
		return v
	elseif t.name == "osumania" then
		return v * 10 + 1100
	elseif t.name == "etterna" then
		return v + 1300
	elseif t.name == "quaver" then
		return 1400
	elseif t.name == "lr2" then
		return _lr2[v] + 1500
	end
	return v
end

return Healths
