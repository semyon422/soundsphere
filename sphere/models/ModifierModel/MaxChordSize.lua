local Modifier = require("sphere.models.ModifierModel.Modifier")

local MaxChordSize = Modifier:new()

MaxChordSize.type = "NoteChartModifier"
MaxChordSize.interfaceType = "stepper"

MaxChordSize.name = "MaxChordSize"

MaxChordSize.defaultValue = 3
MaxChordSize.range = {1, 69}

MaxChordSize.description = "How many notes can be in one row"

MaxChordSize.getString = function(self, config)
    return "MCS"
end

MaxChordSize.getSubString = function(self, config)
    return config.value
end

MaxChordSize.apply = function(self, config)
	local maxChordSize = tonumber(config.value)
	local noteChart = self.noteChart

	local chordSizesByTimings = {}
	self.notes = {}
	for noteDatas in self.noteChart:getInputIterator() do
		for i, noteData in pairs(noteDatas) do
			local chordSize = 0
			if chordSizesByTimings[noteData.timePoint.absoluteTime] ~= nil then
				chordSize = chordSizesByTimings[noteData.timePoint.absoluteTime]
			end
			if chordSize >= maxChordSize and noteData.noteType == "ShortNote" then
				noteDatas[i].noteType = "ignore"
			else
				chordSizesByTimings[noteData.timePoint.absoluteTime] = chordSize + 1
			end
		end
	end

	noteChart:compute()
end

return MaxChordSize
