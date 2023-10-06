local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.TimeRateX: sphere.Modifier
---@operator call: sphere.TimeRateX
local TimeRateX = Modifier + {}

TimeRateX.interfaceType = "slider"

TimeRateX.name = "TimeRateX"

TimeRateX.defaultValue = 1
TimeRateX.format = "%0.2f"
TimeRateX.range = {0.5, 2}
TimeRateX.step = 0.05

TimeRateX.description = "Change the time rate"

---@param config table
---@return string?
function TimeRateX:getString(config)
	local value = config.value
    if value ~= 1 then
		return math.floor(value) .. "."
	end
end

---@param config table
---@return string?
function TimeRateX:getSubString(config)
	local value = config.value
    if value ~= 1 then
		return tostring(value - math.floor(value)):sub(3) .. "X"
	end
end

---@param config table
---@param state table
function TimeRateX:applyMeta(config, state)
	state.timeRate = state.timeRate * config.value
end

return TimeRateX
