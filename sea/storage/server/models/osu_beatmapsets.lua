local OsuBeatmapset = require("sea.osu.OsuBeatmapset")
local BeatmapStatus = require("sea.osu.BeatmapStatus")

---@type rdb.ModelOptions
local osu_beatmapsets = {}

osu_beatmapsets.metatable = OsuBeatmapset

osu_beatmapsets.types = {
	status = BeatmapStatus,
}

return osu_beatmapsets
