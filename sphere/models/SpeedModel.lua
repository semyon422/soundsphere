local class = require("class")
local math_util = require("math_util")

local SpeedModel = class()

SpeedModel.types = {
	"default",
	"osu",
}

SpeedModel.range = {
	default = {0.05, 3, 0.01},
	osu = {1, 40, 1},
}

SpeedModel.format = {
	default = "%0.2f",
	osu = "%d",
}

local osuFactor = 7 / 96

function SpeedModel:get()
	local gameplay = self.configModel.configs.settings.gameplay
	local speed = gameplay.speed
	local speedType = gameplay.speedType

	if speedType == "osu" then
		speed = math_util.round(speed / osuFactor)
	end

	local range = self.range[speedType]
	return math_util.clamp(speed, range[1], range[2])
end

function SpeedModel:set(newSpeed)
	local gameplay = self.configModel.configs.settings.gameplay
	local speedType = gameplay.speedType

	local range = self.range[speedType]
	newSpeed = math_util.clamp(newSpeed, range[1], range[2])

	if speedType == "osu" then
		newSpeed = newSpeed * osuFactor
	end

	range = self.range.default
	gameplay.speed = math_util.clamp(newSpeed, range[1], range[2])
end

function SpeedModel:increase(delta)
	local gameplay = self.configModel.configs.settings.gameplay
	local speed = gameplay.speed

	if gameplay.speedType == "osu" then
		speed = speed / osuFactor
	else
		delta = delta * 0.05
	end

	self:set(speed + delta)
end

return SpeedModel
