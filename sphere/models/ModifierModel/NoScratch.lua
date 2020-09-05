local Modifier = require("sphere.models.ModifierModel.Modifier")
local NoteData = require("ncdk.NoteData")

local NoScratch = Modifier:new()

NoScratch.inconsequential = true
NoScratch.type = "NoteChartModifier"

NoScratch.name = "NoScratch"
NoScratch.shortName = "NoScratch"

NoScratch.variableType = "boolean"

NoScratch.apply = function(self)
	local noteChart = self.noteChartModel.noteChart
	local layerDataSequence = noteChart.layerDataSequence

	noteChart.inputMode:setInputCount("scratch", nil)
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.inputType == "scratch" then
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)

				noteData.noteType = "SoundNote"
				noteData.inputType = "auto"
				noteData.inputIndex = 0
				
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
			end
		end
	end
end

return NoScratch
