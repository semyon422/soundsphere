local class = require("class")

---@class sea.UserConnections
---@operator call: sea.UserConnections
local UserConnections = class()

UserConnections.ttl = 90

---@param repo sea.UserConnectionsRepo
function UserConnections:new(repo)
	self.repo = repo
end

---@param ip string
---@param port integer
---@param user_id? integer
function UserConnections:onConnect(ip, port, user_id)
	self:heartbeat(ip, port, user_id)
end

---@param ip string
---@param port integer
---@param user_id? integer
function UserConnections:onDisconnect(ip, port, user_id)
	self.repo:removeConnection(ip, port)
	if user_id then
		self.repo:setUserOffline(user_id)
	end
end

---@param user_id integer
function UserConnections:onUserConnect(user_id)
	self.repo:setUserOnline(user_id, self.ttl)
end

---@param user_id integer
function UserConnections:onUserDisconnect(user_id)
	self.repo:setUserOffline(user_id)
end

---@param ip string
---@param port integer
---@param user_id? integer
function UserConnections:heartbeat(ip, port, user_id)
	self.repo:setConnection(ip, port, self.ttl)
	if user_id then
		self.repo:setUserOnline(user_id, self.ttl)
	end
end

function UserConnections:getOnlineCount()
	return self.repo:getGlobalCount()
end

---@param user_id integer
---@return boolean
function UserConnections:isUserOnline(user_id)
	return self.repo:isUserOnline(user_id)
end

return UserConnections
