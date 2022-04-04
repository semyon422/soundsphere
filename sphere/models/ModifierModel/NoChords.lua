local Modifier = require("sphere.models.ModifierModel.Modifier")

local NoChords = Modifier:new()

NoChords.type = "NoteChartModifier"
NoChords.interfaceType = "toggle"

NoChords.defaultValue = true
NoChords.name = "NoChords"
NoChords.shortName = "NCH"

NoChords.getString = function(self, config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

local function getColumnSizes(columns)
	local columnSizes = {}
	for i, v in ipairs(columns) do
		columnSizes[i] = v.size
	end
	return columnSizes
end

-- TODO: Also remove LN + ShortNote chords
--		 and LN + LN chords
NoChords.apply = function(self, config)
	if not config.value then
		return
	end

	local noteChart = self.noteChartModel.noteChart
	local inputCount = noteChart.inputMode:getInputCount("key")
	local chords = {}
	local columns = {}
	for i=0, inputCount do
		columns[i] = { size=0 }
	end

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)

		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)

			if (noteData.inputType == "key") then
				local index = noteData.inputIndex
				local time = noteData.timePoint.absoluteTime

				columns[index].size = columns[index].size + 1
				if noteData.noteType == "ShortNote" then
					if chords[time] ~= nil then
						table.insert(chords[time].notes, noteData)
						chords[time].columnSizes = getColumnSizes(columns)
					else
						for _, column in ipairs(columns) do
							if column[time] ~= nil then
								chords[time] = {
									time = time,
									notes = { column[time], noteData },
									columnSizes = getColumnSizes(columns)
								}
							end
						end
					end
				end

				columns[index][time] = noteData
			end
		end

		local sortedChords = {}
		for _, chord in pairs(chords) do
			sortedChords[#sortedChords+1] = chord
		end
		table.sort(sortedChords, function(a, b) return a.time < b.time end)

		for _, chord in ipairs(sortedChords) do
			table.sort(chord.notes, function(a, b) return a.inputIndex < b.inputIndex end)
			local lowestSize = math.huge
			local noteDataToKeep
			for _, noteData in ipairs(chord.notes) do
				local columnSize = chord.columnSizes[noteData.inputIndex]
				if columnSize < lowestSize then
					lowestSize = columnSize
					noteDataToKeep = noteData
				end
			end

			for _, noteData in pairs(chord.notes) do
				if noteData ~= noteDataToKeep then
					noteData.noteType = "Ignore"

					for _, futureChord in ipairs(sortedChords) do
						futureChord.columnSizes[noteData.inputIndex] = futureChord.columnSizes[noteData.inputIndex] - 1
					end
				end
			end
		end
	end
end

return NoChords
