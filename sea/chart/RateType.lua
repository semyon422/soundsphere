local Enum = require("rdb.Enum")

---@enum (key) sea.RateType
local RateType = {
	linear = 0,
	exp = 1,
}

return Enum(RateType)
