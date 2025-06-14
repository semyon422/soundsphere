local class = require("class")
local http_util = require("web.http.util")
local json = require("web.json")

---@class sea.OsuOauthClientConfig
---@field client_id integer
---@field client_secret string
---@field redirect_uri string

---@class sea.OsuTokenData
---@field token_type "Bearer"
---@field expires_in integer
---@field access_token string
---@field refresh_token string?

---@class sea.OsuOauthClient
---@operator call: sea.OsuOauthClient
local OsuOauthClient = class()

---@param config sea.OsuOauthClientConfig
function OsuOauthClient:new(config)
	self.config = config
end

function OsuOauthClient:getAuthorizeUrl()
	local config = self.config

	return "https://osu.ppy.sh/oauth/authorize?" .. http_util.encode_query_string({
		client_id = config.client_id,
		redirect_uri = config.redirect_uri,
		response_type = "code",
		scope = "identify",
		state = "csrf_token",
	})
end

---@param grant_type "authorization_code"|"refresh_token"|"client_credentials"
---@param data string?
---@return sea.OsuTokenData?
---@return string?
function OsuOauthClient:getToken(grant_type, data)
	local config = self.config

	local client = http_util.client()
	local req, res = client:connect("https://osu.ppy.sh/oauth/token")

	req.method = "POST"
	req.headers:set("Accept", "application/json")
	req.headers:set("Content-Type", "application/x-www-form-urlencoded")

	local body_params = {
		client_id = config.client_id,
		client_secret = config.client_secret,
		grant_type = grant_type,
	}
	if grant_type == "authorization_code" then
		body_params.redirect_uri = config.redirect_uri
		body_params.code = assert(data, "missing code")
	elseif grant_type == "refresh_token" then
		body_params.refresh_token = assert(data, "missing refresh token")
	elseif grant_type == "client_credentials" then
		body_params.scope = "public"
	end

	local req_data = http_util.encode_query_string(body_params)

	req:set_length(#req_data)
	local bytes, err = req:send(req_data)

	if not bytes then
		return nil, "send: " .. err
	end

	local ok, err = res:receive_headers()

	if not ok then
		return nil, "receive headers: " .. err
	end

	if res.status ~= 200 then
		return nil, "status ~= 200: " .. res.status
	end

	local body, err = res:receive("*a")

	if not body then
		return nil, "receive: " .. err
	end

	---@type sea.OsuTokenData
	local token_data = json.decode(body)

	return token_data
end

return OsuOauthClient
