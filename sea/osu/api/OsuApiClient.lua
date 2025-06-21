local class = require("class")
local http_util = require("web.http.util")
local json = require("web.json")

---@class sea.OsuApiClient
---@operator call: sea.OsuApiClient
local OsuApiClient = class()

OsuApiClient.access_token = ""

---@param access_token string
function OsuApiClient:setAccessToken(access_token)
	self.access_token = access_token
end

---@param route string
---@param params table?
---@return table?
---@return string?
function OsuApiClient:get(route, params)
	local access_token = assert(self.access_token, "missing access token")

	local url = "https://osu.ppy.sh/api/v2" .. route

	if params then
		url = ("%s?%s"):format(url, http_util.encode_query_string(params))
	end

	local client = http_util.client()
	local req, res = client:connect(url)

	req.headers:set("Authorization", "Bearer " .. access_token)
	req.headers:set("Accept", "application/json")

	local ok, err = req:send_headers()

	if not ok then
		return nil, "send: " .. err
	end

	local body, err = res:receive("*a")

	if not body then
		return nil, "receive: " .. err
	end

	local obj, err = json.decode_safe(body)

	if not obj then
		return nil, "decode json: " .. err
	end

	return json.decode_safe(body)
end

return OsuApiClient
