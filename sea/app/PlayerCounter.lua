local class = require("class")

---@class sea.PlayerCounter
---@operator call: sea.PlayerCounter
local PlayerCounter = class()

---@param dict web.ISharedDict
function PlayerCounter:new(dict)
	self.dict = dict
	self.key = "players_online"
end

function PlayerCounter:increment()
	self.dict:incr(self.key, 1, 0)
end

function PlayerCounter:decrement()
	self.dict:incr(self.key, -1, 0)
end

function PlayerCounter:get()
	return tonumber(self.dict:get(self.key)) or 0
end

return PlayerCounter
