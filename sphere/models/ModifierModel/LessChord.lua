local Modifier = require("sphere.models.ModifierModel.Modifier")

local LessChord = Modifier:new()

LessChord.type = "NoteChartModifier"
LessChord.interfaceType = "stepper"

LessChord.name = "LessChord"

LessChord.defaultValue = "all"
LessChord.range = {1, 9}
LessChord.values = {"all", "0.25", "0.5", "0.75", "1", "2", "3", "4", "5"}

LessChord.getString = function(self, config)
	return "LC"
end

LessChord.getSubString = function(self, config)
	local res = config.value
	if res == "all" then
		res = "A"
	elseif res == "0.25" then
		res = ".25"
	elseif res == "0.5" then
		res = ".5"
	elseif res == "0.75" then
		res = ".75"
	end
	return res
end

-- TODO: Also remove LN + ShortNote chords
--		 and LN + LN chords
LessChord.apply = function(self, config)
	local configVal
	if (config.value ~= "all") then
		configVal = tonumber(config.value)
	end

	local noteChart = self.noteChartModel.noteChart
	local layerDataSequence = noteChart.layerDataSequence
	local inputCount = noteChart.inputMode:getInputCount("key")

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)

		local chords = {}
		local noteDatas = {}
		local columnSizes = {}
		for i=0, inputCount do
			columnSizes[i] = 0
		end

		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)

			if (noteData.inputType == "key") then
				local index = noteData.inputIndex
				local time = noteData.timePoint.absoluteTime

				columnSizes[index] = columnSizes[index] + 1
				if noteData.noteType == "ShortNote" then
					if chords[time] ~= nil then
						table.insert(chords[time].notes, noteData)
						chords[time].columnSizes = { unpack(columnSizes) }
					else
						if noteDatas[time] ~= nil then
							chords[time] = {
								time = time,
								notes = { noteDatas[time], noteData },
								columnSizes =  { unpack(columnSizes) }
							}
						end

						noteDatas[time] = noteData
					end
				end
			end
		end

		local sortedChords = {}
		for _, chord in pairs(chords) do
			sortedChords[#sortedChords+1] = chord
		end
		table.sort(sortedChords, function(a, b) return a.time < b.time end)

		for chordCount, chord in ipairs(sortedChords) do
			if configVal == nil or
					(configVal >= 1 and chordCount % (configVal + 1) ~= 0) or
					(configVal < 1 and (chordCount * 100) % (configVal * 100 + 100) == 0) then
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
						for _, futureChord in ipairs(sortedChords) do
							futureChord.columnSizes[noteData.inputIndex] = futureChord.columnSizes[noteData.inputIndex] - 1
						end

						layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)

						noteData.noteType = "SoundNote"
						noteData.inputType = "auto"
						noteData.inputIndex = 0

						layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
					end
				end
			end
		end
	end
end

return LessChord
