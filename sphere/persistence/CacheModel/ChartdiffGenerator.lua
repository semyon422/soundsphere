local class = require("class")

---@class sphere.ChartdiffGenerator
---@operator call: sphere.ChartdiffGenerator
local ChartdiffGenerator = class()

---@param chartRepo sphere.ChartRepo
---@param difficultyModel sphere.DifficultyModel
function ChartdiffGenerator:new(chartRepo, difficultyModel)
	self.chartRepo = chartRepo
	self.difficultyModel = difficultyModel
end

---@param noteChart ncdk.NoteChart
---@param rate number?
function ChartdiffGenerator:compute(noteChart, rate)
	local difficulty, long_notes_count, notes_count = self.difficultyModel:getDifficulty(noteChart, rate)

	return {
		inputmode = tostring(noteChart.inputMode),
		notes_count = notes_count,
		long_notes_count = long_notes_count,
		enps_diff = difficulty,
		rate = rate,
	}
end

---@param chartdiff table
---@param chartmeta table
function ChartdiffGenerator:fillMeta(chartdiff, chartmeta)
	local rate = chartdiff.rate

	chartdiff.tempo = chartmeta.tempo * rate
	chartdiff.duration = chartmeta.duration / rate
end

---@param chartdiff table
function ChartdiffGenerator:createUpdateChartdiff(chartdiff)
	local _chartdiff = self.chartRepo:selectChartdiff(chartdiff)
	if not _chartdiff then
		return self.chartRepo:insertChartdiff(chartdiff)
	end
	chartdiff.id = _chartdiff.id
	return self.chartRepo:updateChartdiff(chartdiff)
end

---@param noteChart ncdk.NoteChart
---@param hash string
---@param index number
function ChartdiffGenerator:create(noteChart, hash, index)
	local chartdiff = self.chartRepo:selectDefaultChartdiff(hash, index)
	if chartdiff then
		return
	end

	chartdiff = self:compute(noteChart)
	chartdiff.hash = hash
	chartdiff.index = index

	self.chartRepo:insertChartdiff(chartdiff)
end

return ChartdiffGenerator
