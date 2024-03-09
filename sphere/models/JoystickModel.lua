local class = require("class")

---@class sphere.JoystickModel
---@operator call: sphere.JoystickModel
local JoystickModel = class()

function JoystickModel:new()
	self.data = {}
end

function JoystickModel:receive(event)
	if event.name ~= "joystickaxis" then
		return
	end
	local joystick, axis, value = unpack(event)
	local guid = joystick:getGUID()

	local data = self.data
	data[guid] = data[guid] or {}
	data[guid][axis] = value
end

return JoystickModel
