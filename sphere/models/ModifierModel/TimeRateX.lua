local Modifier = require("sphere.models.ModifierModel.Modifier")

local TimeRateX = Modifier + {}

TimeRateX.type = "TimeEngineModifier"
TimeRateX.interfaceType = "slider"

TimeRateX.name = "TimeRateX"

TimeRateX.defaultValue = 1
TimeRateX.format = "%0.2f"
TimeRateX.range = {0.5, 2}
TimeRateX.step = 0.05

TimeRateX.description = "Change the time rate"

function TimeRateX:getString(config)
	local value = config.value
    if value ~= 1 then
		return math.floor(value) .. "."
	end
end

function TimeRateX:getSubString(config)
	local value = config.value
    if value ~= 1 then
		return tostring(value - math.floor(value)):sub(3) .. "X"
	end
end

function TimeRateX:applyMeta(config, state)
	state.timeRate = state.timeRate * config.value
end

return TimeRateX
