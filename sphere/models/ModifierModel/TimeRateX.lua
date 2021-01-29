local Modifier = require("sphere.models.ModifierModel.Modifier")

local TimeRateX = Modifier:new()

TimeRateX.type = "TimeEngineModifier"

TimeRateX.name = "TimeRateX"
TimeRateX.shortName = "X"

TimeRateX.defaultValue = 10
TimeRateX.format = "%0.2f"
TimeRateX.step = 0.05
TimeRateX.offset = 0.5
TimeRateX.range = {0, 30}

TimeRateX.getString = function(self, config)
	config = config or self.config
	return self:getRealValue(config) .. self.shortName
end

TimeRateX.apply = function(self)
	self.rhythmModel.timeEngine:createTimeRateHandler().timeRate = self:getRealValue()
end

return TimeRateX
