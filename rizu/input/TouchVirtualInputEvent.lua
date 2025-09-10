local VirtualInputEvent = require("rizu.input.VirtualInputEvent")

---@class rizu.TouchVirtualInputEvent: rizu.VirtualInputEvent
---@operator call: rizu.TouchVirtualInputEvent
local TouchVirtualInputEvent = VirtualInputEvent + {}

TouchVirtualInputEvent.type = "absolute"

---@param pos {x: number, y: number}
---@param value boolean
---@param id integer
function TouchVirtualInputEvent:new(pos, value, id)
	self.pos = pos
	self.value = value
	self.id = id
end

return TouchVirtualInputEvent
