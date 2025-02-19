local Enum = require("rdb.Enum")

---@enum (key) sea.RatingCalc
local RatingCalc = {
	level = 0,
	enps = 1,
	pp = 2,
	msd = 3,
}

return Enum(RatingCalc)
