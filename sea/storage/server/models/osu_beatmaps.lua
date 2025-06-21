local OsuBeatmap = require("sea.osu.OsuBeatmap")
local BeatmapStatus = require("sea.osu.BeatmapStatus")

---@type rdb.ModelOptions
local osu_beatmaps = {}

osu_beatmaps.metatable = OsuBeatmap

osu_beatmaps.types = {
	status = BeatmapStatus,
}

return osu_beatmaps
