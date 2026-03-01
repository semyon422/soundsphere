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
---@param context sphere.ITaskContext
function DifficultyTask:new(difficultyModel, chartdiffGenerator, chartsRepo, context)
	self.difficultyModel = difficultyModel
	self.chartdiffGenerator = chartdiffGenerator
	self.chartsRepo = chartsRepo
	self.context = context
end

function DifficultyTask:computeMissing()
	local chartsRepo = self.chartsRepo
	local context = self.context

	local scores = chartsRepo:getChartplaysMissingChartdiffs()
	local chartmetas = chartsRepo:getChartmetasMissingChartdiffs()

	local count = #chartmetas + #scores
	local current = 0
	context:checkProgress(2, count, current)

	context:dbBegin()
	print("DifficultyTask: computing default chartdiffs")
	for i, chartmeta in ipairs(chartmetas) do
		if context:shouldStop() then break end
		local charts, err = context:getChartsByHash(chartmeta.hash)
		if not charts then
			context:addError("DifficultyTask: getChartsByHash error (" .. chartmeta.hash .. "): " .. tostring(err))
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
				context:addError("DifficultyTask: toAbsolute error (" .. chartmeta.hash .. "): " .. tostring(err))
			end
		end

		current = current + 1
		context:checkProgress(2, count, current)
		if current % 100 == 0 then
			context:dbCommit()
			context:dbBegin()
		end
	end

	print("DifficultyTask: computing modified chartdiffs")
	for i, score in ipairs(scores) do
		if context:shouldStop() then break end
		local charts, err = context:getChartsByHash(score.hash)
		if not charts then
			context:addError("DifficultyTask: getChartsByHash error (" .. score.hash .. "): " .. tostring(err))
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
				context:addError("DifficultyTask: toAbsolute error (" .. score.hash .. "): " .. tostring(err))
			end
		end

		current = current + 1
		context:checkProgress(2, count, current)
		if current % 100 == 0 then
			context:dbCommit()
			context:dbBegin()
		end
	end
	context:dbCommit()
end

---@param prefer_preview boolean
function DifficultyTask:computeIncomplete(prefer_preview)
	local chartsRepo = self.chartsRepo
	local context = self.context

	local chartdiffs = chartsRepo:getIncompleteChartdiffs()
	print("DifficultyTask: processing incomplete", #chartdiffs)

	local count = #chartdiffs
	local current = 0
	context:checkProgress(2, count, current)

	context:dbBegin()
	for i, chartdiff in ipairs(chartdiffs) do
		if context:shouldStop() then break end
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
				context:addError("DifficultyTask: preview decode error (" .. chartdiff.hash .. "): " .. tostring(err))
			end
		else
			local charts, err = context:getChartsByHash(chartdiff.hash)
			if not charts then
				context:addError("DifficultyTask: getChartsByHash error (" .. chartdiff.hash .. "): " .. tostring(err))
			else
				chart = charts[chartdiff.index]
				local ok, err = xpcall(chart.layers.main.toAbsolute, debug.traceback, chart.layers.main)
				if not ok then
					chart = nil
					context:addError("DifficultyTask: toAbsolute error (" .. chartdiff.hash .. "): " .. tostring(err))
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
		context:checkProgress(2, count, current)
		if i % 100 == 0 then
			context:dbCommit()
			context:dbBegin()
		end
	end
	context:dbCommit()
end

return DifficultyTask
