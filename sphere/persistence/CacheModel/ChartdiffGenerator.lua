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
---@param hash string
---@param index number
function ChartdiffGenerator:create(noteChart, hash, index)
	local chartdiff = self.chartRepo:selectChartdiff(hash, index)
	if chartdiff then
		return
	end

	local difficulty, long_notes_count, notes_count = self.difficultyModel:getDifficulty(noteChart)

	self.chartRepo:insertChartdiff({
		hash = hash,
		index = index,
		inputmode = tostring(noteChart.metaData.inputMode),
		notes_count = notes_count,
		long_notes_count = long_notes_count,
		enps_difficulty = difficulty,
	})
end

return ChartdiffGenerator
