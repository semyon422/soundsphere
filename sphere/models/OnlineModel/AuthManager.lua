local Class = require("aqua.util.Class")
local ThreadPool = require("aqua.thread.ThreadPool")
local inspect = require("inspect")

local AuthManager = Class:new()

AuthManager.createToken = function(self)
	print("create token")
	local config = self.config
	return ThreadPool:execute({
		f = function(params)
			local json = require("json")
			local request = require("luajit-request")

			local response = request.send(params.host .. "/auth/token", {
				method = "POST",
				data = {
					email = params.email,
					password = params.password
				}
			})

			return json.decode(response.body)
		end,
		params = {
			host = config.host,
			email = config.email,
			password = config.password
		},
		result = function(response)
			print(inspect(response))
			if response.status then
				config.token = response.token
				self:checkSession()
				config.email = ""
				config.password = ""
			end
		end,
	})
end

AuthManager.createSession = function(self)
	print("create session")
	local config = self.config
	return ThreadPool:execute({
		f = function(params)
			local json = require("json")
			local request = require("luajit-request")

			local response = request.send(params.host .. "/auth/session", {
				method = "POST",
				data = {
					token = params.token
				}
			})

			return json.decode(response.body)
		end,
		params = {
			host = config.host,
			token = config.token
		},
		result = function(response)
			print(inspect(response))
			config.session = response.session
		end,
		error = function(message)
			print("Session was not created")
			print(message)
		end,
	})
end

AuthManager.checkSession = function(self)
	print("check session")
	local config = self.config
	return ThreadPool:execute({
		f = function(params)
			local json = require("json")
			local request = require("luajit-request")

			local response = request.send(params.host .. "/auth/session/check", {
				method = "POST",
				data = {
					session = params.session
				}
			})

			return json.decode(response.body)
		end,
		params = {
			host = config.host,
			session = config.session,
		},
		result = function(response)
			print(inspect(response))
			if response.status then
				self:updateSession()
			else
				self:createSession()
			end
		end,
		error = function(message)
			print("error")
			print(message)
		end,
	})
end

AuthManager.updateSession = function(self)
	print("update session")
	local config = self.config
	return ThreadPool:execute({
		f = function(params)
			local json = require("json")
			local http = require("aqua.http")
			local request = require("luajit-request")

			local response = request.send(params.host .. "/auth/session/update", {
				method = "POST",
				data = {
					session = params.session
				}
			})

			return json.decode(response.body)
		end,
		params = {
			host = config.host,
			session = config.session,
		},
		result = function(response)
			print(inspect(response))
		end,
	})
end

AuthManager.quickLogin = function(self)
	print("quick login")
	local config = self.config
	local token = config.token
	if #token ~= 0 then
		return
	end
	return ThreadPool:execute({
		f = function(params)
			local json = require("json")
			local request = require("luajit-request")

			if params.key and #params.key ~= 0 then
				local response = request.send(params.host .. "/auth/quick", {
					method = "POST",
					data = {
						key = params.key
					}
				})

				return json.decode(response.body)
			else
				local response = request.send(params.host .. "/auth/quick", {
					method = "GET"
				})

				return json.decode(response.body)
			end
		end,
		params = {
			host = config.host,
			key = config.quick_login_key
		},
		result = function(response)
			print(inspect(response))
			if response.key then
				config.quick_login_key = response.key
				local url = config.host .. "/quick_login?key=" .. response.key
				print(url)
				love.system.openURL(url)
			elseif response.token then
				config.quick_login_key = ""
				config.token = response.token
				self:checkSession()
			end
		end
	})
end

return AuthManager
