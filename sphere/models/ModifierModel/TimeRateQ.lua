local Modifier = require("sphere.models.ModifierModel.Modifier")

local TimeRateQ = Modifier:new()

TimeRateQ.inconsequential = true
TimeRateQ.type = "TimeEngineModifier"

TimeRateQ.name = "TimeRateQ"
TimeRateQ.shortName = "TimeRateQ"

TimeRateQ.variableType = "number"
TimeRateQ.variableName = "value"
TimeRateQ.variableFormat = "%3s"
TimeRateQ.variableRange = {-10, 1, 10}

TimeRateQ.value = 0

TimeRateQ.tostring = function(self)
	return self.value .. "Q"
end

TimeRateQ.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
end

-- https://github.com/Quaver/Quaver/issues/666
TimeRateQ.apply = function(self)
	self.rhythmModel.timeEngine:createTimeRateHandler().timeRate = 2 ^ (0.1 * self.value)
end

return TimeRateQ
