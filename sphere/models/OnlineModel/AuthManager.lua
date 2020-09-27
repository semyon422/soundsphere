local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")
local ThreadPool	= require("aqua.thread.ThreadPool")

local AuthManager = Class:new()

AuthManager.construct = function(self)
	self.observable = Observable:new()
end

AuthManager.load = function(self)
	ThreadPool.observable:add(self)
end

AuthManager.unload = function(self)
	ThreadPool.observable:remove(self)
end

AuthManager.receive = function(self, event)
	if event.name == "TokenResponse" then
		self.onlineModel:receive(event)
	elseif event.name == "SessionResponse" then
		self.onlineModel:receive(event)
	elseif event.name == "SessionCheckResponse" then
		self.onlineModel:receive(event)
	elseif event.name == "SessionUpdateResponse" then
		self.onlineModel:receive(event)
	elseif event.name == "QuickLoginGetResponse" then
		self.onlineModel:receive(event)
	elseif event.name == "QuickLoginPostResponse" then
		self.onlineModel:receive(event)
	end
end

AuthManager.createToken = function(self, email, password)
	return ThreadPool:execute(
		[[
			local http = require("aqua.http")
			local request = require("luajit-request")

			local data = ({...})[1]
			for k, v in pairs(data) do
				data[k] = tostring(v)
			end

			local response = request.send(data.host .. "/auth/token", {
				method = "POST",
				data = {
					email = data.email,
					password = data.password
				}
			})

			thread:push({
				name = "TokenResponse",
				status = response.code == 200,
				body = response.body
			})
		]],
		{
			{
				host = self.host,
				email = email,
				password = password
			}
		}
	)
end

AuthManager.createSession = function(self, token)
	return ThreadPool:execute(
		[[
			local http = require("aqua.http")
			local request = require("luajit-request")

			local data = ({...})[1]
			for k, v in pairs(data) do
				data[k] = tostring(v)
			end

			local response = request.send(data.host .. "/auth/session", {
				method = "POST",
				data = {
					token = data.token
				}
			})

			thread:push({
				name = "SessionResponse",
				status = response.code == 200,
				body = response.body
			})
		]],
		{
			{
				host = self.host,
				token = token
			}
		}
	)
end

AuthManager.checkSession = function(self)
	return ThreadPool:execute(
		[[
			local http = require("aqua.http")
			local request = require("luajit-request")

			local data = ({...})[1]
			for k, v in pairs(data) do
				data[k] = tostring(v)
			end

			local response = request.send(data.host .. "/auth/session/check", {
				method = "POST",
				data = {
					session = data.session
				}
			})

			thread:push({
				name = "SessionCheckResponse",
				status = response.code == 200,
				body = response.body
			})
		]],
		{
			{
				host = self.host,
				session = self.session,
			}
		}
	)
end

AuthManager.updateSession = function(self)
	return ThreadPool:execute(
		[[
			local http = require("aqua.http")
			local request = require("luajit-request")

			local data = ({...})[1]
			for k, v in pairs(data) do
				data[k] = tostring(v)
			end

			local response = request.send(data.host .. "/auth/session/update", {
				method = "POST",
				data = {
					session = data.session
				}
			})

			thread:push({
				name = "SessionUpdateResponse",
				status = response.code == 200,
				body = response.body
			})
		]],
		{
			{
				host = self.host,
				session = self.session,
			}
		}
	)
end

AuthManager.quickLogin = function(self, key)
	return ThreadPool:execute(
		[[
			local http = require("aqua.http")
			local request = require("luajit-request")

			local data = ({...})[1]
			for k, v in pairs(data) do
				data[k] = tostring(v)
			end

			if data.key and #data.key ~= 0 then
				local response = request.send(data.host .. "/auth/quick", {
					method = "POST",
					data = {
						key = data.key
					}
				})

				thread:push({
					name = "QuickLoginPostResponse",
					status = response.code == 200,
					body = response.body
				})
			else
				local response = request.send(data.host .. "/auth/quick", {
					method = "GET"
				})

				thread:push({
					name = "QuickLoginGetResponse",
					status = response.code == 200,
					body = response.body
				})
			end
		]],
		{
			{
				host = self.host,
				key = key
			}
		}
	)
end

return AuthManager
