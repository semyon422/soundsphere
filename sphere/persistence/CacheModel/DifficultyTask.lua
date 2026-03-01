local class = require("class")
local ModifierModel = require("sphere.models.ModifierModel")
local SphPreview = require("sph.SphPreview")
local Sph = require("sph.Sph")
local ChartDecoder = require("sph.ChartDecoder")

---@class sphere.DifficultyTask
---@operator call: sphere.DifficultyTask
local DifficultyTask = class()

---@param difficultyModel sphere.DifficultyModel
---@param chartdiffGenerator sphere.ChartdiffGenerator
---@param chartsRepo sea.ChartsRepo
---@param getChartsByHash fun(hash: string): ncdk2.Chart[]?, string?
---@param checkProgress fun(state: integer, count: integer, current: integer)
---@param shouldStop fun(): boolean
function DifficultyTask:new(difficultyModel, chartdiffGenerator, chartsRepo, getChartsByHash, checkProgress, shouldStop)
	self.difficultyModel = difficultyModel
	self.chartdiffGenerator = chartdiffGenerator
	self.chartsRepo = chartsRepo
	self.getChartsByHash = getChartsByHash
	self.checkProgress = checkProgress
	self.shouldStop = shouldStop
end

function DifficultyTask:computeMissing()
	local chartsRepo = self.chartsRepo

	local scores = chartsRepo:getChartplaysMissingChartdiffs()
	local chartmetas = chartsRepo:getChartmetasMissingChartdiffs()

	local count = #chartmetas + #scores
	local current = 0
	self.checkProgress(2, count, current)

	print("DifficultyTask: computing default chartdiffs")
	for i, chartmeta in ipairs(chartmetas) do
		if self.shouldStop() then break end
		local charts, err = self.getChartsByHash(chartmeta.hash)
		if not charts then
			print(err)
		else
			local chart = charts[chartmeta.index]

			local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
			if ok then
				local time = os.time()
				local chartdiff = self.chartdiffGenerator:compute(chart, 1)
				chartdiff.hash = chartmeta.hash
				chartdiff.index = chartmeta.index
				chartsRepo:createUpdateChartdiff(chartdiff, time)
			else
				print("toAbsolute", err)
			end
		end

		current = current + 1
		self.checkProgress(2, count, current)
	end

	print("DifficultyTask: computing modified chartdiffs")
	for i, score in ipairs(scores) do
		if self.shouldStop() then break end
		local charts, err = self.getChartsByHash(score.hash)
		if not charts then
			print(err)
		else
			local chart = charts[score.index]
			local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
			if ok then
				ModifierModel:apply(score.modifiers, chart)

				local time = os.time()
				local chartdiff = self.chartdiffGenerator:compute(chart, score.rate)
				chartdiff.modifiers = score.modifiers
				chartdiff.hash = score.hash
				chartdiff.index = score.index

				chartsRepo:createUpdateChartdiff(chartdiff, time)
			else
				print("toAbsolute", err)
			end
		end

		current = current + 1
		self.checkProgress(2, count, current)
	end
end

---@param prefer_preview boolean
function DifficultyTask:computeIncomplete(prefer_preview)
	local chartsRepo = self.chartsRepo

	local chartdiffs = chartsRepo:getIncompleteChartdiffs()
	print("DifficultyTask: processing incomplete", #chartdiffs)

	local count = #chartdiffs
	local current = 0
	self.checkProgress(2, count, current)

	for i, chartdiff in ipairs(chartdiffs) do
		if self.shouldStop() then break end
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
			local charts, err = self.getChartsByHash(chartdiff.hash)
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

		current = i
		self.checkProgress(2, count, current)
	end
end

return DifficultyTask
