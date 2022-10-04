local Class = require("Class")

local InputModel = Class:new()

InputModel.inputMode = ""
InputModel.devices = {
	"keyboard",
	"gamepad",
	"joystick",
	"midi"
}

InputModel.transformEvent = function(self, inputMode, event)
	if not event.name:find("^.+pressed$") and not event.name:find("^.+released$") then
		return
	end

	local device = event.name:match("^(.+)pressed$") or event.name:match("^(.+)released$")
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

	local config = self.game.configModel.configs.input
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
		elseif k == key then
			_i = i
			break
		end
	end

	local inputs = self:getInputs(inputMode)
	return inputs[_i], state
end

InputModel.setKey = function(self, inputMode, virtualKey, device, key)
	local inputs = self:getInputs(inputMode)

	if device == "midi" then
		key = tonumber(key)
	end

	local config = self.game.configModel.configs.input

	config[inputMode] = config[inputMode] or {}
	local inputConfig = config[inputMode]

	inputConfig[device] = inputConfig[device] or {}
	local deviceConfig = inputConfig[device]

	deviceConfig[inputs[virtualKey]] = key
end

InputModel.getKey = function(self, inputMode, virtualKey, device)
	local inputs = self:getInputs(inputMode)

	local config = self.game.configModel.configs.input
	local inputConfig = config[inputMode]
	local deviceConfig = inputConfig and inputConfig[device]
	local key = deviceConfig and deviceConfig[inputs[virtualKey]]

	if type(key) == "table" then
		key = table.concat(key, ", ")
	end

	return key or "none"
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
