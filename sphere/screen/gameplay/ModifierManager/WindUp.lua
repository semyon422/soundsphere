local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")
local map = require("aqua.math").map

local WindUp = Modifier:new()

WindUp.inconsequential = true
WindUp.type = "TimeEngineModifier"

WindUp.name = "WindUp"
WindUp.shortName = "WindUp"

WindUp.variableType = "boolean"

WindUp.apply = function(self)
	-- self.sequence.manager.logicEngine.score.windUp = true
end

WindUp.update = function(self)
	local timeEngine = self.sequence.manager.timeEngine
	local startTime = timeEngine.noteChart.metaData:get("minTime")
	local endTime = timeEngine.noteChart.metaData:get("maxTime")
	local currentTime = timeEngine.exactCurrentTime

	if timeEngine.timeRate == 0 then
		return
	end

	local targetTimeRate = map(currentTime, startTime, endTime, 0.75, 1.5)
	timeEngine.baseTimeRate = targetTimeRate
	timeEngine:setTimeRate(targetTimeRate, false)
end

return WindUp
