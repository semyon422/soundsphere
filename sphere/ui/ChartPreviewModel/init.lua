local class = require("class")
local InputMode = require("ncdk.InputMode")
local ChartFactory = require("notechart.ChartFactory")
local GraphicEngine = require("sphere.models.RhythmModel.GraphicEngine")
local ChartEncoder = require("sph.ChartEncoder")
local ChartDecoder = require("sph.ChartDecoder")
local SphPreview = require("sph.SphPreview")
local SphLines = require("sph.SphLines")
local Sph = require("sph.Sph")
local TextLines = require("sph.lines.TextLines")
local BaseSkinInfo = require("sphere.models.NoteSkinModel.BaseSkinInfo")


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
	self.skinInfo = BaseSkinInfo()

	self.skin_by_mode = {}
	-- self.graphicEngine.eventBasedRender = true
end

---@param inputMode string
function ChartPreviewModel:getNoteSkin(inputMode)
	local skin_by_mode = self.skin_by_mode
	local noteSkin = skin_by_mode[inputMode]
	if noteSkin then
		return noteSkin
	end
	noteSkin = self.skinInfo:loadSkin(inputMode)
	noteSkin:loadData()
	skin_by_mode[inputMode] = noteSkin
	return noteSkin
end

local empty_lines = SphPreview:previewLinesToLines({
	{offset = 0},
	{offset = 1},
})

function ChartPreviewModel:setChartview(chartview)
	if not chartview then
		return
	end

	local content = love.filesystem.read(chartview.location_path)
	if not content then
		return
	end

	local notes_preview = chartview.notes_preview

	local lines = empty_lines
	if notes_preview then
		lines = SphPreview:decodeLines(notes_preview)
	end


	-- local charts = assert(ChartFactory:getCharts(
	-- 	chartview.chartfile_name,
	-- 	content
	-- ))
	-- local chart = charts[chartview.index]
	-- to_interval(chart)

	-- assert(IntervalLayer * chart.layers.main)

	-- local encoder = ChartEncoder()
	-- local sph = encoder:encodeSph(chart)

	-- local tl = TextLines()
	-- tl.lines = sph.sphLines:encode()
	-- tl.columns = chart.inputMode:getColumns()
	-- local sph_lines_str = tl:encode()
	-- print(sph_lines_str)

	-- print("size", #sph_lines_str)

	-- local sph_preview = SphPreview:encodeLines(LinesCleaner:clean(sph.sphLines:encode()), 1)
	-- sph.sphLines = SphLines()

	local sph = Sph()
	sph.metadata.input = assert(chartview.chartdiff_inputmode)
	sph.sphLines:decode(lines)

	-- local tl = TextLines()
	-- tl.lines = encoder.sph.sphLines:encode()
	-- tl.columns = noteChart.inputMode:getColumns()
	-- local sph_lines_str2 = tl:encode()

	local decoder = ChartDecoder()
	local chart = decoder:decodeSph(sph)

	-- local f = assert(io.open("sph_preview.bin", "wb"))
	-- f:write(sph_preview)
	-- f:close()
	-- local f = assert(io.open("sph_lines_str.sph", "w"))
	-- f:write(sph_lines_str)
	-- f:close()
	-- f = assert(io.open("sph_lines_str2.sph", "w"))
	-- f:write(sph_lines_str2)
	-- f:close()

	local noteSkin = self:getNoteSkin(tostring(chart.inputMode))
	self.playField = noteSkin.playField
	self.game.noteSkinModel.noteSkin = noteSkin
	-- local noteSkin = self.game.noteSkinModel:loadNoteSkin(tostring(chart.inputMode))
	-- noteSkin:loadData()
	-- noteSkin.editor = true

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
	self.graphicEngine:update()
end

return ChartPreviewModel
