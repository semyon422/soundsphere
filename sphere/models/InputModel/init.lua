local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local json			= require("json")

local InputModel = Class:new()

InputModel.path = "userdata/input.json"

InputModel.mode = "external"

InputModel.types = {
	"keyboard",
	"gamepad",
	"joystick",
	"midi"
}

InputModel.load = function(self)
	self.inputBindings = self.configModel:getConfig("input")
end

InputModel.unload = function(self) end

InputModel.getInputBindings = function(self)
	return self.inputBindings
end

InputModel.setKey = function(self, inputMode, virtualKey, key, type)
	local inputBindings = self.inputBindings

	inputBindings[inputMode] = inputBindings[inputMode] or {}
	local inputConfig = inputBindings[inputMode]

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

InputModel.getKey = function(self, inputMode, virtualKey)
	local inputBindings = self.inputBindings

	local inputConfig = inputBindings[inputMode]
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

InputModel.getInputs = function(self, inputModeString)
	local inputs = {}

	for inputCount, inputType in inputModeString:gmatch("([0-9]+)([a-z]+)") do
		for i = 1, inputCount do
			inputs[#inputs + 1] = {
				virtualKey = inputType .. i
			}
		end
	end

	return inputs
end

return InputModel
