local Modifier = require("sphere.models.RhythmModel.ModifierManager.Modifier")

local SwapModifier = Modifier:new()

SwapModifier.sequential = true
SwapModifier.type = "NoteChartModifier"

SwapModifier.name = "SwapModifier"
SwapModifier.shortName = "SwapModifier"

SwapModifier.apply = function(self)
	local map = self:getMap()

	local noteChart = self.sequence.manager.noteChart
	local layerDataSequence = noteChart.layerDataSequence
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			local submap = map[noteData.inputType]
			if submap and submap[noteData.inputIndex] then
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)
				noteData.inputIndex = submap[noteData.inputIndex]
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
			end
		end
	end
end

return SwapModifier
