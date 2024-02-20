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
---@param playContext sphere.PlayContext
function TimeRateModel:new(configModel, playContext)
	self.configModel = configModel
	self.playContext = playContext
end

---@return number
function TimeRateModel:get()
	local gameplay = self.configModel.configs.settings.gameplay
	local playContext = self.playContext

	local rateType = gameplay.rateType
	local rate = playContext.rate

	if rateType == "exp" then
		rate = 10 * math.log(rate, 2)
	end

	return rate
end

---@param rate number
---@return string
function TimeRateModel:getRateType(rate)
	local gameplay = self.configModel.configs.settings.gameplay

	local is_exp, is_default

	if math.abs(rate - math_util.round(rate, self.range.default[3])) % 1 < 1e-6 then
		is_default = true
	end

	local exp = 10 * math.log(rate, 2)
	if math.abs(exp - math.floor(exp + 0.5)) % 1 < 1e-6 then
		is_exp = true
	end

	if gameplay.rateType == "exp" and is_exp then
		return "exp"
	end
	if gameplay.rateType == "default" and is_default then
		return "default"
	end
	if is_exp then
		return "exp"
	end
	return "default"
end

---@param newRate number
function TimeRateModel:set(newRate)
	local gameplay = self.configModel.configs.settings.gameplay
	local playContext = self.playContext

	local rateType = gameplay.rateType
	local rate = newRate

	local range = self.range[rateType]
	rate = math_util.clamp(rate, range[1], range[2])

	if rateType == "exp" then
		rate = 2 ^ (rate / 10)
	end

	playContext.rate = rate
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
