local class = require("class")

---@class sphere.ChartdiffGenerator
---@operator call: sphere.ChartdiffGenerator
local ChartdiffGenerator = class()

---@param chartsRepo sea.ChartsRepo
---@param difficultyModel sphere.DifficultyModel
function ChartdiffGenerator:new(chartsRepo, difficultyModel)
	self.chartsRepo = chartsRepo
	self.difficultyModel = difficultyModel
end

---@param chart ncdk2.Chart
---@param rate number
function ChartdiffGenerator:compute(chart, rate)
	local chartdiff = {
		rate = rate,
		inputmode = tostring(chart.inputMode),
		modifiers = {},
		mode = "mania",
	}

	self.difficultyModel:compute(chartdiff, chart, rate)

	return chartdiff
end

---@param chart ncdk2.Chart
---@param hash string
---@param index number
---@return sea.Chartdiff?
---@return string?
function ChartdiffGenerator:create(chart, hash, index)
	local chartdiff = self.chartsRepo:selectDefaultChartdiff(hash, index)
	if chartdiff then
		return chartdiff
	end

	local ok, chartdiff = xpcall(self.compute, debug.traceback, self, chart, 1)
	if not ok then
		---@cast chartdiff +string, -table
		return nil, chartdiff
	end

	chartdiff.hash = hash
	chartdiff.index = index

	self.chartsRepo:createChartdiff(chartdiff)

	return chartdiff
end

return ChartdiffGenerator
