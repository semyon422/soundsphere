local Modifier = require("sphere.models.RhythmModel.ModifierManager.Modifier")

local TimeRateX = Modifier:new()

TimeRateX.inconsequential = true
TimeRateX.type = "TimeEngineModifier"

TimeRateX.name = "TimeRateX"
TimeRateX.shortName = "TimeRateX"

TimeRateX.variableType = "number"
TimeRateX.variableName = "value"
TimeRateX.variableFormat = "%0.2f"
TimeRateX.variableRange = {0.5, 0.05, 2}

TimeRateX.value = 1

TimeRateX.tostring = function(self)
	return self.value .. "X"
end

TimeRateX.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
end

TimeRateX.apply = function(self)
	self.sequence.manager.timeEngine:createTimeRateHandler().timeRate = self.value
end

return TimeRateX
