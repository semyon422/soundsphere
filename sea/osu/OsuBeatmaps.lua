local class = require("class")

---@class sea.OsuBeatmaps
---@operator call: sea.OsuBeatmaps
local OsuBeatmaps = class()

---@param api sea.OsuApi
function OsuBeatmaps:new(api)
	self.api = api
end

function OsuBeatmaps:sync()
	local api = self.api

	local res, err = api:beatmapsets_search({
		r = "ranked",
	})

	if not res then
		return nil, err
	end

	print(require("stbl").encode(res))
end

return OsuBeatmaps
