local class = require("class")
local table_util = require("table_util")

---@class sphere.ModifierRegistry
---@operator call: sphere.ModifierRegistry
local ModifierRegistry = class()

---@param id integer
---@return string
function ModifierRegistry:getName(id)
	return assert(table_util.keyof(self.enum, id))
end

ModifierRegistry.enum = {
	-- AutoPlay = 0,
	-- ProMode = 1,
	-- AutoKeySound = 2,
	-- ConstSpeed = 3,
	-- TimeRateQ = 4,
	-- TimeRateX = 5,
	WindUp = 6,
	-- AudioClip = 7,
	NoScratch = 8,
	NoLongNote = 9,
	-- NoMeasureLine = 10,
	Automap = 11,
	MultiplePlay = 12,
	MultiOverPlay = 13,
	Alternate = 14,
	Shift = 15,
	Mirror = 16,
	Random = 17,
	BracketSwap = 18,
	FullLongNote = 19,
	MinLnLength = 20,
	-- ToOsu = 21,
	Alternate2 = 22,
	LessChord = 23,
	MaxChord = 24,
	Taiko = 25,
}

ModifierRegistry.list = {
	"WindUp",
	"NoScratch",
	"NoLongNote",
	"Automap",
	"MultiplePlay",
	"MultiOverPlay",
	"Taiko",
	"Alternate",
	"Alternate2",
	"Shift",
	"Mirror",
	"Random",
	"BracketSwap",
	"MaxChord",
	"LessChord",
	"FullLongNote",
	"MinLnLength",
}

return ModifierRegistry
