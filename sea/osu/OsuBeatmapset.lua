local class = require("class")

---@class sea.OsuBeatmapset
---@operator call: sea.OsuBeatmapset
---@field id integer
---@field status sea.BeatmapStatus
---@field beatmaps sea.OsuApiBeatmap
---@field updated_at integer
local OsuBeatmapset = class()

return OsuBeatmapset
