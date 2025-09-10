local class = require("class")

---@class rizu.VirtualInputEvent
---@operator call: rizu.VirtualInputEvent
---@field pos any
---@field value any
---@field type "absolute"|"relative"
---@field id any
local VirtualInputEvent = class()

return VirtualInputEvent
