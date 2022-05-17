local Class = require("aqua.util.Class")
local thread	= require("aqua.thread")
local inspect = require("inspect")

local AuthManager = Class:new()

AuthManager.checkSession = thread.coro(function(self)
	local api = self.webApi.api
	local config = self.config

	config.session = {}

	print("check session")
	print("POST " .. api.auth.check)
	local response, code, headers = api.auth.check:_get()
	if not response then
		print(code, headers)
		return
	end
	print(inspect(response))
	config.session = response.session or {}

	if not config.session.user_id then
		return
	end

	print("GET " .. api.users[config.session.user_id])
	local user = api.users[config.session.user_id]:get()
	config.user = user or {}
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

AuthManager.quickGetKey = thread.coro(function(self)
	local api = self.webApi.api
	local config = self.config
	config.quick_login_key = ""

	print("GET " .. api.auth.quick)
	local response, code, headers = api.auth.quick:_get()
	if not response then
		print(code, headers)
		return
	end
	print(inspect(response))

	config.quick_login_key = response.key
	local url = api.html.auth.quick .. "?method=POST&key=" .. response.key
	print(url)
	love.system.openURL(url)
end)

AuthManager.quickGetToken = thread.coro(function(self)
	local api = self.webApi.api
	local config = self.config
	local key = config.quick_login_key

	print("PUT " .. api.auth.quick .. "?key=" .. key)
	local response, code, headers = api.auth.quick:_put({
		key = key,
	})
	if not response then
		print(code, headers)
		return
	end
	print(inspect(response))

	if code ~= 200 then
		print(response.message)
		if code >= 400 and code < 500 then
			self:quickGetKey()
		end
		return
	end

	config.quick_login_key = ""
	config.token = response.token
	self:checkSession()
end)

AuthManager.quickLogin = thread.coro(function(self)
	print("quick login")
	local config = self.config
	local key = config.quick_login_key

	if key and #key ~= 0 then
		self:quickGetToken()
	else
		self:quickGetKey()
	end
end)

AuthManager.login = thread.coro(function(self, email, password)
	print("login")
	local api = self.webApi.api
	local config = self.config

	print("POST " .. api.auth.login)
	local response, code, headers = api.auth.login:_post({
		email = email,
		password = password,
		params = true,
	})
	if not response then
		print(code, headers)
		return
	end

	if code ~= 200 then
		print(response.message)
		return
	end

	print(inspect(response))
	config.token = response.token or ""
	self:checkSession()
end)

return AuthManager
