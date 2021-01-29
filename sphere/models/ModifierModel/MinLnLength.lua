local Modifier = require("sphere.models.ModifierModel.Modifier")

local MinLnLength = Modifier:new()

MinLnLength.construct = function(self)
	self.config = {
		name = self.name,
		value = 400
	}
end

MinLnLength.sequential = true
MinLnLength.type = "NoteChartModifier"

MinLnLength.name = "MinLnLength"
MinLnLength.shortName = "MLL"

MinLnLength.defaultValue = 0
MinLnLength.range = {0, 40}
MinLnLength.step = 0.025

MinLnLength.getString = function(self, config)
	config = config or self.config
	return self.shortName .. self:getRealValue(config) * 1000
end

MinLnLength.apply = function(self)
	local duration = self:getRealValue()
	local noteChart = self.noteChartModel.noteChart

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)

		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)

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
