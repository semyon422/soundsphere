local class = require("class")
local odhp = require("osu.odhp")
local TimingValues = require("sea.chart.TimingValues")

---@class sea.Timings
---@operator call: sea.Timings
---@field name string
---@field data number?
local Timings = class()

---@param name string
---@param data any?
function Timings:new(name, data)
	self.name = name
	self.data = data
	local v = self:encode()
	assert(v == math.floor(v))
end

---@return sea.TimingValues
function Timings:getTimingValues()
	local n = self.name
	local v = self.data
	---@cast v number
	if n == "simple" then
		return TimingValues():setSimple(v, v)
	elseif n == "osumania" then
		local od3 = odhp.od3(v)
		return TimingValues():setSimple((151 - od3) / 1000, (188 - od3) / 1000)
	elseif n == "etterna" then
		return TimingValues():setSimple(0.18, 0.18)
	elseif n == "quaver" then
		return TimingValues():setSimple(0.127, 0.164)
	elseif n == "bmsrank" then
		return TimingValues():setSimple(0.2, 0.2)
	end
	return TimingValues():setSimple(0, 0)
end

---@param t integer
---@return sea.Timings
function Timings.decode(t)
	assert(t, "missing timings value")
	if t >= 0 and t <= 500 then
		return Timings("simple", t / 1000)
	elseif t >= 1100 and t <= 1200 then
		return Timings("osumania", (t - 1100) / 10)
	elseif t >= 1304 and t <= 1309 then
		return Timings("etterna", t - 1300)
	elseif t == 1400 then
		return Timings("quaver")
	elseif t >= 1500 and t <= 1503 then
		return Timings("bmsrank", t - 1500)
	end
	return Timings("unknown", t)
end

---@param t sea.Timings
---@return integer
function Timings.encode(t)
	local v = t.data
	local n = t.name
	---@cast v number
	if n == "simple" then
		return v * 1000
	elseif n == "osumania" then
		return v * 10 + 1100
	elseif n == "etterna" then
		return v + 1300
	elseif n == "quaver" then
		return 1400
	elseif n == "bmsrank" then
		return v + 1500
	end
	return v
end

return Timings
