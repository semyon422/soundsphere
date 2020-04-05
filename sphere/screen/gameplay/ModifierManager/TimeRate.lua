local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local TimeRate = InconsequentialModifier:new()

TimeRate.name = "TimeRate"
TimeRate.shortName = "TimeRate"

TimeRate.type = "number"
TimeRate.variable = "value"
TimeRate.format = "%0.2f"
TimeRate.range = {0.5, 0.05, 2}
TimeRate.value = 1

TimeRate.tostring = function(self)
	return self.value .. "X"
end

TimeRate.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
end

TimeRate.apply = function(self)
	local logicEngine = self.sequence.manager.logicEngine
	local timeEngine = self.sequence.manager.timeEngine
	-- logicEngine.score.timeRate = true
	-- timeEngine.timeRate = self.value
	-- timeEngine.targetTimeRate = self.value
	-- timeEngine:setTimeRate(self.value)
end

return TimeRate
