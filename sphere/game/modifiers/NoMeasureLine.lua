local Modifier = require("sphere.game.modifiers.Modifier")

local NoMeasureLine = Modifier:new()

NoMeasureLine.name = "NoMeasureLine"

NoMeasureLine.apply = function(self)
	local noteChart = self.sequence.noteChart
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.noteType == "LineNoteStart" then
				noteData.noteType = "Ignore"
			elseif noteData.noteType == "LineNoteEnd" then
				noteData.noteType = "Ignore"
			end
		end
	end
end

return NoMeasureLine
