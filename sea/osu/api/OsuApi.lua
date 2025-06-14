local class = require("class")

---@class sea.OsuCursor
---@field id integer
---@field approved_date integer unix time ms

--- https://github.com/ppy/osu-web/blob/master/app/Libraries/Search/BeatmapsetSearchRequestParams.php
---@class sea.OsuBeatmapsetSearchRequestParams
---@field c string?
---@field e string?
---@field g integer?
---@field l integer?
---@field m integer?
---@field nsfw boolean?
---@field page integer?
---@field played string?
---@field q string?
---@field query string?
---@field r sea.BeatmapStatus?
---@field s string?
---@field sort string?

---@class sea.OsuBeatmapsetSearchResponse
---@field beatmapsets sea.OsuApiBeatmapset[]
---@field search {sort: string}
---@field recommended_difficulty number?
---@field error string?
---@field total integer
---@field cursor sea.OsuCursor
---@field cursor_string string base64(json.encode(cursor))

---@generic T
---@param f T
---@return T
local function wrap_check_auth(f)
	---@cast f fun(...: any): table?, string?
	return function(...)
		local res, err = f(...)

		if not res then
			return nil, err
		end

		if res.authentication then
			return nil, "not authenticated"
		end

		return res
	end
end

---@class sea.OsuApi
---@operator call: sea.OsuApi
local OsuApi = class()

---@param client sea.OsuApiClient
function OsuApi:new(client)
	self.client = client
end

---@param params sea.OsuBeatmapsetSearchRequestParams
---@return sea.OsuBeatmapsetSearchResponse?
---@return string?
function OsuApi:beatmapsets_search(params)
	return self.client:get("/beatmapsets/search", params)
end

OsuApi.beatmapsets_search = wrap_check_auth(OsuApi.beatmapsets_search)

return OsuApi
