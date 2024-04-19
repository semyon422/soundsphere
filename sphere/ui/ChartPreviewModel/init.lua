local class = require("class")
local NoteChartFactory = require("notechart.NoteChartFactory")
local GraphicEngine = require("sphere.models.RhythmModel.GraphicEngine")
local NoteChartExporter = require("sph.NoteChartExporter")
local NoteChartImporter = require("sph.NoteChartImporter")
local SphPreview = require("sph.SphPreview")

local ConvertAbsoluteToInterval = require("sphere.models.EditorModel.ConvertAbsoluteToInterval")
local ConvertMeasureToInterval = require("sphere.models.EditorModel.ConvertMeasureToInterval")
local NoteChart = require("ncdk.NoteChart")

local function to_interval(noteChart)
	local ld = noteChart:getLayerData(1)

	if ld.mode == "absolute" then
		ld = ConvertAbsoluteToInterval(ld)
	elseif ld.mode == "measure" then
		ld = ConvertMeasureToInterval(ld)
	end

	local nc = NoteChart()
	ld.noteChart = nc
	nc.layerDatas[1] = ld
	nc.chartmeta = noteChart.chartmeta
	nc.inputMode = noteChart.inputMode
	return nc
end

---@class sphere.ChartPreviewModel
---@operator call: sphere.ChartPreviewModel
local ChartPreviewModel = class()

---@param configModel sphere.ConfigModel
---@param previewModel sphere.PreviewModel
---@param game table
function ChartPreviewModel:new(configModel, previewModel, game)
	self.configModel = configModel
	self.previewModel = previewModel
	self.game = game
	self.notes = {}
	self.visualTimeInfo = {
		time = 0,
		rate = 0,
	}
	self.graphicEngine = GraphicEngine(self.visualTimeInfo)
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
	noteChart = to_interval(noteChart)

	local exp = NoteChartExporter()
	exp.noteChart = noteChart
	local sph_chart = exp:export()

	local sph_preview = SphPreview:encodeSphLines(exp.sph.sphLines, 1)
	exp.sph.sphLines = SphPreview:decodeSphLines(sph_preview, noteChart.inputMode:getColumns())

	local imp = NoteChartImporter()
	imp:importFromSph(exp.sph)
	noteChart = imp.noteCharts[1]

	local noteSkin = self.game.noteSkinModel:loadNoteSkin(tostring(noteChart.inputMode))
	noteSkin:loadData()
	noteSkin.editor = true

	local config = self.configModel.configs.settings
	self.graphicEngine.visualTimeRate = config.gameplay.speed
	self.graphicEngine.targetVisualTimeRate = config.gameplay.speed
	self.graphicEngine.scaleSpeed = config.gameplay.scaleSpeed

	self.graphicEngine.range = noteSkin.range
	self.graphicEngine:setNoteChart(noteChart)
	self.graphicEngine:load()
end

function ChartPreviewModel:update()
	self.visualTimeInfo.time = self.previewModel:getTime()
	self.visualTimeInfo.rate = self.previewModel.rate
	if not self.graphicEngine.noteDrawers then
		return
	end
	self.graphicEngine:update()
end

return ChartPreviewModel
