local Enum = require("rdb.Enum")

---@enum (key) sea.TernaryState
local TernaryState = {
	disabled = 0,
	enabled = 1,
	any = 2,
}

return Enum(TernaryState)
