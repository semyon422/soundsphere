local NoteData					= require("ncdk.NoteData")
local InconsequentialModifier	= require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local DoublePlay = InconsequentialModifier:new()

DoublePlay.name = "DoublePlay"
DoublePlay.shortName = "DP"

DoublePlay.type = "boolean"

DoublePlay.apply = function(self)
	local noteChart = self.sequence.manager.noteChart
	self.noteChart = noteChart

	self.columnCount = self.noteChart.inputMode:getInputCount("key")
	self.targetMode = self.columnCount * 2
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			if
				noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart"
			then
				local newNoteData = NoteData:new(noteData.timePoint)

				newNoteData.endNoteData = noteData.endNoteData
				newNoteData.noteType = noteData.noteType
				newNoteData.inputType = noteData.inputType
				newNoteData.inputIndex = noteData.inputIndex + self.columnCount
				newNoteData.sounds = noteData.sounds

				layerData:addNoteData(newNoteData)
			end
		end
	end
	
	self.noteChart.inputMode:setInputCount("key", self.targetMode)

	noteChart:compute()
end

return DoublePlay
