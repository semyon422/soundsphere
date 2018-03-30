ncdk.InputMode = {}
local InputMode = ncdk.InputMode

ncdk.InputMode_metatable = {}
local InputMode_metatable = ncdk.InputMode_metatable
InputMode_metatable.__index = InputMode

InputMode.new = function(self)
	local inputMode = {}
	
	inputMode.inputData = {}
	
	setmetatable(inputMode, InputMode_metatable)
	
	return inputMode
end

InputMode.setInput = function(self, inputType, inputIndex, binding)
	self.inputData[inputType] = self.inputData[inputType] or {}
	self.inputData[inputType][inputIndex] = binding
end

InputMode.getInput = function(self, inputType, inputIndex)
	return self.inputData[inputType] and self.inputData[inputType][inputIndex]
end

InputMode_metatable.__le = function(a, b)
	for inputType, inputTypeData in pairs(a.inputData) do
		if inputType ~= "auto" then
			for inputIndex in pairs(inputTypeData) do
				if not (b.inputData[inputType] and b.inputData[inputType][inputIndex]) then
					return
				end
			end
		end
	end
	
	return true
end