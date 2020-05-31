local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local BracketSwap = Modifier:new()

BracketSwap.sequential = true
BracketSwap.type = "NoteChartModifier"

BracketSwap.name = "BracketSwap"
BracketSwap.shortName = "BS"

BracketSwap.variableType = "boolean"

BracketSwap.getMap = function(self)
	local noteChart = self.sequence.manager.noteChart

	local keyCount = noteChart.inputMode:getInputCount("key")

	local map = {
		key = {}
	}
	local keymap = map.key

	local half = math.floor(keyCount / 2)
	for i = 1, half do
		keymap[i] = (2 * (i - 1)) % half + 1
		keymap[keyCount - i + 1] = keyCount - (2 * (i - 1)) % half
	end

	return map
end

BracketSwap.apply = function(self)
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

return BracketSwap
