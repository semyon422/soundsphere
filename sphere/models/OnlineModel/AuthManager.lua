local Class = require("aqua.util.Class")
local thread	= require("aqua.thread")
local inspect = require("inspect")

local AuthManager = Class:new()

AuthManager.checkSession = thread.coro(function(self)
	local api = self.webApi.api
	local config = self.config

	print("check session")
	print("POST " .. api.auth.check)
	local response, code, headers = api.auth.check:_get()
	if not response then
		print(code, headers)
		return
	end
	print(inspect(response))
	print(inspect(headers))
	config.session = response.session or {}
end)

AuthManager.updateSession = thread.coro(function(self)
	local api = self.webApi.api
	local config = self.config

	print("update session")
	print("POST " .. api.auth.update)
	local response, code, headers = api.auth.update:_post()
	if not response then
		print(code, headers)
		return
	end
	print(inspect(response))
	config.session = response.session or {}
	config.token = response.token or ""
end)

AuthManager.quickLogin = thread.coro(function(self)
	print("quick login")
	local api = self.webApi.api
	local config = self.config
	local key = config.quick_login_key

	local response, code, headers
	if key and #key ~= 0 then
		print("GET " .. api.auth.quick .. "?key=" .. key)
		response, code, headers = api.auth.quick:_get({
			key = key,
		})
	else
		print("GET " .. api.auth.quick)
		response, code, headers = api.auth.quick:_get()
	end
	if not response then
		print(code, headers)
		return
	end
	print(inspect(response))

	if response.key then
		config.quick_login_key = response.key
		local url = api.auth.quick .. "?key=" .. response.key
		print(url)
		love.system.openURL(url)
	elseif response.token then
		config.quick_login_key = ""
		config.token = response.token
		self:checkSession()
	else
		config.quick_login_key = ""
	end
end)

return AuthManager
