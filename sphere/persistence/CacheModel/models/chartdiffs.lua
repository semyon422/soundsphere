local ModifierEncoder = require("sphere.models.ModifierEncoder")
local int_rates = require("libchart.int_rates")

local modifiers = {}

---@param t table
---@return string
function modifiers.encode(t)
	if not t[1] then
		return ""
	end
	return ModifierEncoder:encode(t)
end

---@param t string
---@return table
function modifiers.decode(t)
	if t == "" then
		return {}
	end
	return ModifierEncoder:decode(t)
end

local chartdiffs = {}

chartdiffs.table_name = "chartdiffs"

chartdiffs.types = {
	modifiers = modifiers,
	rate = int_rates,
	is_exp_rate = "boolean",
}

chartdiffs.relations = {}

return chartdiffs
