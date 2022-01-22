local Class = require("aqua.util.Class")
local thread = require("aqua.thread")

local WebApi = Class:new()

WebApi.token = ""

WebApi.processResponse = function(method, response)
	if not response then return end
	local json = require("json")
	if method:find("^___") then
		return response
	elseif method:find("^__") and response then
		if response.body then
			return response.body
		end
		return ""
	elseif method:find("^_") then
		if response.body then
			local status, err = pcall(json.decode, response.body)
			if status then
				return err
			end
		end
		return {}
	end
	local object = {}
	if response.body then
		local status, err = pcall(json.decode, response.body)
		if status then
			object = err
		end
	end
	for _, v in pairs(object) do
		if type(v) == "table" then
			return v
		end
	end
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

WebApi.load = function(self)
	local config = self.config

	self.api = {}

	local mt
	mt = {
		__index = function(t, k)
			local prevPath = rawget(t, "path")
			local path = (prevPath or "") .. "/" .. k
			return setmetatable({
				path = path,
				key = k,
				prevPath = prevPath,
			}, mt)
		end,
		__call = function(t, s, ...)
			return thread.async(([[
				local WebApi = require("sphere.models.OnlineModel.WebApi")
				local method = %q
				local field = method:gsub("_", "")
				local host = %q
				local path = %q
				WebApi.token = %q
				local response
				if field == "get" then
					response = WebApi.get(host .. path, unpack(...))
				else
					response = WebApi.post(host .. path, field:upper(), unpack(...))
				end
				return WebApi.processResponse(method, response)
			]]):format(t.key, config.host, t.prevPath, config.token))({...})
		end
	}
	setmetatable(self.api, mt)
end

return WebApi
