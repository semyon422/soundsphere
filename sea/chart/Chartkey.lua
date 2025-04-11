local class = require("class")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")
local Gamemode = require("sea.chart.Gamemode")
local table_util = require("table_util")

---@class sea.Chartkey
---@operator call: sea.Chartkey
---@field hash string
---@field index integer
---@field modifiers sea.Modifier[]
---@field rate number
---@field mode sea.Gamemode
local Chartkey = class()

Chartkey.struct = {
	hash = types.md5hash,
	index = types.index,
	modifiers = chart_types.modifiers,
	rate = types.number,
	mode = types.new_enum(Gamemode),
}

---@param key sea.Chartkey
---@return boolean
function Chartkey:equalsChartkey(key)
	return
		self.hash == key.hash and
		self.index == key.index and
		table_util.deepequal(self.modifiers, key.modifiers) and
		self.rate == key.rate and
		self.mode == key.mode
end

return Chartkey
