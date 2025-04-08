local ModifierEncoder = require("sphere.models.ModifierEncoder")
local int_rates = require("libchart.int_rates")
local Enum = require("rdb.Enum")
local Gamemode = require("sea.chart.Gamemode")
local stbl = require("stbl")

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

local rate_type = Enum({
	linear = 0,
	exp = 1,
})

local chartdiffs = {}

chartdiffs.table_name = "chartdiffs"

chartdiffs.types = {
	modifiers = modifiers,
	rate = int_rates,
	rate_type = rate_type,
	mode = Gamemode,
	note_types_count = stbl,
	density_data = stbl,
	sv_data = stbl,
}

chartdiffs.relations = {}

return chartdiffs
