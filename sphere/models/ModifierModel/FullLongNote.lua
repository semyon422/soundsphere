local Modifier = require("sphere.models.ModifierModel.Modifier")
local NoteData = require("ncdk.NoteData")

local FullLongNote = Modifier:new()

FullLongNote.type = "NoteChartModifier"
FullLongNote.interfaceType = "slider"

FullLongNote.name = "FullLongNote"

FullLongNote.defaultValue = 0
FullLongNote.range = {0, 3}

FullLongNote.description = "Replace short notes with long notes"

FullLongNote.getString = function(self, config)
	return "FLN"
end

FullLongNote.getSubString = function(self, config)
	return config.value
end

FullLongNote.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart
	self.notes = {}

	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
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

	noteChart:compute()
end

FullLongNote.processNoteData = function(self, noteDataIndex)
	local notes = self.notes
	local n = notes[noteDataIndex]
	if n.noteType ~= "ShortNote" then
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
	if timePointList[1] == n.timePoint then
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
	elseif level >= 1 and #timePointList >= 2 and (not _n or _n.timePoint ~= timePointList[2]) then
		endTimePoint = timePointList[2]
	elseif level >= 0 and #timePointList >= 1 and (not _n or _n.timePoint ~= timePointList[1]) then
		endTimePoint = timePointList[1]
	end

	if not endTimePoint then
		return
	end

	n.noteType = "LongNoteStart"

	local endNoteData = NoteData:new(endTimePoint)
	endNoteData.noteType = "LongNoteEnd"

	endNoteData.startNoteData = n
	n.endNoteData = endNoteData

	self.noteDataLayers[n]:addNoteData(endNoteData, n.inputType, n.inputIndex)
end

FullLongNote.cleanTimePointList = function(self, timePointList, _n)
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
