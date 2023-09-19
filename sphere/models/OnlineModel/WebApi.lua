local class = require("class")
local thread = require("thread")
local json = require("json")
local socket_url = require("socket.url")

---@class sphere.WebApi
---@operator call: sphere.WebApi
local WebApi = class()

WebApi.host = ""
WebApi.token = ""

---@param level number
---@param body string
---@param ... any?
---@return any?...
function WebApi.processResponse(level, body, ...)
	if level == 2 then
		return body, ...
	end

	local status, json_response = pcall(json.decode, body)
	if not status then
		return nil, ...
	end

	if level == 1 then
		return json_response, ...
	end

	local object
	for k, v in pairs(json_response) do
		if type(v) == "table" and not k:find("^_") then
			object = v
			break
		end
	end
	return object, ...
end

---@param url string
---@param params table?
---@return string?
---@return string|number?
---@return table?
function WebApi.get(url, params)
	local http = require("http")
	local ltn12 = require("ltn12")

	local http_util = require("http_util")

	if params then
		url = url .. "?" .. http_util.encode_query_string(params)
	end

	local t = {}
	local one, code, headers = http.request({
		url = url,
		method = "GET",
		sink = ltn12.sink.table(t),
		headers = {
			["Authorization"] = "Bearer " .. WebApi.token,
		},
	})

	if not one then
		return nil, code
	end

	return table.concat(t), code, headers
end

---@param url string
---@param method string
---@param params table?
---@param buffers table?
---@return string?
---@return string|number?
---@return table?
function WebApi.post(url, method, params, buffers)
	local json = require("json")
	local http = require("http")
	local ltn12 = require("ltn12")
	local http_util = require("http_util")

	local request_buffers = {}
	if params then
		table.insert(request_buffers, {
			json.encode(params), name = "json_params"
		})
	end
	if buffers then
		for _, v in ipairs(buffers) do
			table.insert(request_buffers, v)
		end
	end

	local body, headers = http_util.multipart_form_data(request_buffers)
	headers["Authorization"] = "Bearer " .. WebApi.token

	local t = {}
	local one, code, _headers = http.request({
		url = url,
		method = method,
		sink = ltn12.sink.table(t),
		source = ltn12.source.string(body),
		headers = headers,
	})

	if not one then
		return nil, code
	end

	return table.concat(t), code, _headers
end

---@param url string
---@return table
function WebApi:newResource(url)
	url = socket_url.absolute(self.host, url)
	return setmetatable({__url = url}, self.resource_mt)
end

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
			local url, key = t.__url:match("^(.+)/(.-)$")
			local response, code, headers = thread.async(([[
				local WebApi = require("sphere.models.OnlineModel.WebApi")
				local url = %q
				local key = %q
				local method = key:gsub("_", "")
				WebApi.token = %q
				local body, code, headers
				if method == "get" then
					body, code, headers = WebApi.get(url, ...)
				else
					body, code, headers = WebApi.post(url, method:upper(), ...)
				end
				if not body then
					return nil, code
				end
				local _headers = {}
				for k, v in pairs(headers) do
					_headers[k:lower()] = v
				end
				return WebApi.processResponse(select(2, key:gsub("_", "")), body, code, _headers)
			]]):format(url, key, self.token))(...)
			return response, code, headers
		end
	}
	self.api = self:newResource("/api")
end

return WebApi
