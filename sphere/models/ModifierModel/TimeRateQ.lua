local Modifier = require("sphere.models.ModifierModel.Modifier")

local TimeRateQ = Modifier:new()

TimeRateQ.type = "TimeEngineModifier"
TimeRateQ.interfaceType = "slider"

TimeRateQ.name = "TimeRateQ"

TimeRateQ.defaultValue = 0
TimeRateQ.format = "%3s"
TimeRateQ.range = {-10, 10}

TimeRateQ.getString = function(self, config)
    if config.value == -10 then
		return config.value
	elseif config.value ~= 0 then
		return config.value .. "Q"
    end
end

TimeRateQ.getSubString = function(self, config)
    if config.value == -10 then
		return "Q"
    end
end

-- https://github.com/Quaver/Quaver/issues/666
TimeRateQ.apply = function(self, config)
	self.rhythmModel.timeEngine:createTimeRateHandler().timeRate = 2 ^ (0.1 * config.value)
	self.rhythmModel.timeEngine:resetTimeRate()
end

return TimeRateQ
