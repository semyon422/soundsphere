local Modifier = require("sphere.models.ModifierModel.Modifier")

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
    if self.value ~= 1 then
		return self.value .. "X"
    end
end

TimeRateX.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
end

TimeRateX.apply = function(self)
	self.rhythmModel.timeEngine:createTimeRateHandler().timeRate = self.value
end

return TimeRateX
