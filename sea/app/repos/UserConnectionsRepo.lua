local class = require("class")
local SharedMemoryQueue = require("icc.SharedMemoryQueue")

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
function UserConnectionsRepo:_getQueueKey(ip, port)
	return "q:" .. tostring(ip) .. ":" .. tonumber(port)
end

---@private
function UserConnectionsRepo:_getUserKey(user_id)
	return "u:" .. tostring(user_id)
end

---@param ip string
---@param port integer
---@param user_id? integer
---@param ttl integer
function UserConnectionsRepo:setConnection(ip, port, user_id, ttl)
	self.dict:set(self:_getConnKey(ip, port), user_id or true, ttl)
end

---@param ip string
---@param port integer
---@return boolean
function UserConnectionsRepo:hasConnection(ip, port)
	return self.dict:get(self:_getConnKey(ip, port)) ~= nil
end

---@param ip string
---@param port integer
---@return integer|true|nil
function UserConnectionsRepo:getConnectionUser(ip, port)
	return self.dict:get(self:_getConnKey(ip, port))
end

---@param ip string
---@param port integer
function UserConnectionsRepo:removeConnection(ip, port)
	self.dict:delete(self:_getConnKey(ip, port))
	self.dict:delete(self:_getQueueKey(ip, port))
end

---@param ip string
---@param port integer
---@return icc.SharedMemoryQueue
function UserConnectionsRepo:getQueue(ip, port)
	return SharedMemoryQueue(self.dict, self:_getQueueKey(ip, port))
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

---@param callback fun(ip: string, port: integer, user_id: integer|true)
function UserConnectionsRepo:forEachConnection(callback)
	local keys = self.dict:get_keys(0)
	for _, key in ipairs(keys) do
		if key:sub(1, 2) == "c:" then
			local user_id = self.dict:get(key)
			if user_id ~= nil then
				---@cast user_id -string
				local ip, port = key:match("^c:(.+):(%d+)$")
				if ip and port then
					callback(ip, assert(tonumber(port)), user_id)
				end
			end
		end
	end
end

---@return integer
function UserConnectionsRepo:getGlobalCount()
	local count = 0
	self:forEachConnection(function()
		count = count + 1
	end)
	return count
end

---@param user_id integer
---@return boolean
function UserConnectionsRepo:isUserOnline(user_id)
	return self.dict:get(self:_getUserKey(user_id)) ~= nil
end

return UserConnectionsRepo
