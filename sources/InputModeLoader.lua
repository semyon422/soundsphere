InputModeLoader = createClass()

InputModeLoader.load = function(self, filePath)
	self.inputModes = {}
	
	local file = io.open(filePath, "r")
	
	for _, inputModeData in ipairs(json.decode(file:read("*all"))) do
		local inputMode = ncdk.InputMode:new()
		for inputType, inputData in pairs(inputModeData) do
			for inputIndex, binding in ipairs(inputData) do
				inputMode:setInput(inputType, inputIndex, binding)
			end
		end
		table.insert(self.inputModes, inputMode)
	end
	
	file:close()
end

InputModeLoader.getInputMode = function(self, inputMode)
	for _, currentInputMode in ipairs(self.inputModes) do
		if inputMode <= currentInputMode then
			return currentInputMode
		end
	end
end