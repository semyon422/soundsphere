local Enum = require("rdb.Enum")

---@enum (key) sea.old.Formats
local Formats = {
	undefined = 0,
	osu = 1,
	quaver = 2,
	bms = 3,
	ksm = 4,
	o2jam = 5,
	midi = 6,
	stepmania = 7,
	sph = 255,
}

return Enum(Formats)
