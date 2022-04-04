local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

local Mirror = SwapModifier:new()

Mirror.type = "NoteChartModifier"
Mirror.interfaceType = "stepper"

Mirror.name = "Mirror"

Mirror.defaultValue = "all"
Mirror.range = {1, 3}
Mirror.values = {"all", "left", "right"}

Mirror.getString = function(self, config)
	return "MR"
end

Mirror.getSubString = function(self, config)
	return config.value:sub(1, 1):upper()
end

Mirror.getMap = function(self, config)
	local noteChart = self.noteChartModel.noteChart

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

	local value = config.value
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
