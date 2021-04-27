local Modifier = require("sphere.models.ModifierModel.Modifier")
local NoteData = require("ncdk.NoteData")

local FullLongNote = Modifier:new()

FullLongNote.type = "NoteChartModifier"
FullLongNote.interfaceType = "slider"

FullLongNote.name = "FullLongNote"

FullLongNote.defaultValue = 0
FullLongNote.range = {0, 3}

FullLongNote.getString = function(self, config)
	return "FLN" .. config.value
end

FullLongNote.apply = function(self, config)
	local noteChart = self.noteChartModel.noteChart
	self.noteDatas = {}
	self.noteDataLayers = {}

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			if
				noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart" or
				noteData.noteType == "LongNoteEnd"
			then
				self.noteDatas[#self.noteDatas + 1] = noteData
				self.noteDataLayers[noteData] = layerData
			end
		end
	end

	table.sort(self.noteDatas, function(noteData1, noteData2)
		return noteData1.timePoint < noteData2.timePoint
	end)

	self.level = config.value

	local noteDatas = self.noteDatas
	for i = 1, #noteDatas do
		self:processNoteData(i, noteDatas[i])
	end

	noteChart:compute()
end

FullLongNote.processNoteData = function(self, noteDataIndex, noteData)
	if noteData.noteType ~= "ShortNote" then
		return
	end

	local timePoints = {}
	local noteDatas = self.noteDatas
	local nNoteData
	for i = noteDataIndex, #noteDatas do
		local cNoteData = noteDatas[i]
		timePoints[cNoteData.timePoint] = true
		if
			cNoteData.inputType == noteData.inputType and
			cNoteData.inputIndex == noteData.inputIndex and
			cNoteData ~= noteData
		then
			nNoteData = cNoteData
			break
		end
	end

	local timePointList = {}
	for timePoint in pairs(timePoints) do
		table.insert(timePointList, timePoint)
	end
	table.sort(timePointList)
	timePointList = self:cleanTimePointList(timePointList, nNoteData)
	if timePointList[1] == noteData.timePoint then
		table.remove(timePointList, 1)
	end

	local endTimePoint
	local level = self.level
	if level >= 3 and #timePointList >= 2 then
		if not nNoteData then
			endTimePoint = timePointList[#timePointList]
		else
			endTimePoint = timePointList[#timePointList - 1]
		end
	elseif level >= 2 and #timePointList >= 3 then
		endTimePoint = timePointList[math.ceil(#timePointList / 2)]
	elseif level >= 1 and #timePointList >= 2 and (not nNoteData or nNoteData.timePoint ~= timePointList[2]) then
		endTimePoint = timePointList[2]
	elseif level >= 0 and #timePointList >= 1 and (not nNoteData or nNoteData.timePoint ~= timePointList[1]) then
		endTimePoint = timePointList[1]
	end

	if not endTimePoint then
		return
	end

	noteData.noteType = "LongNoteStart"

	local endNoteData = NoteData:new(endTimePoint)
	endNoteData.inputType = noteData.inputType
	endNoteData.inputIndex = noteData.inputIndex
	endNoteData.noteType = "LongNoteEnd"

	endNoteData.startNoteData = noteData
	noteData.endNoteData = endNoteData

	self.noteDataLayers[noteData]:addNoteData(endNoteData)
end

FullLongNote.cleanTimePointList = function(self, timePointList, nNoteData)
	local out = {}
	out[#out + 1] = timePointList[1]

	for i = 2, #timePointList do
		if timePointList[i].absoluteTime - out[#out].absoluteTime >= 0.005 then
			out[#out + 1] = timePointList[i]
		end
	end

	if nNoteData and nNoteData.timePoint.absoluteTime - out[#out].absoluteTime < 0.005 then
		out[#out] = nNoteData.timePoint
	end

	return out
end

return FullLongNote
