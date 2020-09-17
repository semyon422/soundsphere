local Class = require("aqua.util.Class")
local enps = require("libchart.enps")

local DifficultyModel = Class:new()

DifficultyModel.getDifficulty = function(self, noteChart)
	local notes = {}

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)

		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)

			if
				noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart" or
				noteData.noteType == "LaserNoteStart"
			then
				notes[#notes + 1] = {
					time = noteData.timePoint.absoluteTime,
					input = noteData.inputType .. noteData.inputIndex
				}
			end
		end
	end

	return enps.getEnps(notes)
end

return DifficultyModel
