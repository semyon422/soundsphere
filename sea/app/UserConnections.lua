local class = require("class")

---@class sea.UserConnections
---@operator call: sea.UserConnections
local UserConnections = class()

---@param repo sea.UserConnectionsRepo
function UserConnections:new(repo)
	self.repo = repo
end

---@param user_id? integer
function UserConnections:onConnect(user_id)
	self.repo:increment()
	if user_id then
		self.repo:incrementUser(user_id)
	end
end

---@param user_id? integer
function UserConnections:onDisconnect(user_id)
	self.repo:decrement()
	if user_id then
		self.repo:decrementUser(user_id)
	end
end

---@param user_id integer
function UserConnections:onUserConnect(user_id)
	self.repo:incrementUser(user_id)
end

---@param user_id integer
function UserConnections:onUserDisconnect(user_id)
	self.repo:decrementUser(user_id)
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
