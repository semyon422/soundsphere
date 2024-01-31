local ModifierEncoder = require("sphere.models.ModifierEncoder")
local sql_util = require("rdb.sql_util")

local modifiers = {}

---@param t table
---@return string|sql_util.NULL
function modifiers.encode(t)
	if not t[1] then
		return sql_util.NULL
	end
	return ModifierEncoder:encode(t)
end

---@param t string?
---@return table
function modifiers.decode(t)
	if not t then
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
