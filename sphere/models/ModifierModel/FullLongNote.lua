local Modifier = require("sphere.models.ModifierModel.Modifier")
local Notes = require("ncdk2.notes.Notes")
local Note = require("ncdk2.notes.Note")

---@class sphere.FullLongNote: sphere.Modifier
---@operator call: sphere.FullLongNote
local FullLongNote = Modifier + {}

FullLongNote.name = "FullLongNote"

FullLongNote.defaultValue = 0
FullLongNote.values = {0, 1, 2, 3}

FullLongNote.description = "Replace short notes with long notes"

---@param config table
---@return string
---@return string
function FullLongNote:getString(config)
	return "FLN", tostring(config.value)
end

---@param config table
---@param chart ncdk2.Chart
function FullLongNote:apply(config, chart)
	self.notes = {}
	self.chart = chart

	for _, note in chart.notes:iter() do
		if
			note.noteType == "ShortNote" or
			note.noteType == "SoundNote" or
			note.noteType == "Ignore" or
			note.noteType == "LongNoteStart" or
			note.noteType == "LongNoteEnd"
		then
			table.insert(self.notes, {
				noteData = note,
				column = note.column,
			})
		end
	end

	table.sort(self.notes, function(a, b)
		return a.noteData < b.noteData
	end)

	self.level = config.value

	local notes = self.notes
	for i = 1, #notes do
		self:processNoteData(i)
	end

	chart:compute()
end

---@param noteDataIndex number
function FullLongNote:processNoteData(noteDataIndex)
	local notes = self.notes
	local n = notes[noteDataIndex]
	if n.noteData.noteType ~= "ShortNote" then
		return
	end

	local timePoints = {}
	local _n
	for i = noteDataIndex + 1, #notes do
		_n = notes[i]
		timePoints[_n.noteData.visualPoint] = true
		if _n.column == n.column then
			break
		end
	end

	local timePointList = {}
	for timePoint in pairs(timePoints) do
		table.insert(timePointList, timePoint)
	end
	table.sort(timePointList)
	timePointList = self:cleanTimePointList(timePointList, _n)
	if timePointList[1] == n.noteData.visualPoint then
		table.remove(timePointList, 1)
	end

	local endTimePoint
	local level = self.level
	if level >= 3 and #timePointList >= 2 then
		if not _n then
			endTimePoint = timePointList[#timePointList]
		else
			endTimePoint = timePointList[#timePointList - 1]
		end
	elseif level >= 2 and #timePointList >= 3 then
		endTimePoint = timePointList[math.ceil(#timePointList / 2)]
	elseif level >= 1 and #timePointList >= 2 and (not _n or _n.noteData.visualPoint ~= timePointList[2]) then
		endTimePoint = timePointList[2]
	elseif level >= 0 and #timePointList >= 1 and (not _n or _n.noteData.visualPoint ~= timePointList[1]) then
		endTimePoint = timePointList[1]
	end

	if not endTimePoint then
		return
	end

	n.noteData.noteType = "LongNoteStart"

	local endNote = Note(endTimePoint, n.column)
	endNote.noteType = "LongNoteEnd"

	endNote.startNote = n.noteData
	n.noteData.endNote = endNote

	self.chart.notes:insert(endNote)
end

---@param timePointList ncdk2.VisualPoint[]
---@param _n table
---@return table
function FullLongNote:cleanTimePointList(timePointList, _n)
	local out = {timePointList[1]}

	for i = 2, #timePointList do
		if timePointList[i].point.absoluteTime - out[#out].point.absoluteTime >= 0.005 then
			table.insert(out, timePointList[i])
		end
	end

	if _n and _n.noteData:getTime() - out[#out].point.absoluteTime < 0.005 then
		out[#out] = _n.noteData.visualPoint
	end

	return out
end

return FullLongNote
