local class = require("class")
local math_util = require("math_util")
local int_rates = require("libchart.int_rates")

---@class sphere.TimeRateModel
---@operator call: sphere.TimeRateModel
local TimeRateModel = class()

TimeRateModel.types = {
	"linear",
	"exp",
}

TimeRateModel.range = {
	linear = {0.25, 4, 0.05},
	exp = {-20, 20, 1},
}

TimeRateModel.format = {
	linear = "%0.2f",
	exp = "%0.f",
}

---@param configModel sphere.ConfigModel
---@param playContext sphere.PlayContext
function TimeRateModel:new(configModel, playContext)
	self.configModel = configModel
	self.playContext = playContext
end

---@return number
function TimeRateModel:get()
	local gameplay = self.configModel.configs.settings.gameplay
	local playContext = self.playContext

	local rate_type = gameplay.rate_type
	local rate = playContext.rate

	if rate_type == "exp" then
		rate = int_rates.get_exp(rate, 10)
	end

	return rate
end

---@param newRate number
function TimeRateModel:set(newRate)
	local gameplay = self.configModel.configs.settings.gameplay
	local playContext = self.playContext

	local rate_type = gameplay.rate_type
	local rate = newRate

	local range = self.range[rate_type]
	rate = math_util.clamp(rate, range[1], range[2])

	if rate_type == "exp" then
		rate = 2 ^ (rate / 10)
	end

	playContext.rate = int_rates.round(rate)
end

---@param delta number
function TimeRateModel:increase(delta)
	local gameplay = self.configModel.configs.settings.gameplay
	local rate_type = gameplay.rate_type
	local range = self.range[rate_type]
	local rate = self:get() + delta * range[3]
	rate = math_util.round(rate, range[3])
	self:set(rate)
end

return TimeRateModel
