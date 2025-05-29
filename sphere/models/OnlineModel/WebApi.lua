local class = require("class")
local thread = require("thread")
local json = require("json")
local socket_url = require("socket.url")

---@class sphere.WebApi
---@operator call: sphere.WebApi
local WebApi = class()

WebApi.host = ""
WebApi.token = ""

---@param url string
---@return table
function WebApi:newResource(url)
	url = socket_url.absolute(self.host, url)
	return setmetatable({__url = url}, self.resource_mt)
end

---@param body string
---@param ... any?
---@return any?...
function WebApi.processResponse(body, ...)
	local status, json_response = pcall(json.decode, body)
	if not status then
		return nil, json_response
	end
	return json_response, ...
end

---@param url string
---@param method web.HttpMethod
---@param params table?
---@return string?
---@return integer|string?
---@return web.Headers?
function WebApi.request(url, method, params)
	local http_util = require("web.http.util")
	local HttpClient = require("web.http.HttpClient")
	local LsTcpSocket = require("web.luasocket.LsTcpSocket")

	if method == "GET" and params then
		url = url .. "?" .. http_util.encode_query_string(params)
	end

	local soc = LsTcpSocket(4)
	local client = HttpClient(soc)

	local req, res = client:connect(url)

	req.method = method
	req.headers:set("Authorization", "Bearer " .. WebApi.token)
	req.headers:set("Content-Type", "application/json")
	req:set_chunked_encoding()
	if method ~= "GET" and params then
		req:send(json.encode(params))
	end
	req:send("")

	local data, err = res:receive("*a")
	print(res.status)
	print(data, err)

	if not data then
		return nil, err
	end

	return data, res.status, res.headers
end

local requestAsync = thread.async(function(url, method, token, ...)
	local WebApi = require("sphere.models.OnlineModel.WebApi")
	WebApi.token = token
	local body, code, headers = WebApi.request(url, method:upper(), ...)
	if not body then
		return nil, code
	end
	return WebApi.processResponse(body, code, headers)
end)

function WebApi:load()
	self.resource_mt = {
		__index = function(t, k)
			return rawget(t, k) or setmetatable({
				__url = rawget(t, "__url") .. "/" .. k,
			}, getmetatable(t))
		end,
		__tostring = function(t)
			return rawget(t, "__url")
		end,
		__concat = function(t, a)
			return tostring(t) .. tostring(a)
		end,
		__call = function(t, s, ...)
			local url, method = t.__url:match("^(.+)/(.-)$")
			return requestAsync(url, method, self.token, ...)
		end
	}
	self.api = self:newResource("/api")
end

return WebApi
