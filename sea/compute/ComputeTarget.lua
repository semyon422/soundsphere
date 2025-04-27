local Enum = require("rdb.Enum")

---@enum (key) sea.ComputeTarget
local ComputeTarget = {
	chartplays = 0,
	chartdiffs = 1,
	chartmetas = 2,
	leaderboard_users = 3,
	users = 4,
}

return Enum(ComputeTarget)
