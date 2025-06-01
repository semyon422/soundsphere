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
	local sea_client = self.sea_client
	local user = sea_client.remote:getUser()
	sea_client.client:setUser(user)
	self.config.user = user
	print("user", inspect(user))
end
AuthManager.checkUser = thread.coro(AuthManager.checkUserAsync)

function AuthManager:checkSessionAsync()
	print("check session")

	local server_remote = self.sea_client.remote
	local config = self.config

	local ok = server_remote.auth:loginSession(config.session)
	if not ok then
		print("invalid session")
		return
	end

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
	-- print("quick login")
	-- local config = self.config
	-- local key = config.quick_login_key

	-- if key and #key ~= 0 then
	-- 	self:quickGetToken()
	-- else
	-- 	self:quickGetKey()
	-- end
end

---@param email string
---@param password string
function AuthManager:loginAsync(email, password)
	print("login")

	local sea_client = self.sea_client
	local server_remote = sea_client.remote
	local config = self.config

	local ret, err = server_remote.auth:login(email, password)
	if not ret then
		print(err)
		return
	end

	config.session = ret.session
	config.user = ret.user
	config.token = ret.token

	self:checkSessionAsync()
end
AuthManager.login = thread.coro(AuthManager.loginAsync)

function AuthManager:logoutAsync()
	print("logout")

	local sea_client = self.sea_client
	local server_remote = sea_client.remote
	local config = self.config

	server_remote.auth:logout()

	config.session = {}
	config.user = {}
	config.token = ""

	sea_client.client:setUser()
end
AuthManager.logout = thread.coro(AuthManager.logoutAsync)

return AuthManager
