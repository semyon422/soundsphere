local class = require("class")

---@class sea.UserConnectionsRepo
---@operator call: sea.UserConnectionsRepo
local UserConnectionsRepo = class()

---@param dict web.ISharedDict
function UserConnectionsRepo:new(dict)
	self.dict = dict
end

---@private
function UserConnectionsRepo:_getConnKey(ip, port)
	return "c:" .. tostring(ip) .. ":" .. tonumber(port)
end

---@private
function UserConnectionsRepo:_getUserKey(user_id)
	return "u:" .. tostring(user_id)
end

---@param ip string
---@param port integer
---@param ttl integer
function UserConnectionsRepo:setConnection(ip, port, ttl)
	self.dict:set(self:_getConnKey(ip, port), true, ttl)
end

---@param ip string
---@param port integer
function UserConnectionsRepo:removeConnection(ip, port)
	self.dict:delete(self:_getConnKey(ip, port))
end

---@param user_id integer
---@param ttl integer
function UserConnectionsRepo:setUserOnline(user_id, ttl)
	self.dict:set(self:_getUserKey(user_id), true, ttl)
end

---@param user_id integer
function UserConnectionsRepo:setUserOffline(user_id)
	self.dict:delete(self:_getUserKey(user_id))
end

---@return integer
function UserConnectionsRepo:getGlobalCount()
	local keys = self.dict:get_keys(0)
	local count = 0
	for _, key in ipairs(keys) do
		if key:sub(1, 2) == "c:" then
			count = count + 1
		end
	end
	return count
end

---@param user_id integer
---@return boolean
function UserConnectionsRepo:isUserOnline(user_id)
	return self.dict:get(self:_getUserKey(user_id)) ~= nil
end

return UserConnectionsRepo
