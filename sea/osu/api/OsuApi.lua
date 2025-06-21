local class = require("class")
local table_util = require("table_util")
local OsuApiClient = require("sea.osu.api.OsuApiClient")
local OsuOauthClient = require("sea.osu.api.OsuOauthClient")

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

---@class sea.OsuApi
---@operator call: sea.OsuApi
local OsuApi = class()

---@param config sea.OsuOauthClientConfig
---@param grant_type sea.OsuApiGrantType
---@param token_data sea.OsuTokenData?
function OsuApi:new(config, grant_type, token_data)
	token_data = token_data or {}

	self.grant_type = grant_type
	self.token_data = token_data

	self.api_client = OsuApiClient()
	self.oauth_client = OsuOauthClient(config)

	self.api_client:setAccessToken(token_data.access_token)

	self.token_updated = false
end

---@return boolean?
---@return string?
function OsuApi:reauth()
	local grant_type = self.grant_type
	local token_data = self.token_data

	local new_token_data, err = self.oauth_client:getToken(grant_type, token_data.refresh_token)
	if not new_token_data then
		return nil, err
	end

	table_util.clear(token_data)
	table_util.copy(new_token_data, token_data)

	self.api_client:setAccessToken(token_data.access_token)

	self.token_updated = true

	return true
end

---@param route string
---@param params table?
---@param again boolean?
---@return table?
---@return string?
function OsuApi:get(route, params, again)
	local res, err = self.api_client:get(route, params)

	if not res then
		return nil, err
	end

	if not res.authentication then
		return res
	end

	if again then
		return nil, "new token does not work"
	end

	local ok, err = self:reauth()
	if not ok then
		return nil, "reauth: " .. err
	end

	return self:get(route, params, true)
end

---@param params sea.OsuBeatmapsetSearchRequestParams
---@return sea.OsuBeatmapsetSearchResponse?
---@return string?
function OsuApi:beatmapsets_search(params)
	return self:get("/beatmapsets/search", params)
end

return OsuApi
