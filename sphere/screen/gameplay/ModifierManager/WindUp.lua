local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")
local map = require("aqua.math").map

local WindUp = InconsequentialModifier:new()

WindUp.name = "WindUp"
WindUp.shortName = "WindUp"

WindUp.apply = function(self)
	self.sequence.manager.engine.score.windUp = self.value
end

WindUp.update = function(self)
	local engine = self.sequence.manager.engine
	local startTime = engine.noteChart:hashGet("minTime")
	local endTime = engine.noteChart:hashGet("maxTime")
	local currentTime = engine.exactCurrentTime
	engine:setTimeRate(map(currentTime, startTime, endTime, 0.75, 1.5))
end

return WindUp
