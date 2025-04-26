local Enum = require("rdb.Enum")

---@enum (key) sea.JudgesResult
local JudgesResult = {
	any = 0,
	fc = 1, -- miss_count = 0
	pfc = 2, -- not_perfect_count = 0
}

return Enum(JudgesResult)
