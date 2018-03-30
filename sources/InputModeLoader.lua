InputModeLoader = createClass()

InputModeLoader.load = function(self, filePath)
	self.inputModes = {}
	
	local file = io.open(filePath, "r")
	for line in file:lines() do
		if line:trim() ~= "" then
			self:parseLine(line)
		end
	end
end

InputModeLoader.parseLine = function(self, line)
	local inputMode = ncdk.InputMode:new()
	
	for _, inputData in ipairs(line:split("|")) do
		local inputType, inputIndexDatas = unpack(inputData:split("#"))
		for _, inputIndexData in ipairs(inputIndexDatas:split("&")) do
			local inputIndex, binding = unpack(inputIndexData:split("^"))
			inputMode:setInput(inputType, tonumber(inputIndex), binding)
		end
	end
	
	table.insert(self.inputModes, inputMode)
end

InputModeLoader.getInputMode = function(self, inputMode)
	for _, currentInputMode in ipairs(self.inputModes) do
		if inputMode <= currentInputMode then
			return currentInputMode
		end
	end
end