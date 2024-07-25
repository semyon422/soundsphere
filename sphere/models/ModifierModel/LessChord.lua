local Modifier = require("sphere.models.ModifierModel.Modifier")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

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
---@param chart ncdk2.Chart
function LessChord:apply(config, chart)
	local configVal
	if config.value ~= "none" then
		configVal = tonumber(config.value)
	end

	local inputCount = chart.inputMode.key

	local chords = {}
	local singles = {}
	local noteDatas = {}
	local columnSizes = {}
	for i = 1, inputCount do
		columnSizes[i] = 0
	end

	local new_notes = Notes()
	local notes = {}
	for _, note in chart.notes:iter() do
		local inputType, inputIndex = InputMode:splitInput(note.column)
		if inputType == "key" then
			table.insert(notes, {
				noteData = note,
				inputIndex = inputIndex,
			})
		else
			new_notes:insert(note)
		end
	end
	chart.notes = new_notes
	table.sort(notes, function(a, b) return a.noteData < b.noteData end)

	for _, note in ipairs(notes) do
		local noteData = note.noteData
		local index = note.inputIndex
		local time = noteData:getTime()

		columnSizes[index] = columnSizes[index] + 1
		if noteData.type == "note" then
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
		note.noteData.column = "key" .. note.inputIndex
		chart.notes:insert(note.noteData)
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

					note.noteData.type = "sample"
					note.noteData.column = "auto" .. note.inputIndex
					chart.notes:insert(note.noteData)
				else
					note.noteData.column = "key" .. note.inputIndex
					chart.notes:insert(note.noteData)
				end
			end
		else
			for _, note in pairs(chord.notes) do
				note.noteData.column = "key" .. note.inputIndex
				chart.notes:insert(note.noteData)
			end
		end
	end

	chart:compute()
end

return LessChord
