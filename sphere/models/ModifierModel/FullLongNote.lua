local Modifier = require("sphere.models.ModifierModel.Modifier")
local NoteData = require("ncdk.NoteData")

---@class sphere.FullLongNote: sphere.Modifier
---@operator call: sphere.FullLongNote
local FullLongNote = Modifier + {}

FullLongNote.interfaceType = "slider"

FullLongNote.name = "FullLongNote"

FullLongNote.defaultValue = 0
FullLongNote.range = {0, 3}

FullLongNote.description = "Replace short notes with long notes"

---@param config table
---@return string
function FullLongNote:getString(config)
	return "FLN"
end

---@param config table
---@return string
function FullLongNote:getSubString(config)
	return tostring(config.value)
end

---@param config table
function FullLongNote:apply(config)
	self.notes = {}

	for noteDatas, inputType, inputIndex, layerDataIndex in self.noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if
				noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart" or
				noteData.noteType == "LongNoteEnd"
			then
				table.insert(self.notes, {
					noteData = noteData,
					inputType = inputType,
					inputIndex = inputIndex,
					layerDataIndex = layerDataIndex,
				})
			end
		end
	end

	table.sort(self.notes, function(a, b)
		return a.noteData.timePoint < b.noteData.timePoint
	end)

	self.level = config.value

	local notes = self.notes
	for i = 1, #notes do
		self:processNoteData(i)
	end

	self.noteChart:compute()
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
		timePoints[_n.noteData.timePoint] = true
		if
			_n.inputType == n.inputType and
			_n.inputIndex == n.inputIndex
		then
			break
		end
	end

	local timePointList = {}
	for timePoint in pairs(timePoints) do
		table.insert(timePointList, timePoint)
	end
	table.sort(timePointList)
	timePointList = self:cleanTimePointList(timePointList, _n)
	if timePointList[1] == n.noteData.timePoint then
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
	elseif level >= 1 and #timePointList >= 2 and (not _n or _n.noteData.timePoint ~= timePointList[2]) then
		endTimePoint = timePointList[2]
	elseif level >= 0 and #timePointList >= 1 and (not _n or _n.noteData.timePoint ~= timePointList[1]) then
		endTimePoint = timePointList[1]
	end

	if not endTimePoint then
		return
	end

	n.noteData.noteType = "LongNoteStart"

	local endNoteData = NoteData(endTimePoint)
	endNoteData.noteType = "LongNoteEnd"

	endNoteData.startNoteData = n.noteData
	n.noteData.endNoteData = endNoteData

	local noteChart = self.noteChart
	noteChart.layerDatas[n.layerDataIndex]:addNoteData(endNoteData, n.inputType, n.inputIndex)
end

---@param timePointList table
---@param _n table
---@return table
function FullLongNote:cleanTimePointList(timePointList, _n)
	local out = {}
	out[#out + 1] = timePointList[1]

	for i = 2, #timePointList do
		if timePointList[i].absoluteTime - out[#out].absoluteTime >= 0.005 then
			out[#out + 1] = timePointList[i]
		end
	end

	if _n and _n.noteData.timePoint.absoluteTime - out[#out].absoluteTime < 0.005 then
		out[#out] = _n.noteData.timePoint
	end

	return out
end

return FullLongNote
