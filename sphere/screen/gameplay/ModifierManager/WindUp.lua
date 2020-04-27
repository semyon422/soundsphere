local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")
local map = require("aqua.math").map

local WindUp = InconsequentialModifier:new()

WindUp.name = "WindUp"
WindUp.shortName = "WindUp"

WindUp.type = "boolean"

WindUp.apply = function(self)
	self.sequence.manager.logicEngine.score.windUp = true
end

WindUp.update = function(self)
	local logicEngine = self.sequence.manager.logicEngine
	local startTime = logicEngine.noteChart:hashGet("minTime")
	local endTime = logicEngine.noteChart:hashGet("maxTime")
	local currentTime = logicEngine.exactCurrentTime
	-- logicEngine:setTimeRate(map(currentTime, startTime, endTime, 0.75, 1.5))
end

return WindUp
