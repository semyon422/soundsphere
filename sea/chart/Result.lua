local Enum = require("rdb.Enum")

---@enum (key) sea.Result
local Result = {
	fail = 0, -- determined by sea.Healths
	pass = 1, -- determined by sea.Healths
	fc = 2, -- miss_count = 0
	pfc = 3, -- not_perfect_count = 0
}

return Enum(Result)
