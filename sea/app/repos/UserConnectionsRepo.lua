local class = require("class")

---@class sea.UserConnectionsRepo
---@operator call: sea.UserConnectionsRepo
local UserConnectionsRepo = class()

---@param dict web.ISharedDict
function UserConnectionsRepo:new(dict)
	self.dict = dict
	self.key = "players_online"
end

function UserConnectionsRepo:increment()
	self.dict:incr(self.key, 1, 0)
end

function UserConnectionsRepo:decrement()
	self.dict:incr(self.key, -1, 0)
end

function UserConnectionsRepo:get()
	return tonumber(self.dict:get(self.key)) or 0
end

return UserConnectionsRepo
