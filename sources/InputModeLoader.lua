InputModeLoader = createClass()

InputModeLoader.load = function(self, filePath)
	self.inputModes = {}
	
	local file = io.open(filePath, "r")
	local fileContent = file:read("*all")
	file:close()
	local jsonData = json.decode(fileContent)
	
	for _, inputModeData in ipairs(jsonData) do
		local inputMode = ncdk.InputMode:new()
		for inputType, inputData in pairs(inputModeData) do
			for inputIndex, binding in ipairs(inputData) do
				inputMode:setInput(inputType, inputIndex, binding)
			end
		end
		table.insert(self.inputModes, inputMode)
	end
end

InputModeLoader.getInputMode = function(self, inputMode)
	for _, currentInputMode in ipairs(self.inputModes) do
		if inputMode <= currentInputMode then
			return currentInputMode
		end
	end
end