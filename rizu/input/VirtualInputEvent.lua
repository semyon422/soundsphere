local class = require("class")

---@alias rizu.VirtualInputEventId integer
---@alias rizu.VirtualInputEventValue false|true|"left"|"right"

---@class rizu.VirtualInputEvent
---@operator call: rizu.VirtualInputEvent
local VirtualInputEvent = class()

---@param id rizu.VirtualInputEventId
---@param value rizu.VirtualInputEventValue?
---@param column integer
---@param pos [number, number]
function VirtualInputEvent:new(id, value, column, pos)
	self.id = id
	self.value = value
	self.column = column
	self.pos = pos
end

return VirtualInputEvent
