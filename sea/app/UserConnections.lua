local class = require("class")

---@class sea.UserConnections
---@operator call: sea.UserConnections
local UserConnections = class()

---@param repo sea.UserConnectionsRepo
function UserConnections:new(repo)
	self.repo = repo
end

function UserConnections:onConnect()
	self.repo:increment()
end

function UserConnections:onDisconnect()
	self.repo:decrement()
end

function UserConnections:getOnlineCount()
	return self.repo:get()
end

return UserConnections
