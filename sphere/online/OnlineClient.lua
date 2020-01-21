local enet = require("enet")
local json = require("json")
local http = require("aqua.http")
local Observable = require("aqua.util.Observable")

local OnlineClient = {}

OnlineClient.path = "userdata/online.json"

OnlineClient.init = function(self)
	self.observable = Observable:new()
end

OnlineClient.load = function(self)
	local file = io.open(self.path, "r")
	self.data = json.decode(file:read("*all"))
	file:close()

	-- self.host = enet.host_create()
	-- self.server = self.host:connect(self.data.host)
end

OnlineClient.unload = function(self)
	-- self.server:disconnect()
	-- self.host:flush()
end

OnlineClient.update = function(self)
	-- local host = self.host
	-- local event = host:service()
	-- while event do
	-- 	self:internalReceive(event)
	-- 	event = host:service()
	-- end
end

OnlineClient.internalReceive = function(self, event)
	print(event.type)
end

OnlineClient.receive = function(self, event)

end

OnlineClient.send = function(self, event)
	return self.observable:send(event)
end

OnlineClient.getUserId = function(self)
	return self.data.userId
end

OnlineClient.getSessionId = function(self)
	return self.data.sessionId
end

-- OnlineClient.login = function(self)
-- 	http.post()
-- end

return OnlineClient
