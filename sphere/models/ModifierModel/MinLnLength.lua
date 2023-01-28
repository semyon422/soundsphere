local Modifier = require("sphere.models.ModifierModel.Modifier")

local MinLnLength = Modifier:new()

MinLnLength.type = "NoteChartModifier"
MinLnLength.interfaceType = "slider"

MinLnLength.name = "MinLnLength"

MinLnLength.defaultValue = 0.4
MinLnLength.range = {0, 40}
MinLnLength.step = 0.025

MinLnLength.description = "Convert long notes to short notes if they are shorter than this length"

MinLnLength.getString = function(self, config)
	return "MLL"
end

MinLnLength.getSubString = function(self, config)
	return config.value * 1000
end

MinLnLength.apply = function(self, config)
	local duration = config.value
	local noteChart = self.game.noteChartModel.noteChart

	for noteDatas in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if noteData.noteType == "LongNoteStart" or noteData.noteType == "LaserNoteStart" then
				if (noteData.endNoteData.timePoint.absoluteTime - noteData.timePoint.absoluteTime) <= duration then
					noteData.noteType = "ShortNote"
					noteData.endNoteData.noteType = "Ignore"
				end
			end
		end
	end
end

return MinLnLength
