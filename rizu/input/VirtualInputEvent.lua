local class = require("class")

---@alias rizu.VirtualInputEventId integer

---@class rizu.VirtualInputEvent
---@operator call: rizu.VirtualInputEvent
---@field pos any
---@field value any?
---@field id rizu.VirtualInputEventId
local VirtualInputEvent = class()

---@param pos any
---@param value any?
---@param id rizu.VirtualInputEventId
function VirtualInputEvent:new(pos, value, id)
	self.pos = pos
	self.value = value
	self.id = id
end

return VirtualInputEvent
