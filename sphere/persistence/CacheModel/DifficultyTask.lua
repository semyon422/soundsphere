local class = require("class")
local ModifierModel = require("sphere.models.ModifierModel")
local SphPreview = require("sph.SphPreview")
local Sph = require("sph.Sph")
local ChartDecoder = require("sph.ChartDecoder")

---@class sphere.DifficultyTask
---@operator call: sphere.DifficultyTask
local DifficultyTask = class()

---@param difficultyModel sphere.DifficultyModel
---@param chartsRepo sea.ChartsRepo
---@param cacheManager sphere.CacheManager
function DifficultyTask:new(difficultyModel, chartsRepo, cacheManager)
	self.difficultyModel = difficultyModel
	self.chartsRepo = chartsRepo
	self.cacheManager = cacheManager
end

---@param hash string
---@return ncdk2.Chart[]?
---@return string?
function DifficultyTask:getChartsByHash(hash)
	return self.cacheManager:getChartsByHash(hash)
end

function DifficultyTask:computeMissing()
	local chartsRepo = self.chartsRepo

	local scores = chartsRepo:getChartplaysMissingChartdiffs()
	local chartmetas = chartsRepo:getChartmetasMissingChartdiffs()

	self.cacheManager.state = 2
	self.cacheManager.chartfiles_count = #chartmetas + #scores
	self.cacheManager.chartfiles_current = 0
	self.cacheManager:checkProgress()

	print("DifficultyTask: computing default chartdiffs")
	for i, chartmeta in ipairs(chartmetas) do
		local charts, err = self:getChartsByHash(chartmeta.hash)
		if not charts then
			print(err)
		else
			local chart = charts[chartmeta.index]

			local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
			if ok then
				local time = os.time()
				local chartdiff = self.cacheManager.chartdiffGenerator:compute(chart, 1)
				chartdiff.hash = chartmeta.hash
				chartdiff.index = chartmeta.index
				chartsRepo:createUpdateChartdiff(chartdiff, time)
			else
				print("toAbsolute", err)
			end
		end

		self.cacheManager.chartfiles_current = self.cacheManager.chartfiles_current + 1
		self.cacheManager:checkProgress()
		if self.cacheManager.needStop then break end
	end

	print("DifficultyTask: computing modified chartdiffs")
	for i, score in ipairs(scores) do
		local charts, err = self:getChartsByHash(score.hash)
		if not charts then
			print(err)
		else
			local chart = charts[score.index]
			local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
			if ok then
				ModifierModel:apply(score.modifiers, chart)

				local time = os.time()
				local chartdiff = self.cacheManager.chartdiffGenerator:compute(chart, score.rate)
				chartdiff.modifiers = score.modifiers
				chartdiff.hash = score.hash
				chartdiff.index = score.index

				chartsRepo:createUpdateChartdiff(chartdiff, time)
			else
				print("toAbsolute", err)
			end
		end

		self.cacheManager.chartfiles_current = self.cacheManager.chartfiles_current + 1
		self.cacheManager:checkProgress()
		if self.cacheManager.needStop then break end
	end
end

---@param prefer_preview boolean
function DifficultyTask:computeIncomplete(prefer_preview)
	local chartsRepo = self.chartsRepo

	local chartdiffs = chartsRepo:getIncompleteChartdiffs()
	print("DifficultyTask: processing incomplete", #chartdiffs)

	self.cacheManager.state = 2
	self.cacheManager.chartfiles_count = #chartdiffs
	self.cacheManager.chartfiles_current = 0

	for i, chartdiff in ipairs(chartdiffs) do
		---@type ncdk2.Chart
		local chart

		local preview = chartdiff.notes_preview
		if preview and prefer_preview then
			local lines = SphPreview:decodeLines(preview)

			local sph = Sph()
			sph.metadata.input = assert(chartdiff.inputmode)
			sph.sphLines:decode(lines)

			local decoder = ChartDecoder()
			chart = decoder:decodeSph(sph)
		else
			local charts, err = self:getChartsByHash(chartdiff.hash)
			if not charts then
				print(err)
			else
				chart = charts[chartdiff.index]
				local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
				if not ok then
					chart = nil
					print("toAbsolute", err)
				else
					ModifierModel:apply(chartdiff.modifiers, chart)
				end
			end
		end

		if chart then
			self.difficultyModel:compute(chartdiff, chart, chartdiff.rate)
			chartsRepo:updateChartdiff(chartdiff)
		end

		self.cacheManager.chartfiles_current = i
		self.cacheManager:checkProgress()
		if self.cacheManager.needStop then break end
	end
end

return DifficultyTask
