local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.TimeRateQ: sphere.Modifier
---@operator call: sphere.TimeRateQ
local TimeRateQ = Modifier + {}

TimeRateQ.type = "TimeEngineModifier"
TimeRateQ.interfaceType = "slider"

TimeRateQ.name = "TimeRateQ"

TimeRateQ.defaultValue = 0
TimeRateQ.format = "%3s"
TimeRateQ.range = {-10, 10}

TimeRateQ.description = "Rate = 2^(x/10), Quaver issue 666"

---@param config table
---@return string?
function TimeRateQ:getString(config)
    if config.value == -10 then
		return config.value
	elseif config.value ~= 0 then
		return config.value .. "Q"
    end
end

---@param config table
---@return string?
function TimeRateQ:getSubString(config)
    if config.value == -10 then
		return "Q"
    end
end

-- https://github.com/Quaver/Quaver/issues/666
---@param config table
---@param state table
function TimeRateQ:applyMeta(config, state)
	state.timeRate = state.timeRate * 2 ^ (0.1 * config.value)
end

return TimeRateQ
