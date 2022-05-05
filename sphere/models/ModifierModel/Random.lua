local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

local Random = SwapModifier:new()

Random.type = "NoteChartModifier"
Random.interfaceType = "stepper"

Random.name = "Random"

Random.defaultValue = "all"
Random.range = {1, 3}
Random.values = {"all", "left", "right"}

Random.getString = function(self, config)
	return "RD"
end

Random.getSubString = function(self, config)
	return config.value:sub(1, 1):upper()
end

Random.getMap = function(self, config)
	local noteChart = self.noteChartModel.noteChart
	local value = config.value

	local inputs = {}
	for inputType, inputIndex in noteChart:getInputIteraator() do
		if noteChart.inputMode:getInputCount(inputType) > 0 then
			inputs[inputType] = inputs[inputType] or {}
			inputs[inputType][#inputs[inputType] + 1] = inputIndex
		end
	end

	local filteredInputs = {}
	for inputType, subInputs in pairs(inputs) do
		local inputCount = noteChart.inputMode:getInputCount(inputType)
		filteredInputs[inputType] = {}
		local filteredSubInputs = filteredInputs[inputType]

		local halfFloor = math.floor(inputCount / 2)
		local halfCeil = math.ceil(inputCount / 2)
		for i = 1, #subInputs do
			if value == "all" then
				filteredSubInputs[#filteredSubInputs + 1] = subInputs[i]
			elseif value == "left" then
				if subInputs[i] <= halfFloor then
					filteredSubInputs[#filteredSubInputs + 1] = subInputs[i]
				end
			elseif value == "right" then
				if subInputs[i] > halfCeil then
					filteredSubInputs[#filteredSubInputs + 1] = subInputs[i]
				end
			end
		end
	end

	inputs = filteredInputs

	local map = {}

	for inputType, subInputs in pairs(inputs) do
		local availableIndices = {}
		for i = 1, #subInputs do
			availableIndices[i] = subInputs[i]
		end

		map[inputType] = {}

		local submap = map[inputType]
		for i = 1, #subInputs do
			local index = math.random(1, #availableIndices)
			submap[subInputs[i]] = availableIndices[index]
			table.remove(availableIndices, index)
		end
	end

	return map
end

return Random
