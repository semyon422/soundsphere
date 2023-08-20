local class = require("class")
local socket_url = require("socket.url")
local thread = require("thread")

---@class sphere.OnlineNotechartManager
---@operator call: sphere.OnlineNotechartManager
local OnlineNotechartManager = class()

OnlineNotechartManager.openWebNotechart = thread.coro(function(self, hash, index)
	local api = self.webApi.api
	local urls = self.urls

	print("GET " .. api.notecharts)
	local notecharts = api.notecharts:get({
		hash = hash,
		index = index,
	})
	local id = notecharts and notecharts[1] and notecharts[1].id

	if id then
		love.system.openURL(socket_url.absolute(urls.host, "/notecharts/" .. id))
	end
end)

return OnlineNotechartManager
