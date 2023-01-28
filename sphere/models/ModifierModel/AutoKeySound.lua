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

	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		local layerData = noteChart.layerDatas[layerDataIndex]
		for _, noteData in ipairs(noteDatas) do
			if noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart" then
				local soundNoteData = NoteData:new(noteData.timePoint)

				soundNoteData.noteType = "SoundNote"
				soundNoteData.sounds, noteData.sounds = noteData.sounds, {}

				layerData:addNoteData(soundNoteData, "auto", 0)
			end
		end
	end
end

return AutoKeySound
