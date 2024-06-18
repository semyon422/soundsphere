local math_util = require("math_util")
local Upscaler = require("libchart.Upscaler")
local NextUpscaler = require("libchart.NextUpscaler")
local Reductor = require("libchart.Reductor")
local BlockFinder = require("libchart.BlockFinder")
local NotePreprocessor = require("libchart.NotePreprocessor")
local Modifier = require("sphere.models.ModifierModel.Modifier")
local AutomapOldConfig = require("sphere.models.ModifierModel.AutomapOldConfig")
local InputMode = require("ncdk.InputMode")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")

---@class sphere.Automap: sphere.Modifier
---@operator call: sphere.Automap
local Automap = Modifier + {}

Automap.name = "Automap"

Automap.defaultValue = 10
Automap.values = {}

for i = 1, 26 do
	table.insert(Automap.values, i)
end

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
---@param chart ncdk2.Chart
function Automap:apply(config, chart)
	self.old = config.old
	self.targetMode = config.value

	self.chart = chart
	self.columnCount = chart.inputMode.key

	if self.targetMode == self.columnCount or self.columnCount == 0 then
		return
	end

	self:applyAutomap()
	if self.targetMode < self.columnCount then
		self:processReductor()
	elseif self.targetMode > self.columnCount then
		self:processUpscaler()
	end

	chart:compute()
end

function Automap:applyAutomap()
	local tNoteDatas = {}
	self.tNoteDatas = tNoteDatas

	for notes, column, layer in self.chart:iterLayerNotes() do
		local inputType, inputIndex = InputMode:splitInput(column)
		for _, note in ipairs(notes) do
			if inputType == "key" and (note.noteType == "ShortNote" or note.noteType == "LongNoteStart") then
				local n = {}

				n.noteData = note
				n.layer = layer

				n.startTime = math_util.round(note.visualPoint.point.absoluteTime * 1000)
				if note.noteType == "LongNoteStart" and note.endNoteData then
					n.endTime = math_util.round(note.endNoteData.visualPoint.point.absoluteTime * 1000)
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

	for _, layer in pairs(self.chart.layers) do
		for column, notes in layer.notes:iter() do
			local inputType, inputIndex = InputMode:splitInput(column)
			if inputType == "key" then
				layer.notes.column_notes[column] = nil
			end
		end
	end
end

function Automap:processUpscaler()
	local chart = self.chart

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
		local layer = n.layer

		layer.notes:insert(n.noteData, "key" .. n.columnIndex)
		if n.long then
			layer.notes:insert(n.noteData.endNoteData, "key" .. n.columnIndex)
		end
	end

	self.chart.inputMode.key = targetMode
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
	local chart = self.chart

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
	if not (AbsoluteLayer * self.chart.layers.main) then
		for _, tNoteData in ipairs(self.tNoteDatas) do
			tNoteData.endTime = tNoteData.startTime
		end
	end

	for i = 1, #notes do
		local n = notes[i]
		tNoteDatasMap[n] = nil

		local layer = n.layer
		layer.notes:insert(n.noteData, "key" .. n.columnIndex)

		if n.long then
			if n.startTime == n.endTime then
				n.noteData.noteType = "ShortNote"
				-- n.noteData.endNoteData.noteType = "Ignore"
			else
				layer.notes:insert(n.noteData.endNoteData, "key" .. n.columnIndex)
				local p = layer:getPoint(n.endTime / 1000)
				local vp = layer.visual:getPoint(p)
				n.noteData.endNoteData.visualPoint = vp
			end
		end
	end

	for n in pairs(tNoteDatasMap) do
		local noteData = n.noteData
		noteData.noteType = "SoundNote"

		local layer = n.layer
		layer.notes:insert(n.noteData, "auto" .. n.columnIndex)

		-- if n.long then
		-- 	n.noteData.endNoteData.noteType = "Ignore"
		-- end
	end

	self.chart.inputMode.key = targetMode
end

return Automap
