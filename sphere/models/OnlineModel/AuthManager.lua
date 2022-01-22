local Class = require("aqua.util.Class")
local thread	= require("aqua.thread")
local inspect = require("inspect")

local AuthManager = Class:new()

AuthManager.checkSession = function(self)
	print("check session")
	local api = self.webApi.api
	local config = self.config

	thread.call(function()
		print("POST " .. config.host .. "/auth/check")
		local response = api.auth.check:_get()
		print(inspect(response))
		if not response then
			return
		end
		config.session = response.session or {}
	end)
end

AuthManager.updateSession = function(self)
	print("update session")
	local api = self.webApi.api
	local config = self.config

	thread.call(function()
		print("POST " .. config.host .. "/auth/update")
		local response = api.auth.update:_post()
		print(inspect(response))
		if not response then
			return
		end
		config.session = response.session or {}
		config.token = response.token or ""
	end)
end

AuthManager.quickLogin = function(self)
	print("quick login")
	local api = self.webApi.api
	local config = self.config
	local key = config.quick_login_key

	thread.call(function()
		local response
		if key and #key ~= 0 then
			print("GET 2 " .. config.host .. "/auth/quick")
			response = api.auth.quick:_get({
				key = key,
			})
		else
			print("GET " .. config.host .. "/auth/quick")
			response = api.auth.quick:_get()
		end
		print(inspect(response))
		if response.key then
			config.quick_login_key = response.key
			local url = config.host .. "/html/auth/quick?key=" .. response.key
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
end

return AuthManager
