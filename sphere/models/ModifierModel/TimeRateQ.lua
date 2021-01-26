local Modifier = require("sphere.models.ModifierModel.Modifier")

local TimeRateQ = Modifier:new()

TimeRateQ.type = "TimeEngineModifier"

TimeRateQ.name = "TimeRateQ"
TimeRateQ.shortName = "Q"

TimeRateQ.defaultValue = 0
TimeRateQ.format = "%3s"
TimeRateQ.range = {-10, 1, 10}

TimeRateQ.tostring = function(self)
	return self.value .. self.shortName
end

-- https://github.com/Quaver/Quaver/issues/666
TimeRateQ.apply = function(self)
	self.rhythmModel.timeEngine:createTimeRateHandler().timeRate = 2 ^ (0.1 * self.value)
end

return TimeRateQ
