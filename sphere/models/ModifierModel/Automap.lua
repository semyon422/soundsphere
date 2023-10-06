local math_util = require("math_util")
local Upscaler = require("libchart.Upscaler")
local NextUpscaler = require("libchart.NextUpscaler")
local Reductor = require("libchart.Reductor")
local BlockFinder = require("libchart.BlockFinder")
local NotePreprocessor = require("libchart.NotePreprocessor")
local Modifier = require("sphere.models.ModifierModel.Modifier")
local AutomapOldConfig = require("sphere.models.ModifierModel.AutomapOldConfig")

---@class sphere.Automap: sphere.Modifier
---@operator call: sphere.Automap
local Automap = Modifier + {}

Automap.interfaceType = "slider"

Automap.name = "Automap"

Automap.defaultValue = 10
Automap.range = {1, 26}

Automap.description = "anyK to anyK conversion"

---@param config table
---@return string
---@return string
function Automap:getString(config)
	return "AM", tostring(config.value)
end

---@param config table
---@param state table
function Automap:applyMeta(config, state)
	local columnCount = state.inputMode.key
	if not columnCount or config.value == columnCount then
		return
	end

	state.inputMode.key = config.value
end

---@param config table
function Automap:apply(config)
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

	self.noteChart:compute()
end

function Automap:applyAutomap()
	local tNoteDatas = {}
	self.tNoteDatas = tNoteDatas

	for noteDatas, inputType, inputIndex, layerDataIndex in self.noteChart:getInputIterator() do
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

	for _, layerData in self.noteChart:getLayerDataIterator() do
		layerData.noteDatas.key = {}
	end
end

function Automap:processUpscaler()
	local noteChart = self.noteChart

	local targetMode = self.targetMode
	local columnCount = self.columnCount

	NotePreprocessor.columnCount = columnCount
	NotePreprocessor:process(self.tNoteDatas)

	local bf = BlockFinder()
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

---@return table
function Automap:getOldUpscalerNotes()
	local am = Upscaler()
	am.columns = AutomapOldConfig[self.targetMode][self.columnCount]
	am:load(self.targetMode)
	local notes, blocks = am:process(self.nbs)

	return notes
end

---@return table
function Automap:getUpscalerNotes()
	local am = NextUpscaler()
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

function Automap:processReductor()
	local noteChart = self.noteChart

	local targetMode = self.targetMode
	local columnCount = self.columnCount

	local tNoteDatasMap = {}
	for _, tNoteData in ipairs(self.tNoteDatas) do
		tNoteData.endTime = tNoteData.startTime
		tNoteDatasMap[tNoteData] = true
	end

	NotePreprocessor.columnCount = columnCount
	NotePreprocessor:process(self.tNoteDatas)

	local reductor = Reductor()
	local notes = reductor:process(self.tNoteDatas, columnCount, targetMode)

	-- currently Automap only absolute time mode
	-- reducting long notes requires creating new time points
	-- time point interpolating is not fully inplemented in LayerData
	if self.noteChart:getLayerData(1).mode ~= "absolute" then
		for _, tNoteData in ipairs(self.tNoteDatas) do
			tNoteData.endTime = tNoteData.startTime
		end
	end

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
