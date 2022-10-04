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
	self.timeRateHandler = self.game.rhythmModel.timeEngine:createTimeRateHandler()
end

WindUp.update = function(self, config)
	if not config.value then
		return
	end

	local timeEngine = self.game.rhythmModel.timeEngine
	local startTime = timeEngine.noteChart.metaData:get("minTime")
	local endTime = timeEngine.noteChart.metaData:get("maxTime")
	local currentTime = timeEngine.currentTime

	if not timeEngine.timer.isPlaying then
		return
	end

	local timeRate = map(currentTime, startTime, endTime, 0.75, 1.5)
	self.timeRateHandler.timeRate = timeRate
	timeEngine:resetTimeRate()
end

return WindUp
