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
local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local MeasureLayer = require("ncdk2.layers.MeasureLayer")
local AbsoluteInterval = require("ncdk2.convert.AbsoluteInterval")
local MeasureInterval = require("ncdk2.convert.MeasureInterval")

---@param chart ncdk2.Chart
local function to_interval(chart)
	local layer = chart.layers.main

	if AbsoluteLayer * layer then
		local conv = AbsoluteInterval({1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 16}, 0.002)
		conv:convert(layer, "closest_gte")
	elseif MeasureLayer * layer then
		local conv = MeasureInterval()
		conv:convert(layer)
	end
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
	-- self.graphicEngine.eventBasedRender = true
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
	to_interval(chart)

	assert(IntervalLayer * chart.layers.main)

	local encoder = ChartEncoder()
	local sph = encoder:encodeSph(chart)

	-- local tl = TextLines()
	-- tl.lines = sph.sphLines:encode()
	-- tl.columns = chart.inputMode:getColumns()
	-- local sph_lines_str = tl:encode()
	-- print(sph_lines_str)

	-- print("size", #sph_lines_str)

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
