local Modifier = require("sphere.models.ModifierModel.Modifier")

local NoScratch = Modifier:new()

NoScratch.type = "NoteChartModifier"
NoScratch.interfaceType = "toggle"

NoScratch.defaultValue = true
NoScratch.name = "NoScratch"
NoScratch.shortName = "NSC"

NoScratch.description = "Remove scratch notes"

NoScratch.getString = function(self, config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

NoScratch.applyMeta = function(self, config, state)
	if not config.value then
		return
	end
	state.inputMode.scratch = nil
end

NoScratch.apply = function(self, config)
	if not config.value then
		return
	end

	local noteChart = self.noteChart

	noteChart.inputMode.scratch = nil

	for _, layerData in noteChart:getLayerDataIterator() do
		if layerData.noteDatas.scratch then
			for _, noteDatas in ipairs(layerData.noteDatas.scratch) do
				for _, noteData in ipairs(noteDatas) do
					noteData.noteType = "SoundNote"
					layerData:addNoteData(noteData, "auto", 0)
				end
			end
			layerData.noteDatas.scratch = nil
		end
	end
end

return NoScratch
