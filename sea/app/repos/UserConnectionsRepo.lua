local class = require("class")

---@class sea.UserConnectionsRepo
---@operator call: sea.UserConnectionsRepo
local UserConnectionsRepo = class()

---@param dict web.ISharedDict
function UserConnectionsRepo:new(dict)
	self.dict = dict
	self.global_key = "players_online"
end

function UserConnectionsRepo:increment()
	self.dict:incr(self.global_key, 1, 0)
end

function UserConnectionsRepo:decrement()
	self.dict:incr(self.global_key, -1, 0)
end

function UserConnectionsRepo:getGlobalCount()
	return tonumber(self.dict:get(self.global_key)) or 0
end

---@private
function UserConnectionsRepo:_getUserKey(user_id)
	return "u:" .. tostring(user_id) .. ":c"
end

---@param user_id integer
function UserConnectionsRepo:incrementUser(user_id)
	self.dict:incr(self:_getUserKey(user_id), 1, 0)
end

---@param user_id integer
function UserConnectionsRepo:decrementUser(user_id)
	self.dict:incr(self:_getUserKey(user_id), -1, 0)
end

---@param user_id integer
---@return boolean
function UserConnectionsRepo:isUserOnline(user_id)
	local count = tonumber(self.dict:get(self:_getUserKey(user_id))) or 0
	return count > 0
end

return UserConnectionsRepo
