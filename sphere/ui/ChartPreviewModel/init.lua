local class = require("class")
local NoteChartFactory = require("notechart.NoteChartFactory")
local GraphicEngine = require("sphere.models.RhythmModel.GraphicEngine")
local NoteChartExporter = require("sph.NoteChartExporter")
local NoteChartImporter = require("sph.NoteChartImporter")
local SphPreview = require("sph.SphPreview")
local SphLines = require("sph.SphLines")
local TextLines = require("sph.lines.TextLines")
local LinesCleaner = require("sph.lines.LinesCleaner")
local stbl = require("stbl")

local ConvertAbsoluteToInterval = require("sphere.models.EditorModel.ConvertAbsoluteToInterval")
local ConvertMeasureToInterval = require("sphere.models.EditorModel.ConvertMeasureToInterval")
local NoteChart = require("ncdk.NoteChart")

local function to_interval(noteChart)
	local ld = noteChart:getLayerData(1)

	if ld.mode == "absolute" then
		ld = ConvertAbsoluteToInterval(ld, "closest_gte")
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

	local tl = TextLines()
	tl.lines = exp.sph.sphLines:encode()
	tl.columns = noteChart.inputMode:getColumns()
	local sph_lines_str = tl:encode()

	local sph_preview = SphPreview:encodeLines(LinesCleaner:clean(exp.sph.sphLines:encode()), 1)
	exp.sph.sphLines = SphLines()
	exp.sph.sphLines:decode(SphPreview:decodeLines(sph_preview))

	local tl = TextLines()
	tl.lines = exp.sph.sphLines:encode()
	tl.columns = noteChart.inputMode:getColumns()
	local sph_lines_str2 = tl:encode()

	local imp = NoteChartImporter()
	imp:importFromSph(exp.sph)
	noteChart = imp.noteCharts[1]

	local f = assert(io.open("sph_preview.bin", "wb"))
	f:write(sph_preview)
	f:close()
	local f = assert(io.open("sph_lines_str.sph", "w"))
	f:write(sph_lines_str)
	f:close()
	f = assert(io.open("sph_lines_str2.sph", "w"))
	f:write(sph_lines_str2)
	f:close()

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
