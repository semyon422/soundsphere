local class = require("class")
local ModifierModel = require("sphere.models.ModifierModel")
local SphPreview = require("sph.SphPreview")
local Sph = require("sph.Sph")
local ChartDecoder = require("sph.ChartDecoder")

---@class rizu.library.DifficultyTask
---@operator call: rizu.library.DifficultyTask
local DifficultyTask = class()

---@param difficultyModel sphere.DifficultyModel
---@param chartdiffGenerator rizu.library.ChartdiffGenerator
---@param chartsRepo sea.ChartsRepo
---@param taskContext rizu.library.ITaskContext
function DifficultyTask:new(difficultyModel, chartdiffGenerator, chartsRepo, taskContext)
	self.difficultyModel = difficultyModel
	self.chartdiffGenerator = chartdiffGenerator
	self.chartsRepo = chartsRepo
	self.taskContext = taskContext
end

function DifficultyTask:computeMissing()
	local chartsRepo = self.chartsRepo
	local taskContext = self.taskContext

	local scores = chartsRepo:getChartplaysMissingChartdiffs()
	local chartmetas = chartsRepo:getChartmetasMissingChartdiffs()

	local count = #chartmetas + #scores
	local current = 0
	taskContext:checkProgress(2, count, current)

	taskContext:dbBegin()
	print("DifficultyTask: computing default chartdiffs")
	for i, chartmeta in ipairs(chartmetas) do
		if taskContext:shouldStop() then break end
		local charts_data, err = taskContext:getChartsByHash(chartmeta.hash)
		if not charts_data then
			taskContext:addError("DifficultyTask: getChartsByHash error (" .. chartmeta.hash .. "): " .. tostring(err))
		else
			local chart = charts_data[chartmeta.index]

			local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
			if ok then
				local time = os.time()
				local chartdiff = self.chartdiffGenerator:compute(chart, 1)
				chartdiff.hash = chartmeta.hash
				chartdiff.index = chartmeta.index
				chartsRepo:createUpdateChartdiff(chartdiff, time)
			else
				taskContext:addError("DifficultyTask: toAbsolute error (" .. chartmeta.hash .. "): " .. tostring(err))
			end
		end

		current = current + 1
		taskContext:checkProgress(2, count, current)
		if current % 100 == 0 then
			taskContext:dbCommit()
			taskContext:dbBegin()
		end
	end

	print("DifficultyTask: computing modified chartdiffs")
	for i, score in ipairs(scores) do
		if taskContext:shouldStop() then break end
		local charts_data, err = taskContext:getChartsByHash(score.hash)
		if not charts_data then
			taskContext:addError("DifficultyTask: getChartsByHash error (" .. score.hash .. "): " .. tostring(err))
		else
			local chart = charts_data[score.index]
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
				taskContext:addError("DifficultyTask: toAbsolute error (" .. score.hash .. "): " .. tostring(err))
			end
		end

		current = current + 1
		taskContext:checkProgress(2, count, current)
		if current % 100 == 0 then
			taskContext:dbCommit()
			taskContext:dbBegin()
		end
	end
	taskContext:dbCommit()
end

---@param prefer_preview boolean
function DifficultyTask:computeIncomplete(prefer_preview)
	local chartsRepo = self.chartsRepo
	local taskContext = self.taskContext

	local chartdiffs = chartsRepo:getIncompleteChartdiffs()
	print("DifficultyTask: processing incomplete", #chartdiffs)

	local count = #chartdiffs
	local current = 0
	taskContext:checkProgress(2, count, current)

	taskContext:dbBegin()
	for i, chartdiff in ipairs(chartdiffs) do
		if taskContext:shouldStop() then break end
		---@type ncdk2.Chart
		local chart

		local preview = chartdiff.notes_preview
		if preview and prefer_preview then
			local ok, err = pcall(function()
				local lines = SphPreview:decodeLines(preview)

				local sph = Sph()
				sph.metadata.input = assert(chartdiff.inputmode)
				sph.sphLines:decode(lines)

				local decoder = ChartDecoder()
				chart = decoder:decodeSph(sph)
			end)
			if not ok then
				taskContext:addError("DifficultyTask: preview decode error (" .. chartdiff.hash .. "): " .. tostring(err))
			end
		else
			local charts_data, err = taskContext:getChartsByHash(chartdiff.hash)
			if not charts_data then
				taskContext:addError("DifficultyTask: getChartsByHash error (" .. chartdiff.hash .. "): " .. tostring(err))
			else
				chart = charts_data[chartdiff.index]
				local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
				if not ok then
					chart = nil
					taskContext:addError("DifficultyTask: toAbsolute error (" .. chartdiff.hash .. "): " .. tostring(err))
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
		taskContext:checkProgress(2, count, current)
		if i % 100 == 0 then
			taskContext:dbCommit()
			taskContext:dbBegin()
		end
	end
	taskContext:dbCommit()
end

return DifficultyTask
