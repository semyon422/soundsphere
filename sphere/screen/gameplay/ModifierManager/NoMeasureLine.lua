local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local NoMeasureLine = InconsequentialModifier:new()

NoMeasureLine.name = "NoMeasureLine"
NoMeasureLine.shortName = "NML"

NoMeasureLine.apply = function(self)
	local noteChart = self.sequence.manager.noteChart
	
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
