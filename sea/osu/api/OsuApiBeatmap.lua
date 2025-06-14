local class = require("class")

---@class sea.OsuApiBeatmap
---@operator call: sea.OsuApiBeatmap
---@field id integer
---@field beatmapset_id integer
---@field status sea.BeatmapStatus
---@field checksum string
local OsuApiBeatmap = class()

return OsuApiBeatmap
