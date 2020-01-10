local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")
local NoteData = require("ncdk.NoteData")

local NoScratch = InconsequentialModifier:new()

NoScratch.name = "NoScratch"
NoScratch.shortName = "NoScratch"

NoScratch.type = "boolean"

NoScratch.apply = function(self)
	local noteChart = self.sequence.manager.noteChart

	noteChart.inputMode:setInputCount("scratch", nil)
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.inputType == "scratch" then
				noteData.noteType = "SoundNote"
				noteData.inputType = "auto"
				noteData.inputIndex = 0
			end
		end
	end
end

return NoScratch
