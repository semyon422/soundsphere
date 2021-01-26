local Modifier = require("sphere.models.ModifierModel.Modifier")

local TimeRateX = Modifier:new()

TimeRateX.type = "TimeEngineModifier"

TimeRateX.name = "TimeRateX"
TimeRateX.shortName = "X"

TimeRateX.defaultValue = 1
TimeRateX.format = "%0.2f"
TimeRateX.range = {0.5, 0.05, 2}

TimeRateX.tostring = function(self)
	return self.value .. self.shortName
end

TimeRateX.apply = function(self)
	self.rhythmModel.timeEngine:createTimeRateHandler().timeRate = self.value
end

return TimeRateX
