local class = require("class")
local http_util = require("web.http.util")
local json = require("web.json")

---@class sea.BeatmapStatusCache
---@operator call: sea.BeatmapStatusCache
local BeatmapStatusCache = class()

---@param api_key string
function BeatmapStatusCache:new(api_key)
	self.api_key = api_key
end

---@param hash string
---@return sea.BeatmapStatus?
---@return string?
function BeatmapStatusCache:getStatus(hash)
	local body, status, headers = http_util.request("https://osu.ppy.sh/api/get_beatmaps?" .. http_util.encode_query_string({
		k = self.api_key,
		h = hash,
		m = 3,
		limit = 1,
	}))

	if not body then
		return nil, tostring(status)
	end

	if status ~= 200 then
		return nil, "status ~= 200"
	end

	local beatmaps = json.decode(body)
	if #beatmaps == 0 then
		return nil, "beatmap not found"
	end

	return tonumber(beatmaps[1].approved)
end

return BeatmapStatusCache
