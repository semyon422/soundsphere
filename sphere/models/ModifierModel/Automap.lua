local aquamath				= require("aqua.math")
local Upscaler				= require("libchart.Upscaler")
local NextUpscaler			= require("libchart.NextUpscaler")
local Reductor				= require("libchart.Reductor")
local BlockFinder			= require("libchart.BlockFinder")
local NotePreprocessor		= require("libchart.NotePreprocessor")
local Modifier				= require("sphere.models.ModifierModel.Modifier")
local AutomapOldConfig		= require("sphere.models.ModifierModel.AutomapOldConfig")

local Automap = Modifier:new()

Automap.type = "NoteChartModifier"
Automap.interfaceType = "slider"

Automap.name = "Automap"

Automap.defaultValue = 10
Automap.range = {1, 26}

Automap.description = "anyK to anyK conversion"

Automap.getString = function(self, config)
	return "AM"
end

Automap.getSubString = function(self, config)
	return config.value
end

Automap.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart
	self.noteChart = noteChart

	self.old = config.old
	self.targetMode = config.value
	self.columnCount = math.floor(self.noteChart.inputMode:getInputCount("key"))

	if self.targetMode == self.columnCount or self.columnCount == 0 then
		return
	end

	self:applyAutomap()
	if self.targetMode < self.columnCount then
		self:processReductor()
	elseif self.targetMode > self.columnCount then
		self:processUpscaler()
	end

	noteChart:compute()
end

Automap.applyAutomap = function(self)
	local noteChart = self.game.noteChartModel.noteChart
	self.noteChart = noteChart

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
		if noteData.noteType == "LongNoteStart" and noteData.endNoteData then
			tNoteData.endTime = aquamath.round(noteData.endNoteData.timePoint.absoluteTime * 1000)
			tNoteData.long = true
		else
			tNoteData.endTime = tNoteData.startTime
		end
		tNoteData.baseEndTime = tNoteData.endTime
		tNoteData.columnIndex = noteData.inputIndex
		tNoteData.baseColumnIndex = noteData.inputIndex

		tNoteDatas[i] = tNoteData
	end

	noteChart.layerDataSequence.inputCount["key"] = {}
end

Automap.processUpscaler = function(self)
	local layerDataSequence = self.noteChart.layerDataSequence

	local targetMode = self.targetMode
	local columnCount = self.columnCount

	NotePreprocessor.columnCount = columnCount
	NotePreprocessor:process(self.tNoteDatas)

	local bf = BlockFinder:new()
	bf.noteData = self.tNoteDatas
	bf.columnCount = columnCount
	bf:process()

	self.nbs = bf:getNoteBlocks()

	NotePreprocessor:process(self.nbs)

	local notes
	if self.old then
		notes = self:getOldUpscalerNotes()
	else
		notes = self:getUpscalerNotes()
	end

	for i = 1, #notes do
		local tNoteData = notes[i]
		tNoteData.noteData.inputIndex = tNoteData.columnIndex
		layerDataSequence:increaseInputCount(tNoteData.noteData.inputType, tNoteData.noteData.inputIndex, 1)
		if tNoteData.long then
			tNoteData.noteData.endNoteData.inputIndex = tNoteData.columnIndex
			layerDataSequence:increaseInputCount(tNoteData.noteData.inputType, tNoteData.noteData.endNoteData.inputIndex, 1)
		end
	end

	self.noteChart.inputMode:setInputCount("key", targetMode)
end

Automap.getOldUpscalerNotes = function(self)
	local am = Upscaler:new()
	am.columns = AutomapOldConfig[self.targetMode][self.columnCount]
	am:load(self.targetMode)
	local notes, blocks = am:process(self.nbs)

	return notes
end

Automap.getUpscalerNotes = function(self)
	local am = NextUpscaler:new()
	am.targetMode = self.targetMode
	am.columnCount = self.columnCount
	am.notes = self.nbs
	am:process()

	local columns = {}
	local notes = {}
	for _, noteBlock in ipairs(self.nbs) do
		for _, note in ipairs(noteBlock:getNotes()) do
			notes[#notes + 1] = note
			columns[noteBlock.columnIndex] = (columns[noteBlock.columnIndex] or 0) + 1
		end
	end

	return notes
end

Automap.processReductor = function(self)
	local layerDataSequence = self.noteChart.layerDataSequence

	local targetMode = self.targetMode
	local columnCount = self.columnCount

	local tNoteDatasMap = {}
	for _, tNoteData in ipairs(self.tNoteDatas) do
		tNoteData.endTime = tNoteData.startTime
		tNoteDatasMap[tNoteData] = true
	end

	NotePreprocessor.columnCount = columnCount
	NotePreprocessor:process(self.tNoteDatas)

	local reductor = Reductor:new()
	local notes = reductor:process(self.tNoteDatas, columnCount, targetMode)

	if self.noteChart:requireLayerData(1).timeData.mode == "measure" then
		for _, tNoteData in ipairs(self.tNoteDatas) do
			tNoteData.endTime = tNoteData.startTime
		end
	end

	for i = 1, #notes do
		local tNoteData = notes[i]
		tNoteDatasMap[tNoteData] = nil
		tNoteData.noteData.inputIndex = tNoteData.columnIndex
		layerDataSequence:increaseInputCount(tNoteData.noteData.inputType, tNoteData.noteData.inputIndex, 1)
		if tNoteData.long and tNoteData.startTime == tNoteData.endTime then
			tNoteData.noteData.noteType = "ShortNote"
			tNoteData.noteData.endNoteData.noteType = "Ignore"
		end
		if tNoteData.long and tNoteData.startTime ~= tNoteData.endTime then
			tNoteData.noteData.endNoteData.inputIndex = tNoteData.columnIndex
			layerDataSequence:increaseInputCount(tNoteData.noteData.inputType, tNoteData.noteData.endNoteData.inputIndex, 1)
			local timePoint = self.noteChart:requireLayerData(1):getTimePoint(
				tNoteData.endTime / 1000,
				tNoteData.noteData.endNoteData.timePoint.side
			)
			tNoteData.noteData.endNoteData.timePoint = timePoint
		end
	end

	for tNoteData in pairs(tNoteDatasMap) do
		local noteData = tNoteData.noteData

		noteData.noteType = "SoundNote"
		noteData.inputType = "auto"
		noteData.inputIndex = 0
		layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)

		if tNoteData.long then
			tNoteData.noteData.endNoteData.noteType = "Ignore"
		end
	end

	self.noteChart.inputMode:setInputCount("key", targetMode)
end

return Automap
