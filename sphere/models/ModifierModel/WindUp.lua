local Modifier = require("sphere.models.ModifierModel.Modifier")
local map = require("aqua.math").map

local WindUp = Modifier:new()

WindUp.type = "TimeEngineModifier"
WindUp.interfaceType = "toggle"

WindUp.name = "WindUp"
WindUp.shortName = "WU"

WindUp.apply = function(self, config)
	if config.value == 0 then
		return
	end
	self.timeRateHandler = self.rhythmModel.timeEngine:createTimeRateHandler()
end

WindUp.update = function(self, config)
	if config.value == 0 then
		return
	end

	local timeEngine = self.rhythmModel.timeEngine
	local startTime = timeEngine.noteChart.metaData:get("minTime")
	local endTime = timeEngine.noteChart.metaData:get("maxTime")
	local currentTime = timeEngine.exactCurrentTime

	if timeEngine.timeRate == 0 then
		return
	end

	local timeRate = map(currentTime, startTime, endTime, 0.75, 1.5)
	self.timeRateHandler.timeRate = timeRate

	local baseTimeRate = self.rhythmModel.timeEngine:getBaseTimeRate()
	timeEngine:setTimeRate(baseTimeRate, false)
end

return WindUp
