local Enum = require("rdb.Enum")

---@enum (key) sea.ComputeState
local ComputeState = {
	new = 0,
	valid = 1,
	invalid = 2,
}

return Enum(ComputeState)
