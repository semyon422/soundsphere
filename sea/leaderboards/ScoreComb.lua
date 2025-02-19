local Enum = require("rdb.Enum")

---@enum (key) sea.ScoreComb
local ScoreComb = {
	avg = 0,
	exp95 = 1,
}

return Enum(ScoreComb)
