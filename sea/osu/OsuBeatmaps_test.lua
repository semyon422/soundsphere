local OsuBeatmaps = require("sea.osu.OsuBeatmaps")

local test = {}

---@param t any
function test.all(t)
	local api = {}
	---@cast api sea.OsuApi

	function api:beatmapsets_search(params)
		return {
			beatmapsets = {},
			cursor_string = "",
		}
	end

	local bs = OsuBeatmaps(api)
end

---@param t any
function test.get_status(t)
	local api = {}
	---@cast api sea.OsuApi

	local bs = OsuBeatmaps(api)

	
end

return test
