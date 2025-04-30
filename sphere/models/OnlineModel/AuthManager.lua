local class = require("class")
local thread = require("thread")
local inspect = require("inspect")

---@class sphere.AuthManager
---@operator call: sphere.AuthManager
---@field config table
local AuthManager = class()

---@param sea_client sphere.SeaClient
function AuthManager:new(sea_client)
	self.sea_client = sea_client
end

function AuthManager:checkUserAsync()
	print("check user")
	local server_remote = self.sea_client.remote
	self.config.user = server_remote:getUser()
	print("user", inspect(self.config.user))
end
AuthManager.checkUser = thread.coro(AuthManager.checkUserAsync)

function AuthManager:checkSessionAsync()
	print("check session")
	local server_remote = self.sea_client.remote
	self.config.session = server_remote:getSession()
	print("session", inspect(self.config.session))

	self:checkUserAsync()
end
AuthManager.checkSession = thread.coro(AuthManager.checkSessionAsync)

function AuthManager:quickGetKeyAsync()
	local api = self.webApi.api
	local config = self.config
	config.quick_login_key = ""

	print("GET " .. api.auth.quick)
	local response, code, headers = api.auth.quick:_get()
	if not response then
		print(code, headers)
		return
	end

	config.quick_login_key = response.key
	local url = api.html.auth.quick .. "?method=POST&key=" .. response.key
	print(url)
	love.system.openURL(url)
end
AuthManager.quickGetKey = thread.coro(AuthManager.quickGetKeyAsync)

function AuthManager:quickGetTokenAsync()
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

	if code ~= 200 then
		print(response.message)
		if code >= 400 and code < 500 then
			self:quickGetKeyAsync()
		end
		return
	end

	config.quick_login_key = ""
	config.token = response.token or ""
	config.session = response.session or {}

	self:checkUserAsync()
end
AuthManager.quickGetToken = thread.coro(AuthManager.quickGetTokenAsync)

function AuthManager:quickLogin()
	print("quick login")
	local config = self.config
	local key = config.quick_login_key

	if key and #key ~= 0 then
		self:quickGetToken()
	else
		self:quickGetKey()
	end
end

---@param email string
---@param password string
function AuthManager:loginAsync(email, password)
	print("login")
	local api = self.webApi.api.v2.auth
	local config = self.config

	print("POST " .. api.login)
	local response, code, headers = api.login:post({
		email = email,
		password = password,
	})
	if not response then
		print(code, headers)
		return
	end

	if code ~= 200 then
		print(code)
		return
	end

	if not response.token then
		print(table.concat(response.errors, ", "))
		return
	end

	config.token = response.token
	config.session = response.session

	self:checkUserAsync()
end
AuthManager.login = thread.coro(AuthManager.loginAsync)

function AuthManager:logoutAsync()
	local webApi = self.webApi
	local api = webApi.api
	local config = self.config

	config.session = {}
	config.user = {}
	config.token = ""

	webApi.token = config.token

	print("POST " .. api.auth.logout)
	api.auth.update:post()
end
AuthManager.logout = thread.coro(AuthManager.logoutAsync)

return AuthManager
