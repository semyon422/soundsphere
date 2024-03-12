local class = require("class")

---@class sphere.InputModel
---@operator call: sphere.InputModel
local InputModel = class()

InputModel.inputMode = ""
InputModel.inputs = {}

---@param configModel sphere.ConfigModel
function InputModel:new(configModel)
	self.configModel = configModel
end

---@param inputMode string
---@param event table
---@return string?
---@return boolean?
function InputModel:transformEvent(inputMode, event)
	if event.name ~= "inputchanged" then
		return
	end

	local device, id, key, state = event[1], event[2], event[3], event[4]

	local config = self.configModel.configs.input
	local inputConfig = config[inputMode]

	if not inputConfig then
		return
	end

	local _i
	for i, binds in pairs(inputConfig) do
		if type(binds) == "table" then
			for _, bind in pairs(binds) do
				local _key, _device, _id = unpack(bind, 1, 3)
				if _key == key and _device == device and _id == id then
					_i = i
					break
				end
			end
		end
	end

	if not _i then
		return
	end

	local inputs = self:getInputs(inputMode)
	return inputs[_i], state
end

---@param inputMode string
---@param virtualKey string
---@param index number
---@param device string
---@param device_id string
---@param key string
function InputModel:setKey(inputMode, virtualKey, index, device, device_id, key)
	local inputs = self:getInputs(inputMode)
	local n = inputs[virtualKey]

	local config = self.configModel.configs.input

	config[inputMode] = config[inputMode] or {}
	local inputConfig = config[inputMode]

	inputConfig[n] = inputConfig[n] or {}
	local binds = inputConfig[n]

	if not key then
		binds[index] = nil
		return
	end

	binds[index] = {key, device, device_id}
end

---@param inputMode string
---@param virtualKey string
---@param index number
---@return string|number?
function InputModel:getKey(inputMode, virtualKey, index)
	local inputs = self:getInputs(inputMode)
	local n = inputs[virtualKey]

	local config = self.configModel.configs.input
	local inputConfig = config[inputMode]
	if not inputConfig then
		return
	end

	local bind = inputConfig[n] and inputConfig[n][index]
	if not bind then
		return
	end

	return unpack(bind, 1, 3)
end

---@param inputMode string
---@return number
function InputModel:getBindsCount(inputMode)
	local max_index = 0

	local config = self.configModel.configs.input
	local inputConfig = config[inputMode]
	if not inputConfig then
		return max_index
	end

	for _, binds in pairs(inputConfig) do
		for i in ipairs(binds) do
			max_index = math.max(max_index, i)
		end
	end

	return max_index
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
