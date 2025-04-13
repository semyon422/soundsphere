local class = require("class")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")
local Gamemode = require("sea.chart.Gamemode")
local table_util = require("table_util")

---@class sea.ChartdiffKeyPart
---@operator call: sea.ChartdiffKeyPart
---@field modifiers sea.Modifier[]
---@field rate number
---@field mode sea.Gamemode
local ChartdiffKeyPart = class()

ChartdiffKeyPart.struct = {
	modifiers = chart_types.modifiers,
	rate = types.number,
	mode = types.new_enum(Gamemode),
}

assert(#table_util.keys(ChartdiffKeyPart.struct) == 3)

---@param key sea.ChartdiffKeyPart
---@return boolean
function ChartdiffKeyPart:equalsChartdiffKeyPart(key)
	return
		table_util.deepequal(self.modifiers, key.modifiers) and
		self.rate == key.rate and
		self.mode == key.mode
end

return ChartdiffKeyPart
