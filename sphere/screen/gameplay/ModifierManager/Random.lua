local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local Random = Modifier:new()

Random.inconsequential = true
Random.type = "NoteChartModifier"

Random.name = "Random"
Random.shortName = "RD"

Random.variableType = "boolean"

Random.getMap = function(self)
	local noteChart = self.sequence.manager.noteChart

	local maxInputs = {}
	local inputs = {}
	for inputType, inputIndex in noteChart:getInputIteraator() do
		inputs[inputType] = inputs[inputType] or {}
		inputs[inputType][#inputs[inputType] + 1] = inputIndex

		maxInputs[inputType] = math.max(maxInputs[inputType] or 0, inputIndex)
	end

	local map = {}

	for inputType, subInputs in pairs(inputs) do
		if maxInputs[inputType] > 0 then
			local availableIndices = {}
			for i = 1, #inputs[inputType] do
				availableIndices[i] = inputs[inputType][i]
			end

			map[inputType] = {}

			local list = map[inputType]
			for i = 1, #inputs[inputType] do
				local index = math.random(1, #availableIndices)
				list[inputs[inputType][i]] = availableIndices[index]
				table.remove(availableIndices, index)
			end
		end
	end

	return map
end

Random.apply = function(self)
	math.randomseed(os.time())

	local map = self:getMap()

	local noteChart = self.sequence.manager.noteChart
	local layerDataSequence = noteChart.layerDataSequence
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			if map[noteData.inputType] then
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)
				noteData.inputIndex = map[noteData.inputType][noteData.inputIndex]
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
			end
		end
	end
end

return Random
