local Modifier = require("sphere.models.ModifierModel.Modifier")

local MinLnLength = Modifier:new()

MinLnLength.sequential = true
MinLnLength.type = "NoteChartModifier"

MinLnLength.name = "MinLnLength"
MinLnLength.shortName = "MLL"

MinLnLength.variableType = "number"
MinLnLength.variableName = "duration"
MinLnLength.variableRange = {0, 25, 1000}

MinLnLength.duration = 400

MinLnLength.construct = function(self)
	self.duration = MinLnLength.duration
end

MinLnLength.tostring = function(self)
	return self.shortName .. self.duration
end

MinLnLength.tojson = function(self)
	return ([[{"name":"%s","duration":%s}]]):format(self.name, self.duration)
end

MinLnLength.apply = function(self)
	local duration = self.duration / 1000
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
