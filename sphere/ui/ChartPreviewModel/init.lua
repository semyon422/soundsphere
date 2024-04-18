local class = require("class")
local NoteChartFactory = require("notechart.NoteChartFactory")
local ShortGraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.ShortGraphicalNote")
local PreviewGraphicEngine = require("sphere.ui.ChartPreviewModel.PreviewGraphicEngine")

---@class sphere.ChartPreviewModel
---@operator call: sphere.ChartPreviewModel
local ChartPreviewModel = class()

---@param configModel sphere.ConfigModel
---@param previewModel sphere.PreviewModel
---@param game table
function ChartPreviewModel:new(configModel, previewModel, game)
	self.configModel = configModel
	self.game = game
	self.notes = {}
	self.previewGraphicEngine = PreviewGraphicEngine(previewModel)
end

function ChartPreviewModel:setChartview(chartview)
	print(chartview.real_path)

	local content = love.filesystem.read(chartview.location_path)
	if not content then
		return
	end

	local noteChart = assert(NoteChartFactory:getNoteChart(
		chartview.chartfile_name,
		content,
		chartview.index
	))

	local noteSkin = self.game.noteSkinModel:loadNoteSkin(tostring(noteChart.inputMode))
	noteSkin:loadData()
	noteSkin.editor = true

	local notes = {}

	local ctp = noteChart.layerDatas[1]:newTimePoint()
	ctp.absoluteTime = 0

	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			local input = inputType .. inputIndex
			local t = noteData.noteType
			if t == "ShortNote" or t == "LongNoteStart" or t == "LaserNoteStart" then
				local note = ShortGraphicalNote("ShortNote", noteData)
				note.currentTimePoint = ctp
				note.graphicEngine = self.previewGraphicEngine
				-- note.layerData = layerData
				-- note.logicalNote = logicEngine:getLogicalNote(noteData)
				note.inputType = inputType
				note.inputIndex = inputIndex
				note:update()
				table.insert(notes, note)
			end
		end
	end

	self.notes = notes
end

function ChartPreviewModel:update()
	for _, note in ipairs(self.notes) do
		note:update()
	end
end

return ChartPreviewModel
