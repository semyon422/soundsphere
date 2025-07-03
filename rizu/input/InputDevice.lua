local class = require("class")

---@alias rizu.InputDeviceType "keyboard"|"gamepad"|"joystick"|"midi"

---@class rizu.InputDevice
---@operator call: rizu.InputDevice
---@field type rizu.InputDeviceType
---@field id integer
local InputDevice = class()

---@param type rizu.InputDeviceType
---@param id integer
function InputDevice:new(type, id)
	self.type = type
	self.id = id
end

return InputDevice
