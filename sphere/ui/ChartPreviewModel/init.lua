local class = require("class")
local GraphicEngine = require("sphere.models.RhythmModel.GraphicEngine")
local ChartDecoder = require("sph.ChartDecoder")
local SphPreview = require("sph.SphPreview")
local Sph = require("sph.Sph")
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
	self.audio_offset = 0
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
	if not self.configModel.configs.settings.select.chart_preview then
		self.graphicEngine:unload()
		return
	end

	if not chartview or not chartview.chartdiff_inputmode then
		self.graphicEngine:unload()
		return
	end

	local notes_preview = chartview.notes_preview

	local lines = empty_lines
	if notes_preview and notes_preview ~= "" then
		lines = SphPreview:decodeLines(notes_preview)  -- slow
	end

	local sph = Sph()
	sph.metadata:set("title", "")
	sph.metadata:set("artist", "")
	sph.metadata:set("input", assert(chartview.chartdiff_inputmode))
	sph.sphLines:decode(lines)

	local decoder = ChartDecoder()

	local ok, chart = pcall(decoder.decodeSph, decoder, sph)  -- slow
	if not ok then
		self.graphicEngine:unload()
		return
	end

	local noteSkin = self:getNoteSkin(tostring(chart.inputMode))
	self.playField = noteSkin.playField
	self.noteSkin = noteSkin
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

	self.audio_offset = chartview.audio_offset or 0
end

function ChartPreviewModel:update()
	self.visualTimeInfo.time = self.previewModel:getTime() + self.audio_offset
	self.visualTimeInfo.rate = self.previewModel.rate
	self.graphicEngine:update()
end

return ChartPreviewModel
