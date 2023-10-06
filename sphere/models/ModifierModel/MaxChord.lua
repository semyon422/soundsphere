local Modifier = require("sphere.models.ModifierModel.Modifier")
local NoteData = require("ncdk.NoteData")

---@class sphere.MaxChord
---@operator call: sphere.MaxChord
local MaxChord = Modifier + {}

MaxChord.interfaceType = "slider"

MaxChord.name = "MaxChord"

MaxChord.defaultValue = 1
MaxChord.values = {}

for i = 1, 10 do
	table.insert(MaxChord.values, i)
end

MaxChord.description = "All chords will be <= modifier value"

---@param config table
---@return string
---@return string
function MaxChord:getString(config)
	return "CH", tostring(config.value)
end

---@param noteData ncdk.NoteData
---@return boolean
local function checkNote(noteData)
	return noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart"
end

---@param noteDatas table
---@param i number
---@param dir number?
---@return number
local function getNextTime(noteDatas, i, dir)
	dir = dir or 1
	for j = i + dir, #noteDatas, dir do
		local noteData = noteDatas[j]
		if checkNote(noteData) then
			return noteData.timePoint.absoluteTime
		end
	end
	return math.huge
end

---@param a table
---@param b table
---@return boolean
local function sortByColumn(a, b)
	return a.column < b.column
end

---@param line table
---@param columns number
---@return string
local function getCounterKey(line, columns)  -- use bit.bor
	local t = {}
	for i = 1, columns do
		t[i] = 0
	end
	for _, note in ipairs(line) do
		t[note.column] = 1
	end
	return table.concat(t)
end

---@param t table
---@param v any
---@return any?
local function removeValue(t, v)
	for i, _v in ipairs(t) do
		if _v == v then
			table.remove(t, i)
			return v
		end
	end
end

local function zeroes(size)
	local t = {}
	for i = 1, size do
		t[i] = 0
	end
	return t
end

---@param config table
function MaxChord:apply(config)
	local maxChord = config.value
	local noteChart = self.noteChart

	local columns = noteChart.inputMode.key

	local notes = {}
	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		if inputType == "key" then
			for i, noteData in ipairs(noteDatas) do
				if checkNote(noteData) then
					table.insert(notes, {
						noteData = noteData,
						time = noteData.timePoint.absoluteTime,
						nextTime = getNextTime(noteDatas, i),
						prevTime = getNextTime(noteDatas, i, -1),
						column = inputIndex,
						layer = layerDataIndex,
					})
				end
			end
		end
	end

	local linesMap = {}
	for _, note in ipairs(notes) do
		local time = note.time
		linesMap[time] = linesMap[time] or {time = time}
		table.insert(linesMap[time], note)
	end

	local lines = {}
	for _, line in pairs(linesMap) do
		table.insert(lines, line)
		table.sort(line, sortByColumn)
	end
	table.sort(lines, function(a, b)
		return a.time < b.time
	end)

	local counters = {}
	local deletedNotes = {}

	for i = 1, #lines do
		local line = lines[i]
		local nextLineTime = lines[i + 1] and lines[i + 1].time or math.huge

		while #line > maxChord do
			local minNextTime, maxNextTime
			for _, note in ipairs(line) do
				if (not minNextTime or note.nextTime < minNextTime) and note.nextTime ~= nextLineTime then
					minNextTime = note.nextTime
				end
			end

			local notesToDelete = line
			if minNextTime then
				notesToDelete = {}
				for _, note in ipairs(line) do
					if note.nextTime == minNextTime then
						table.insert(notesToDelete, note)
					end
				end
			end

			if #notesToDelete == 1 then
				removeValue(line, notesToDelete[1])
				table.insert(deletedNotes, notesToDelete[1])
			else
				local key = getCounterKey(notesToDelete, columns)
				counters[key] = counters[key] or zeroes(#notesToDelete)
				local counter = counters[key]

				local min_cIndex = 1
				for k = 1, #counter do
					if counter[k] == 0 then
						min_cIndex = k
					end
				end
				local note = notesToDelete[min_cIndex]
				counter[min_cIndex] = counter[min_cIndex] + 1
				removeValue(line, note)
				table.insert(deletedNotes, note)

				local s = 0
				for k = 1, #counter do
					s = s + counter[k]
				end
				if s == #counter then
					counters[key] = zeroes(#counter)
				end
			end
		end
	end

	for _, note in ipairs(deletedNotes) do
		local layerData = noteChart.layerDatas[note.layer]

		local noteData = note.noteData
		-- noteData.noteType = "SoundNote"
		noteData.noteType = "Ignore"
		if noteData.endNoteData then
			noteData.endNoteData.noteType = "Ignore"
		end

		local soundNoteData = NoteData(noteData.timePoint)

		soundNoteData.noteType = "SoundNote"
		soundNoteData.sounds, noteData.sounds = noteData.sounds, {}

		layerData:addNoteData(soundNoteData, "auto", 0)
	end
end

return MaxChord
