local Modifier = require("sphere.models.ModifierModel.Modifier")
local map = require("math_util").map

local WindUp = Modifier:new()

WindUp.type = "TimeEngineModifier"
WindUp.interfaceType = "toggle"

WindUp.defaultValue = true
WindUp.name = "WindUp"
WindUp.shortName = "WU"

WindUp.description = "Change time rate from 0.75 to 1.5 during the play"

WindUp.getString = function(self, config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

WindUp.apply = function(self, config)
	if not config.value then
		return
	end
	self.timeRateHandler = self.rhythmModel.timeEngine:createTimeRateHandler()
	self.timeRateHandler.getTimeRate = function(self)
		local timeEngine = self.timeEngine
		local startTime = timeEngine.noteChart.metaData.minTime
		local endTime = timeEngine.noteChart.metaData.maxTime
		local currentTime = timeEngine.currentTime

		local timeRate = map(currentTime, startTime, endTime, 0.75, 1.5)
		return math.min(math.max(timeRate, 0.75), 1.5)
	end
end

return WindUp
