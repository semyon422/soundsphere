local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local TimeRate = Modifier:new()

TimeRate.inconsequential = true
TimeRate.type = "TimeEngineModifier"

TimeRate.name = "TimeRate"
TimeRate.shortName = "TimeRate"

TimeRate.variableType = "number"
TimeRate.variableName = "value"
TimeRate.variableFormat = "%0.2f"
TimeRate.variableRange = {0.5, 0.05, 2}

TimeRate.value = 1

TimeRate.tostring = function(self)
	return self.value .. "X"
end

TimeRate.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
end

TimeRate.apply = function(self)
	local timeEngine = self.sequence.manager.timeEngine
	timeEngine.baseTimeRate = self.value
end

return TimeRate
