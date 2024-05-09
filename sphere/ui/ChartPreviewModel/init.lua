local class = require("class")
local ChartFactory = require("notechart.ChartFactory")
local GraphicEngine = require("sphere.models.RhythmModel.GraphicEngine")
local ChartEncoder = require("sph.ChartEncoder")
local ChartDecoder = require("sph.ChartDecoder")
local SphPreview = require("sph.SphPreview")
local SphLines = require("sph.SphLines")
local TextLines = require("sph.lines.TextLines")
local LinesCleaner = require("sph.lines.LinesCleaner")
local stbl = require("stbl")

local ConvertAbsoluteToInterval = require("sphere.models.EditorModel.ConvertAbsoluteToInterval")
local ConvertMeasureToInterval = require("sphere.models.EditorModel.ConvertMeasureToInterval")
local NoteChart = require("ncdk.NoteChart")

---@param chart ncdk2.Chart
local function to_interval(chart)
	local layer = chart.layers.main

	-- if layer.mode == "absolute" then
	-- 	layer = ConvertAbsoluteToInterval(layer, "closest_gte")
	-- elseif layer.mode == "measure" then
	-- 	layer = ConvertMeasureToInterval(layer)
	-- end

	-- local nc = NoteChart()
	-- layer.noteChart = nc
	-- nc.layerDatas[1] = layer
	-- nc.chartmeta = chart.chartmeta
	-- nc.inputMode = chart.inputMode
	-- return nc
	return chart
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

	local charts = assert(ChartFactory:getCharts(
		chartview.chartfile_name,
		content
	))
	local chart = charts[chartview.index]

	-- chart = to_interval(chart)

	local encoder = ChartEncoder()
	local sph = encoder:encodeSph(charts[1])

	-- local tl = TextLines()
	-- tl.lines = encoder.sph.sphLines:encode()
	-- tl.columns = noteChart.inputMode:getColumns()
	-- local sph_lines_str = tl:encode()

	local sph_preview = SphPreview:encodeLines(LinesCleaner:clean(sph.sphLines:encode()), 1)
	sph.sphLines = SphLines()
	sph.sphLines:decode(SphPreview:decodeLines(sph_preview))

	-- local tl = TextLines()
	-- tl.lines = encoder.sph.sphLines:encode()
	-- tl.columns = noteChart.inputMode:getColumns()
	-- local sph_lines_str2 = tl:encode()

	local decoder = ChartDecoder()
	chart = decoder:decodeSph(sph)

	-- local f = assert(io.open("sph_preview.bin", "wb"))
	-- f:write(sph_preview)
	-- f:close()
	-- local f = assert(io.open("sph_lines_str.sph", "w"))
	-- f:write(sph_lines_str)
	-- f:close()
	-- f = assert(io.open("sph_lines_str2.sph", "w"))
	-- f:write(sph_lines_str2)
	-- f:close()

	local noteSkin = self.game.noteSkinModel:loadNoteSkin(tostring(chart.inputMode))
	noteSkin:loadData()
	noteSkin.editor = true

	local config = self.configModel.configs.settings
	self.graphicEngine.visualTimeRate = config.gameplay.speed
	self.graphicEngine.targetVisualTimeRate = config.gameplay.speed
	self.graphicEngine.scaleSpeed = config.gameplay.scaleSpeed

	self.graphicEngine.range = noteSkin.range
	self.graphicEngine:setChart(chart)
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
