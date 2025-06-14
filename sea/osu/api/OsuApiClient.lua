local class = require("class")
local http_util = require("web.http.util")
local json = require("web.json")

---@class sea.OsuApiClientConfig
---@field client_id integer
---@field client_secret string
---@field redirect_uri string

---@class sea.OsuApiClient
---@operator call: sea.OsuApiClient
local OsuApiClient = class()

---@param token_data sea.OsuTokenData
function OsuApiClient:new(token_data)
	self.token_data = token_data
end

---@param route string
---@param params table?
---@return table?
---@return string?
function OsuApiClient:get(route, params)
	local token_data = assert(self.token_data, "missing token data")

	local url = "https://osu.ppy.sh/api/v2" .. route

	if params then
		url = ("%s?%s"):format(url, http_util.encode_query_string(params))
	end

	local client = http_util.client()
	local req, res = client:connect(url)

	req.headers:set("Authorization", "Bearer " .. token_data.access_token)
	req.headers:set("Accept", "application/json")

	local ok, err = req:send_headers()

	if not ok then
		return nil, "send: " .. err
	end

	local body, err = res:receive("*a")

	if not body then
		return nil, "receive: " .. err
	end

	if res.status ~= 200 then
		return nil, "status ~= 200: " .. body
	end

	-- {"authentication":"basic"}

	return json.decode(body)
end

return OsuApiClient
