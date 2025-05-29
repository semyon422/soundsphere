local Enum = require("rdb.Enum")

---@enum (key) sea.RankingType
local RankingType = {
	rating = 0,
	accuracy = 1,
	charts = 2,
	play_count = 3,
	play_time = 4,
	social_rating = 5,
}

return Enum(RankingType)
