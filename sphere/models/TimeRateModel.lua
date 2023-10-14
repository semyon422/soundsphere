local class = require("class")
local math_util = require("math_util")

---@class sphere.TimeRateModel
---@operator call: sphere.TimeRateModel
local TimeRateModel = class()

TimeRateModel.types = {
	"default",
	"exp",
}

TimeRateModel.range = {
	default = {0.5, 2, 0.05},
	exp = {-10, 10, 1},
}

TimeRateModel.format = {
	default = "%0.2f",
	exp = "%0.f",
}

---@param configModel sphere.ConfigModel
function TimeRateModel:new(configModel)
	self.configModel = configModel
end

---@return number
function TimeRateModel:get()
	local gameplay = self.configModel.configs.settings.gameplay
	local play = self.configModel.configs.play

	local rateType = gameplay.rateType
	local rate = play.rate

	if rateType == "exp" then
		rate = 10 * math.log(rate, 2)
	end

	return rate
end

---@param newRate number
function TimeRateModel:set(newRate)
	local gameplay = self.configModel.configs.settings.gameplay
	local play = self.configModel.configs.play

	local rateType = gameplay.rateType
	local rate = newRate

	local range = self.range[rateType]
	rate = math_util.clamp(rate, range[1], range[2])

	if rateType == "exp" then
		rate = 2 ^ (rate / 10)
	end

	play.rate = rate
end

---@param delta number
function TimeRateModel:increase(delta)
	local gameplay = self.configModel.configs.settings.gameplay
	local rateType = gameplay.rateType
	local range = self.range[rateType]
	local rate = self:get() + delta * range[3]
	rate = math_util.round(rate, range[3])
	self:set(rate)
end

return TimeRateModel
