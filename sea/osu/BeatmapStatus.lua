local Enum = require("rdb.Enum")

---@enum (key) sea.BeatmapStatus
local BeatmapStatus = {
	loved = 4,
	qualified = 3,
	approved = 2,
	ranked = 1,
	pending = 0,
	wip = -1,
	graveyard = -2,
}

return Enum(BeatmapStatus)
