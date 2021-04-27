local Modifier = require("sphere.models.ModifierModel.Modifier")

local TimeRateX = Modifier:new()

TimeRateX.type = "TimeEngineModifier"
TimeRateX.interfaceType = "slider"

TimeRateX.name = "TimeRateX"

TimeRateX.defaultValue = 1
TimeRateX.format = "%0.2f"
TimeRateX.range = {0.5, 2}
TimeRateX.step = 0.05

TimeRateX.getString = function(self, config)
	local value = config.value
    if value ~= 1 then
		return value .. "X"
	end
end

TimeRateX.apply = function(self, config)
	self.rhythmModel.timeEngine:createTimeRateHandler().timeRate = config.value
end

return TimeRateX
