local Enum = require("rdb.Enum")

---@enum (key) sea.old.Inputmodes
local Inputmodes = {
	["undefined"] = 0,
	["1key"] = 1,
	["2key"] = 2,
	["3key"] = 3,
	["4key"] = 4,
	["5key"] = 5,
	["6key"] = 6,
	["7key"] = 7,
	["8key"] = 8,
	["9key"] = 9,
	["10key"] = 10,
	["12key"] = 12,
	["14key"] = 14,
	["16key"] = 16,
	["18key"] = 18,
	["20key"] = 20,
	["5key1scratch"] = 105,
	["5key1pedal1scratch"] = 115,
	["7key1scratch"] = 107,
	["7key1pedal1scratch"] = 117,
	["10key2scratch"] = 210,
	["14key2scratch"] = 214,
	["24key"] = 24,
	["26key"] = 26,
	["48key"] = 48,
	["88key"] = 88,
	["4bt2fx2ll2lr"] = 255,
}

return Enum(Inputmodes)
