local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local json			= require("json")

local InputManager = Class:new()

InputManager.path = "userdata/input.json"

InputManager.mode = "external"
InputManager.needRound = true
InputManager.scaleInputOffset = false
InputManager.offset = 0

InputManager.types = {
	"keyboard",
	"gamepad",
	"joystick",
	"midi"
}

InputManager.construct = function(self)
	self.observable = Observable:new()
end

InputManager.setMode = function(self, mode)
	self.mode = mode
end

InputManager.setInputOffset = function(self, offset)
	self.offset = offset
end

InputManager.setScaleInputOffset = function(self, scaleInputOffset)
	self.scaleInputOffset = scaleInputOffset
end

InputManager.setBindings = function(self, inputBindings)
	self.inputBindings = inputBindings
end

InputManager.send = function(self, event)
	return self.observable:send(event)
end

InputManager.setInputMode = function(self, inputMode)
	self.inputMode = inputMode
	self.inputConfig = self.inputBindings[inputMode]
end

InputManager.receive = function(self, event)
	if event.name == "TimeState" then
		self.currentTime = event.exactCurrentTime
		return
	end

	local mode = self.mode

	if event.virtual and mode == "internal" then
		return self:send(event)
	end

	if mode ~= "external" then
		return
	end

	if not self.inputConfig then
		return
	end

	local keyConfig
	if event.name == "keypressed" and self.inputConfig.press.keyboard then
		keyConfig = self.inputConfig.press.keyboard[event.args[2]]
	elseif event.name == "keyreleased" and self.inputConfig.release.keyboard then
		keyConfig = self.inputConfig.release.keyboard[event.args[2]]
	elseif event.name == "gamepadpressed" then
		keyConfig = self.inputConfig.press.gamepad[tostring(event.args[2])]
	elseif event.name == "gamepadreleased" then
		keyConfig = self.inputConfig.release.gamepad[tostring(event.args[2])]
	elseif event.name == "joystickpressed" and self.inputConfig.press.joystick then
		keyConfig = self.inputConfig.press.joystick[tostring(event.args[2])]
	elseif event.name == "joystickreleased" and self.inputConfig.release.joystick then
		keyConfig = self.inputConfig.release.joystick[tostring(event.args[2])]
	elseif event.name == "midipressed" then
		keyConfig = self.inputConfig.press.midi[tostring(event.args[1])]
	elseif event.name == "midireleased" then
		keyConfig = self.inputConfig.release.midi[tostring(event.args[1])]
	end
	if not keyConfig then
		return
	end

	local eventTime = self.currentTime
	if self.needRound then
		eventTime =  math.floor(self.currentTime * 1024) / 1024
	end

	local offset = self.offset
	if self.scaleInputOffset then
		offset = offset * self.timeEngine.timeRate
	end

	local events = {}
	for _, key in ipairs(keyConfig.press) do
		events[#events + 1] = {
			name = "keypressed",
			args = {key},
			virtual = true,
			time = eventTime + offset
		}
	end
	for _, key in ipairs(keyConfig.release) do
		events[#events + 1] = {
			name = "keyreleased",
			args = {key},
			virtual = true,
			time = eventTime + offset
		}
	end
	for _, event in ipairs(events) do
		self:send(event)
	end
end

return InputManager
