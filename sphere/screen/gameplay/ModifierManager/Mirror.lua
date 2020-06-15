local SwapModifier = require("sphere.screen.gameplay.ModifierManager.SwapModifier")

local Mirror = SwapModifier:new()

Mirror.sequential = true
Mirror.type = "NoteChartModifier"

Mirror.name = "Mirror"
Mirror.shortName = "Mirror"

Mirror.variableType = "number"
Mirror.variableName = "value"
Mirror.variableFormat = "%s"
Mirror.variableRange = {1, 1, 3}
Mirror.variableValues = {"all", "left", "right"}
Mirror.value = 1

Mirror.modeNames = {"A", "L", "R"}

Mirror.tostring = function(self)
	return self.shortName .. self.modeNames[self.value]
end

Mirror.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
end

Mirror.getMap = function(self)
	local noteChart = self.sequence.manager.noteChart

	local inputCounts = {}
	for inputType, inputIndex in noteChart:getInputIteraator() do
		if not inputCounts[inputType] then
			local inputCount = noteChart.inputMode:getInputCount(inputType)
			if inputCount > 0 then
				inputCounts[inputType] = inputCount
			end
		end
	end

	local map = {}

	local value = self.value
	for inputType, inputCount in pairs(inputCounts) do
		map[inputType] = {}
		local submap = map[inputType]
		local halfFloor = math.floor(inputCount / 2)
		local halfCeil = math.ceil(inputCount / 2)
		if value == 1 then
			for i = 1, inputCount do
				submap[i] = inputCount - i + 1
			end
		elseif value == 2 then
			for i = 1, halfFloor do
				submap[i] = halfFloor - i + 1
			end
		elseif value == 3 then
			for i = 1, halfFloor do
				submap[halfCeil + i] = inputCount - i + 1
			end
		end
	end

	return map
end

return Mirror
