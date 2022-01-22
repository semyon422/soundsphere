local thread = require("aqua.thread")

local WebApi = {}

WebApi.processResponse = function(method, response)
	local json = require("json")
	if method:find("^___") then
		return response
	elseif method:find("^__") then
		return response.body
	elseif method:find("^_") then
		return json.decode(response.body)
	end
	for _, v in pairs(json.decode(response.body)) do
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
	return request.send(url)
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
	})
end

WebApi.init = function(self)
	-- local config = self.config
	-- self.host = config.host
	self.host = "http://localhost"

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
				local response
				if field == "get" then
					response = WebApi.get(host .. "/api" .. path, unpack(...))
				else
					response = WebApi.post(host .. "/api" .. path, field:upper(), unpack(...))
				end
				return WebApi.processResponse(method, response)
			]]):format(t.key, self.host, t.prevPath))({...})
		end
	}
	setmetatable(self.api, mt)
end

return WebApi
