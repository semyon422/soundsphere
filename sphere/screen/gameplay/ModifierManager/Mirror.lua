local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local Mirror = InconsequentialModifier:new()

Mirror.name = "Mirror"
Mirror.shortName = "Mirror"

Mirror.apply = function(self)
	local noteChart = self.sequence.manager.noteChart
	local keyCount = noteChart.inputMode:getInputCount("key")
	local scratchCount = noteChart.inputMode:getInputCount("scratch")
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.inputType == "key" then
				noteData.inputIndex = keyCount - noteData.inputIndex + 1
			elseif noteData.inputType == "scratch" then
				noteData.noteType = scratchCount - noteData.inputIndex + 1
			end
		end
	end
end

return Mirror
