local Enum = require("rdb.Enum")

---@enum (key) sea.ComputeTarget
local ComputeTarget = {
	chartplays = 0,
	chartdiffs = 1,
	chartmetas = 2,
	users = 3,
	total_rating = 4,
	ranks = 5,
}

return Enum(ComputeTarget)
