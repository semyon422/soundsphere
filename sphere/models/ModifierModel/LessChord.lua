local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.LessChord: sphere.Modifier
---@operator call: sphere.LessChord
local LessChord = Modifier + {}

LessChord.name = "LessChord"

LessChord.defaultValue = "none"
LessChord.values = {"none", "-5", "-4", "-3", "2", "3", "4", "5"}

LessChord.description = [[
Stepper values are:
none: no chords
-5: every 5th chord kept
-4: every 4th chord kept
-3: every 3rd chord kept
2: every 2nd chord removed
3: every 3rd chord removed
4: every 4th chord removed
5: every 5th chord removed]]

---@param config table
---@return string
---@return string
function LessChord:getString(config)
	return "LC", config.value == "none" and "N" or tostring(config.value)
end

-- TODO: Also remove LN + ShortNote chords
--		 and LN + LN chords

---@param config table
function LessChord:apply(config)
	local configVal
	if config.value ~= "none" then
		configVal = tonumber(config.value)
	end

	local noteChart = self.noteChart
	local inputCount = noteChart.inputMode.key

	for _, layerData in noteChart:getLayerDataIterator() do
		local chords = {}
		local singles = {}
		local noteDatas = {}
		local columnSizes = {}
		for i = 1, inputCount do
			columnSizes[i] = 0
		end

		local notes = {}
		if layerData.noteDatas.key then
			for inputIndex, _noteDatas in pairs(layerData.noteDatas.key) do
				for _, noteData in ipairs(_noteDatas) do
					table.insert(notes, {
						noteData = noteData,
						inputIndex = inputIndex,
					})
				end
			end
			layerData.noteDatas.key = {}
		end
		table.sort(notes, function(a, b) return a.noteData < b.noteData end)

		for _, note in ipairs(notes) do
			local noteData = note.noteData
			local index = note.inputIndex
			local time = noteData.timePoint.absoluteTime

			columnSizes[index] = columnSizes[index] + 1
			if noteData.noteType == "ShortNote" then
				if chords[time] then
					table.insert(chords[time].notes, note)
					chords[time].columnSizes = {unpack(columnSizes)}
				else
					singles[time] = note

					if noteDatas[time] then
						chords[time] = {
							time = time,
							notes = {noteDatas[time], note},
							columnSizes = {unpack(columnSizes)}
						}
						singles[time] = nil
					end

					noteDatas[time] = note
				end
			end
		end

		for _, note in pairs(singles) do
			layerData:addNoteData(note.noteData, "key", note.inputIndex)
		end

		local sortedChords = {}
		for _, chord in pairs(chords) do
			sortedChords[#sortedChords + 1] = chord
		end
		table.sort(sortedChords, function(a, b) return a.time < b.time end)

		for chordCount, chord in ipairs(sortedChords) do
			if configVal == nil or
				(configVal > 0 and chordCount % configVal == 0) or
				(configVal < 0 and chordCount % math.abs(configVal) ~= 0)
			then
				table.sort(chord.notes, function(a, b) return a.inputIndex < b.inputIndex end)
				local lowestSize = math.huge
				local noteDataToKeep
				for _, note in ipairs(chord.notes) do
					local columnSize = chord.columnSizes[note.inputIndex]
					if columnSize < lowestSize then
						lowestSize = columnSize
						noteDataToKeep = note
					end
				end

				for _, note in pairs(chord.notes) do
					if note ~= noteDataToKeep then
						for _, futureChord in ipairs(sortedChords) do
							futureChord.columnSizes[note.inputIndex] = futureChord.columnSizes[note.inputIndex] - 1
						end

						note.noteData.noteType = "SoundNote"
						layerData:addNoteData(note.noteData, "auto", 0)
					else
						layerData:addNoteData(note.noteData, "key", note.inputIndex)
					end
				end
			else
				for _, note in pairs(chord.notes) do
					layerData:addNoteData(note.noteData, "key", note.inputIndex)
				end
			end
		end
	end

	noteChart:compute()
end

return LessChord
