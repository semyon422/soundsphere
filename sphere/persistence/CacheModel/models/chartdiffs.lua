local ModifierEncoder = require("sphere.models.ModifierEncoder")

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
}

chartdiffs.relations = {}

return chartdiffs
