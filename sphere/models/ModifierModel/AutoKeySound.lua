local Modifier = require("sphere.models.ModifierModel.Modifier")
local NoteData = require("ncdk.NoteData")

local AutoKeySound = Modifier:new()

AutoKeySound.type = "NoteChartModifier"
AutoKeySound.interfaceType = "toggle"

AutoKeySound.defaultValue = true
AutoKeySound.name = "AutoKeySound"
AutoKeySound.shortName = "AKS"

AutoKeySound.description = "Key sounds will not depend on the input"

AutoKeySound.getString = function(self, config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

AutoKeySound.apply = function(self, config)
	if not config.value then
		return
	end

	local noteChart = self.game.noteChartModel.noteChart

	for _, layerData in noteChart:getLayerDataIterator() do
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)

			if noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart" then
				local soundNoteData = NoteData:new(noteData.timePoint)

				soundNoteData.noteType = "SoundNote"
				soundNoteData.inputType = "auto"
				soundNoteData.inputIndex = 0
				soundNoteData.sounds = noteData.sounds
				noteData.sounds = {}

				layerData:addNoteData(soundNoteData)
			end
		end
	end
end

return AutoKeySound
