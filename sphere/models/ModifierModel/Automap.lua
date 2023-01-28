local math_util				= require("math_util")
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

Automap.applyMeta = function(self, config, state)
	local columnCount = state.inputMode.key
	if not columnCount or config.value == columnCount then
		return
	end

	state.inputMode.key = config.value
end

Automap.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart
	self.noteChart = noteChart

	self.old = config.old
	self.targetMode = config.value
	self.columnCount = self.noteChart.inputMode.key

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

	local tNoteDatas = {}
	self.tNoteDatas = tNoteDatas

	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if inputType == "key" and (noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart") then
				local n = {}

				n.noteData = noteData
				n.layerDataIndex = layerDataIndex

				n.startTime = math_util.round(noteData.timePoint.absoluteTime * 1000)
				if noteData.noteType == "LongNoteStart" and noteData.endNoteData then
					n.endTime = math_util.round(noteData.endNoteData.timePoint.absoluteTime * 1000)
					n.long = true
				else
					n.endTime = n.startTime
				end
				n.baseEndTime = n.endTime
				n.columnIndex = inputIndex
				n.baseColumnIndex = inputIndex

				tNoteDatas[#tNoteDatas + 1] = n
			end
		end
	end

	table.sort(tNoteDatas, function(noteData1, noteData2)
		return noteData1.startTime < noteData2.startTime
	end)

	for _, layerData in noteChart:getLayerDataIterator() do
		layerData.noteDatas.key = {}
	end
end

Automap.processUpscaler = function(self)
	local noteChart = self.noteChart

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
		local n = notes[i]

		local key = noteChart.layerDatas[n.layerDataIndex].noteDatas.key
		key[n.columnIndex] = key[n.columnIndex] or {}
		table.insert(key[n.columnIndex], n.noteData)
		if n.long then
			table.insert(key[n.columnIndex], n.noteData.endNoteData)
		end
	end

	self.noteChart.inputMode.key = targetMode
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
	local noteChart = self.noteChart

	local targetMode = self.targetMode
	local columnCount = self.columnCount

	local tNoteDatasMap = {}
	for _, tNoteData in ipairs(self.tNoteDatas) do
		tNoteDatasMap[tNoteData] = true
	end

	NotePreprocessor.columnCount = columnCount
	NotePreprocessor:process(self.tNoteDatas)

	local reductor = Reductor:new()
	local notes = reductor:process(self.tNoteDatas, columnCount, targetMode)

	for i = 1, #notes do
		local n = notes[i]
		tNoteDatasMap[n] = nil

		local layerData = noteChart.layerDatas[n.layerDataIndex]
		layerData:addNoteData(n.noteData, "key", n.columnIndex)

		if n.long then
			if n.startTime == n.endTime then
				n.noteData.noteType = "ShortNote"
				-- n.noteData.endNoteData.noteType = "Ignore"
			else
				layerData:addNoteData(n.noteData.endNoteData, "key", n.columnIndex)
				n.noteData.endNoteData.timePoint = layerData:getTimePoint(
					n.endTime / 1000,
					n.noteData.endNoteData.timePoint.side
				)
			end
		end
	end

	for n in pairs(tNoteDatasMap) do
		local noteData = n.noteData
		noteData.noteType = "SoundNote"

		local layerData = noteChart.layerDatas[n.layerDataIndex]
		layerData:addNoteData(n.noteData, "auto", 0)

		-- if n.long then
		-- 	n.noteData.endNoteData.noteType = "Ignore"
		-- end
	end

	self.noteChart.inputMode.key = targetMode
end

return Automap
