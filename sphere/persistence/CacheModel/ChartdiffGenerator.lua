local class = require("class")

---@class sphere.ChartdiffGenerator
---@operator call: sphere.ChartdiffGenerator
local ChartdiffGenerator = class()

---@param chartdiffsRepo sphere.ChartdiffsRepo
---@param difficultyModel sphere.DifficultyModel
function ChartdiffGenerator:new(chartdiffsRepo, difficultyModel)
	self.chartdiffsRepo = chartdiffsRepo
	self.difficultyModel = difficultyModel
end

---@param noteChart ncdk.NoteChart
---@param rate number
function ChartdiffGenerator:compute(noteChart, rate)
	local chartdiff = {
		rate = rate,
		inputmode = tostring(noteChart.inputMode),
	}

	self.difficultyModel:compute(chartdiff, noteChart, rate)

	return chartdiff
end

---@param chartdiff table
---@param chartmeta table
function ChartdiffGenerator:fillMeta(chartdiff, chartmeta)
	local rate = chartdiff.rate

	chartdiff.tempo = (chartmeta.tempo or 0) * rate
	chartdiff.duration = (chartmeta.duration or 0) / rate
end

---@param noteChart ncdk.NoteChart
---@param hash string
---@param index number
---@return table?
---@return string?
function ChartdiffGenerator:create(noteChart, hash, index)
	local chartdiff = self.chartdiffsRepo:selectDefaultChartdiff(hash, index)
	if chartdiff then
		return chartdiff
	end

	local ok, chartdiff = xpcall(self.compute, debug.traceback, self, noteChart, 1)
	if not ok then
		return nil, chartdiff
	end

	chartdiff.hash = hash
	chartdiff.index = index

	self.chartdiffsRepo:insertChartdiff(chartdiff)

	return chartdiff
end

return ChartdiffGenerator
