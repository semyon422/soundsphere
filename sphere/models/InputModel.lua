local Class = require("Class")

local InputModel = Class:new()

InputModel.inputMode = ""
InputModel.inputs = {}
InputModel.devices = {
	"keyboard",
	"gamepad",
	"joystick",
	"midi"
}

InputModel.transformEvent = function(self, inputMode, event)
	local device = event.name:match("^(.+)pressed$") or event.name:match("^(.+)released$")
	if not device then
		return
	end

	if device == "key" then
		device = "keyboard"
	end

	local state = true
	if event.name:find("^.+released$") then
		state = false
	end

	local key = event[2]
	if device == "midi" then
		key = event[1]
	end

	local config = self.configModel.configs.input
	local inputConfig = config[inputMode]
	local deviceConfig = inputConfig and inputConfig[device]

	if not deviceConfig then
		return
	end

	local _i
	for i, k in pairs(deviceConfig) do
		if type(k) == "table" then
			for _, _k in pairs(k) do
				if _k == key then
					_i = i
					break
				end
			end
		end
	end

	local inputs = self:getInputs(inputMode)
	return inputs[_i], state
end

InputModel.setKey = function(self, inputMode, virtualKey, device, key, index)
	local inputs = self:getInputs(inputMode)
	local n = inputs[virtualKey]

	if device == "midi" then
		key = tonumber(key)
	end

	local config = self.configModel.configs.input

	config[inputMode] = config[inputMode] or {}
	local inputConfig = config[inputMode]

	inputConfig[device] = inputConfig[device] or {}
	local deviceConfig = inputConfig[device]

	if type(deviceConfig[n]) ~= "table" then
		deviceConfig[n] = {}
	end

	deviceConfig[n][index] = key
end

InputModel.getKey = function(self, inputMode, virtualKey, device, index)
	local inputs = self:getInputs(inputMode)
	local n = inputs[virtualKey]

	local config = self.configModel.configs.input
	local inputConfig = config[inputMode]
	if not inputConfig then
		return "none"
	end

	local deviceConfig = inputConfig[device]
	if not deviceConfig then
		return "none"
	end

	local keys = deviceConfig[n]

	if type(keys) ~= "table" then
		return "none"
	end

	return keys[index] or "none"
end

InputModel.getInputs = function(self, inputMode)
	if inputMode == self.inputMode then
		return self.inputs
	end
	self.inputMode = inputMode

	local inputs = {}
	self.inputs = inputs

	local j = 1
	for inputCount, inputType in inputMode:gmatch("([0-9]+)([a-z]+)") do
		for i = 1, inputCount do
			local input = inputType .. i
			inputs[j] = input
			inputs[input] = j
			j = j + 1
		end
	end

	return inputs
end

return InputModel
