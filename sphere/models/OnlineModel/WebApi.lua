local Class = require("aqua.util.Class")
local thread = require("aqua.thread")
local json = require("json")

local WebApi = Class:new()

WebApi.token = ""

WebApi.processResponse = function(level, response)
	local code = response.code

	local headers = {}
	for k, v in pairs(response.headers) do
		headers[k:lower()] = v
	end

	if level == 3 then
		return response
	elseif level == 2 then
		return response.body, code, headers
	end

	local status, json_response = pcall(json.decode, response.body)

	if not status then
		return nil, code, headers
	end

	if level == 1 then
		return json_response, code, headers
	end

	local object
	for k, v in pairs(json_response) do
		if type(v) == "table" and not k:find("^_") then
			object = v
			break
		end
	end
	return object, code, headers
end

WebApi.get = function(url, params)
	local request = require("luajit-request")
	local encode_query_string = require("aqua.util.encode_query_string")
	require("preloaders.preloadall")

	if params then
		url = url .. "?" .. encode_query_string(params)
	end
	return request.send(url, {
		method = "GET",
		headers = {
			["Authorization"] = "Bearer " .. WebApi.token,
		},
	})
end

WebApi.post = function(url, method, params, buffers)
	local json = require("json")
	local request = require("luajit-request")
	require("preloaders.preloadall")

	local request_buffers = {json_params = json.encode(params)}
	if buffers then
		for k, v in pairs(buffers) do
			request_buffers[k] = v
		end
	end

	return request.send(url, {
		method = method,
		buffers = request_buffers,
		headers = {
			["Authorization"] = "Bearer " .. WebApi.token,
		},
	})
end

WebApi.newResource = function(self, url)
	return setmetatable({__url = url}, self.resource_mt)
end

WebApi.load = function(self)
	local config = self.config

	self.resource_mt = {
		__index = function(t, k)
			return setmetatable({
				__url = rawget(t, "__url") .. "/" .. k,
			}, getmetatable(t))
		end,
		__call = function(t, s, ...)
			local url, key = t.__url:match("^(.+)/(.-)$")
			local response, code, headers = thread.async(([[
				local WebApi = require("sphere.models.OnlineModel.WebApi")
				local url = %q
				local key = %q
				local method = key:gsub("_", "")
				WebApi.token = %q
				local response, code, err
				if method == "get" then
					response, code, err = WebApi.get(url, ...)
				else
					response, code, err = WebApi.post(url, method:upper(), ...)
				end
				if not response then
					return false, code, err
				end
				return WebApi.processResponse(select(2, key:gsub("_", "")), response)
			]]):format(url, key, config.token))({...})
			return response, code, headers
		end
	}
	self.api = self:newResource(config.host)
end

return WebApi
