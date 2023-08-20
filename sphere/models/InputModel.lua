local class = require("class")

---@class sphere.InputModel
---@operator call: sphere.InputModel
local InputModel = class()

InputModel.inputMode = ""
InputModel.inputs = {}
InputModel.devices = {
	"keyboard",
	"gamepad",
	"joystick",
	"midi"
}

---@param inputMode string
---@param event table
---@return string?
---@return boolean?
function InputModel:transformEvent(inputMode, event)
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

---@param inputMode string
---@param virtualKey string
---@param device string
---@param key string
---@param index number
function InputModel:setKey(inputMode, virtualKey, device, key, index)
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

---@param inputMode string
---@param virtualKey string
---@param device string
---@param index number
---@return string|number
function InputModel:getKey(inputMode, virtualKey, device, index)
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

---@param inputMode string
---@return table
function InputModel:getInputs(inputMode)
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
