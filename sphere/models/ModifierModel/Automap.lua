local aquamath				= require("aqua.math")
local clone					= require("aqua.table").clone
local Upscaler				= require("libchart.Upscaler")
local NoteBlock				= require("libchart.NoteBlock")
local BlockFinder			= require("libchart.BlockFinder")
local NotePreprocessor		= require("libchart.NotePreprocessor")
local NoteData				= require("ncdk.NoteData")
local Modifier				= require("sphere.models.ModifierModel.Modifier")

local config = {}

config[5] = {}

config[5][4] = {
	{1,1,0,0,0},
	{0,1,1,0,0},
	{0,0,1,1,0},
	{0,0,0,1,1},
}

config[6] = {}

config[6][4] = {
	{1,1,0,0,0,0},
	{0,1,1,0,0,0},
	{0,0,0,1,1,0},
	{0,0,0,0,1,1},
}

config[6][5] = {
	{1,1,0,0,0,0},
	{0,1,1,0,0,0},
	{0,0,1,1,0,0},
	{0,0,0,1,1,0},
	{0,0,0,0,1,1},
}

config[7] = {}

config[7][4] = {
	{1,1,0,0,0,0,0},
	{0,1,1,1,0,0,0},
	{0,0,0,1,1,1,0},
	{0,0,0,0,0,1,1},
}

config[7][5] = {
	{1,1,0,0,0,0,0},
	{0,1,1,0,0,0,0},
	{0,0,1,1,1,0,0},
	{0,0,0,0,1,1,0},
	{0,0,0,0,0,1,1},
}

config[7][6] = {
	{1,1,0,0,0,0,0},
	{0,1,1,0,0,0,0},
	{0,0,1,1,0,0,0},
	{0,0,0,1,1,0,0},
	{0,0,0,0,1,1,0},
	{0,0,0,0,0,1,1},
}

config[8] = {}

config[8][4] = {
	{1,1,0,0,0,0,0,0},
	{0,0,1,1,0,0,0,0},
	{0,0,0,0,1,1,0,0},
	{0,0,0,0,0,0,1,1},
}

config[8][5] = {
	{1,1,0,0,0,0,0,0},
	{0,1,1,1,0,0,0,0},
	{0,0,0,1,1,0,0,0},
	{0,0,0,0,1,1,1,0},
	{0,0,0,0,0,0,1,1},
}

config[8][6] = {
	{1,1,0,0,0,0,0,0},
	{0,1,1,0,0,0,0,0},
	{0,0,1,1,0,0,0,0},
	{0,0,0,0,1,1,0,0},
	{0,0,0,0,0,1,1,0},
	{0,0,0,0,0,0,1,1},
}

config[8][7] = {
	{1,1,0,0,0,0,0,0},
	{0,1,1,0,0,0,0,0},
	{0,0,1,1,0,0,0,0},
	{0,0,0,1,1,0,0,0},
	{0,0,0,0,1,1,0,0},
	{0,0,0,0,0,1,1,0},
	{0,0,0,0,0,0,1,1},
}

config[9] = {}

config[9][4] = {
	{1,1,1,0,0,0,0,0,0},
	{0,0,1,1,1,0,0,0,0},
	{0,0,0,0,1,1,1,0,0},
	{0,0,0,0,0,0,1,1,1},
}

config[9][5] = {
	{1,1,0,0,0,0,0,0,0},
	{0,1,1,1,0,0,0,0,0},
	{0,0,0,1,1,1,0,0,0},
	{0,0,0,0,0,1,1,1,0},
	{0,0,0,0,0,0,0,1,1},
}

config[9][6] = {
	{1,1,0,0,0,0,0,0,0},
	{0,1,1,1,0,0,0,0,0},
	{0,0,0,1,1,0,0,0,0},
	{0,0,0,0,1,1,0,0,0},
	{0,0,0,0,0,1,1,1,0},
	{0,0,0,0,0,0,0,1,1},
}

config[9][7] = {
	{1,1,0,0,0,0,0,0,0},
	{0,1,1,0,0,0,0,0,0},
	{0,0,1,1,0,0,0,0,0},
	{0,0,0,1,1,1,0,0,0},
	{0,0,0,0,0,1,1,0,0},
	{0,0,0,0,0,0,1,1,0},
	{0,0,0,0,0,0,0,1,1},
}

config[9][8] = {
	{1,1,0,0,0,0,0,0,0},
	{0,1,1,0,0,0,0,0,0},
	{0,0,1,1,0,0,0,0,0},
	{0,0,0,1,1,0,0,0,0},
	{0,0,0,0,1,1,0,0,0},
	{0,0,0,0,0,1,1,0,0},
	{0,0,0,0,0,0,1,1,0},
	{0,0,0,0,0,0,0,1,1},
}

config[10] = {}

config[10][4] = {
	{1,1,1,0,0,0,0,0,0,0},
	{0,0,1,1,1,0,0,0,0,0},
	{0,0,0,0,0,1,1,1,0,0},
	{0,0,0,0,0,0,0,1,1,1},
}

config[10][5] = {
	{1,1,0,0,0,0,0,0,0,0},
	{0,0,1,1,0,0,0,0,0,0},
	{0,0,0,0,1,1,0,0,0,0},
	{0,0,0,0,0,0,1,1,0,0},
	{0,0,0,0,0,0,0,0,1,1},
}

config[10][6] = {
	{1,1,0,0,0,0,0,0,0,0},
	{0,1,1,1,0,0,0,0,0,0},
	{0,0,0,1,1,0,0,0,0,0},
	{0,0,0,0,0,1,1,0,0,0},
	{0,0,0,0,0,0,1,1,1,0},
	{0,0,0,0,0,0,0,0,1,1},
}

config[10][7] = {
	{1,1,0,0,0,0,0,0,0,0},
	{0,1,1,1,0,0,0,0,0,0},
	{0,0,1,1,1,0,0,0,0,0},
	{0,0,0,0,1,1,0,0,0,0},
	{0,0,0,0,0,1,1,1,0,0},
	{0,0,0,0,0,0,1,1,1,0},
	{0,0,0,0,0,0,0,0,1,1},
}

config[10][8] = {
	{1,1,0,0,0,0,0,0,0,0},
	{0,1,1,0,0,0,0,0,0,0},
	{0,0,1,1,0,0,0,0,0,0},
	{0,0,0,1,1,0,0,0,0,0},
	{0,0,0,0,0,1,1,0,0,0},
	{0,0,0,0,0,0,1,1,0,0},
	{0,0,0,0,0,0,0,1,1,0},
	{0,0,0,0,0,0,0,0,1,1},
}

config[10][9] = {
	{1,1,0,0,0,0,0,0,0,0},
	{0,1,1,0,0,0,0,0,0,0},
	{0,0,1,1,0,0,0,0,0,0},
	{0,0,0,1,1,0,0,0,0,0},
	{0,0,0,0,1,1,0,0,0,0},
	{0,0,0,0,0,1,1,0,0,0},
	{0,0,0,0,0,0,1,1,0,0},
	{0,0,0,0,0,0,0,1,1,0},
	{0,0,0,0,0,0,0,0,1,1},
}

local Automap = Modifier:new()

Automap.sequential = true
Automap.type = "NoteChartModifier"

Automap.name = "Automap"
Automap.shortName = "AM"

Automap.variableType = "number"
Automap.variableName = "keys"
Automap.variableRange = {4, 1, 10}

Automap.keys = 10

Automap.construct = function(self)
	self.keys = Automap.keys
end

Automap.tostring = function(self)
	return self.shortName .. self.keys
end

Automap.tojson = function(self)
	return ([[{"name":"%s","keys":%s}]]):format(self.name, self.keys)
end

Automap.apply = function(self)
	local noteChart = self.model.noteChart
	self.noteChart = noteChart

	self.targetMode = self.keys
	self.columnCount = self.noteChart.inputMode:getInputCount("key")

	if self.targetMode <= self.columnCount or self.columnCount == 0 then
		return
	end

	local noteDatas = {}
	self.noteDatas = noteDatas
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			if
				(noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart") and
				noteData.inputType == "key"
			then
				noteDatas[#noteDatas + 1] = noteData
			end
		end
	end
	
	table.sort(noteDatas, function(noteData1, noteData2)
		return noteData1.timePoint < noteData2.timePoint
	end)
	
	local tNoteDatas = {}
	self.tNoteDatas = tNoteDatas
	for i = 1, #noteDatas do
		local noteData = noteDatas[i]
		local tNoteData = {}

		tNoteData.noteData = noteData

		tNoteData.startTime = aquamath.round(noteData.timePoint.absoluteTime * 1000)
		if noteData.endNoteData then
			tNoteData.endTime = aquamath.round(noteData.endNoteData.timePoint.absoluteTime * 1000)
			tNoteData.long = true
		else
			tNoteData.endTime = tNoteData.startTime
		end
		tNoteData.columnIndex = noteData.inputIndex
		tNoteData.baseColumnIndex = noteData.inputIndex

		tNoteDatas[i] = tNoteData
	end

	noteChart.layerDataSequence.inputCount["key"] = {}

	self:process()
	
	noteChart:compute()
end

Automap.process = function(self)
	local layerDataSequence = self.noteChart.layerDataSequence

	local targetMode = self.targetMode
	local columnCount = self.columnCount
	
	NotePreprocessor.columnCount = columnCount
	NotePreprocessor:process(self.tNoteDatas)

	local bf = BlockFinder:new()
	bf.noteData = self.tNoteDatas
	bf.columnCount = columnCount
	bf:process()

	local nbs = bf:getNoteBlocks()

	NotePreprocessor:process(nbs)

	local am = Upscaler:new()
	am.columns = config[targetMode][columnCount]
	am:load(targetMode)
	local notes, blocks = am:process(nbs)

	for i = 1, #notes do
		local tNoteData = notes[i]
		tNoteData.noteData.inputIndex = tNoteData.columnIndex
		layerDataSequence:increaseInputCount(tNoteData.noteData.inputType, tNoteData.noteData.inputIndex, 1)
		if tNoteData.long then
			tNoteData.noteData.endNoteData.inputIndex = tNoteData.columnIndex
		end
	end

	self.noteChart.inputMode:setInputCount("key", targetMode)
end

return Automap
