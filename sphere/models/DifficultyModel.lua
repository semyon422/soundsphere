local class = require("class")
local enps = require("libchart.enps")
local osu_starrate = require("libchart.osu_starrate")
local simplify_notechart = require("libchart.simplify_notechart")

---@class sphere.DifficultyModel
---@operator call: sphere.DifficultyModel
local DifficultyModel = class()

---@param chartdiff table
---@param noteChart ncdk.NoteChart
---@param timeRate number
function DifficultyModel:compute(chartdiff, noteChart, timeRate)
	local notes = simplify_notechart(noteChart)

	local long_notes_count = 0
	for _, note in ipairs(notes) do
		if note.end_time then
			long_notes_count = long_notes_count + 1
		end
	end

	local bm = osu_starrate.Beatmap(notes, noteChart.inputMode:getColumns(), timeRate)

	chartdiff.notes_count = #notes
	chartdiff.long_notes_count = long_notes_count
	chartdiff.enps_diff = enps.getEnps(notes) * timeRate
	chartdiff.osu_diff = bm:calculateStarRate()
end

return DifficultyModel
