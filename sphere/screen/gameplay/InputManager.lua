local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local json			= require("json")

local InputManager = Class:new()

InputManager.path = "userdata/input.json"

InputManager.mode = "external"

InputManager.types = {
	"keyboard",
	"gamepad",
	"joystick"
}

InputManager.init = function(self)
	self.observable = Observable:new()
end

InputManager.setMode = function(self, mode)
	self.mode = mode
end

InputManager.send = function(self, event)
	return self.observable:send(event)
end

InputManager.read = function(self)
	self.data = {}
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		self.data = json.decode(file:read("*all"))
		file:close()
	end
end

InputManager.write = function(self)
	local file = io.open(self.path, "w")
	file:write(json.encode(self.data))
	return file:close()
end

InputManager.setKey = function(self, inputMode, virtualKey, key, type)
	local data = self.data

	data[inputMode] = data[inputMode] or {}
	local inputConfig = data[inputMode]

	inputConfig.press = inputConfig.press or {}
	local press = inputConfig.press
	press[type] = press[type] or {}

	inputConfig.release = inputConfig.release or {}
	local release = inputConfig.release
	release[type] = release[type] or {}

	for type, keys in pairs(press) do
		for key, data in pairs(keys) do
			if data.press and data.press[1] == virtualKey then
				press[type][key] = nil
			end
		end
	end
	for type, keys in pairs(release) do
		for key, data in pairs(keys) do
			if data.release and data.release[1] == virtualKey then
				release[type][key] = nil
			end
		end
	end

	press[type][key] = {
		press = {virtualKey},
		release = {}
	}
	release[type][key] = {
		press = {},
		release = {virtualKey}
	}
end

InputManager.getKey = function(self, inputMode, virtualKey)
	local data = self.data

	local inputConfig = data[inputMode]
	if not inputConfig or not inputConfig.press then
		return "none"
	end

	for type, keys in pairs(inputConfig.press) do
		for key, data in pairs(keys) do
			if data.press and data.press[1] == virtualKey then
				return key
			end
		end
	end

	return "none"
end

InputManager.setInputMode = function(self, inputMode)
	self.inputMode = inputMode
	self.inputConfig = self.data[inputMode]
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
	if event.name == "keypressed" then
		keyConfig = self.inputConfig.press.keyboard[event.args[1]]
	elseif event.name == "keyreleased" then
		keyConfig = self.inputConfig.release.keyboard[event.args[1]]
	elseif event.name == "gamepadpressed" then
		keyConfig = self.inputConfig.press.gamepad[tostring(event.args[2])]
	elseif event.name == "gamepadreleased" then
		keyConfig = self.inputConfig.release.gamepad[tostring(event.args[2])]
	elseif event.name == "joystickpressed" then
		keyConfig = self.inputConfig.press.joystick[tostring(event.args[2])]
	elseif event.name == "joystickreleased" then
		keyConfig = self.inputConfig.release.joystick[tostring(event.args[2])]
	end
	if not keyConfig then
		return
	end

	local events = {}
	for _, key in ipairs(keyConfig.press) do
		events[#events + 1] = {
			name = "keypressed",
			args = {key},
			virtual = true,
			time = self.currentTime
		}
	end
	for _, key in ipairs(keyConfig.release) do
		events[#events + 1] = {
			name = "keyreleased",
			args = {key},
			virtual = true,
			time = self.currentTime
		}
	end
	for _, event in ipairs(events) do
		self:send(event)
	end
end

return InputManager
