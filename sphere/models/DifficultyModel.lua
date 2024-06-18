local class = require("class")
local enps = require("libchart.enps")
local osu_starrate = require("libchart.osu_starrate")
local simplify_notechart = require("libchart.simplify_notechart")
local ChartEncoder = require("sph.ChartEncoder")
local SphPreview = require("sph.SphPreview")
local LinesCleaner = require("sph.lines.LinesCleaner")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local MeasureLayer = require("ncdk2.layers.MeasureLayer")
local AbsoluteInterval = require("ncdk2.convert.AbsoluteInterval")
local MeasureInterval = require("ncdk2.convert.MeasureInterval")

---@param chart ncdk2.Chart
local function to_interval(chart)
	local layer = chart.layers.main

	if AbsoluteLayer * layer then
		local conv = AbsoluteInterval({1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 16}, 0.002)
		conv:convert(layer, "closest_gte")
	elseif MeasureLayer * layer then
		local conv = MeasureInterval()
		conv:convert(layer)
	end
end

---@class sphere.DifficultyModel
---@operator call: sphere.DifficultyModel
local DifficultyModel = class()

---@param chartdiff table
---@param chart ncdk2.Chart
---@param timeRate number
function DifficultyModel:compute(chartdiff, chart, timeRate)
	local notes = simplify_notechart(chart)

	local long_notes_count = 0
	for _, note in ipairs(notes) do
		if note.end_time then
			long_notes_count = long_notes_count + 1
		end
	end

	local columns = chart.inputMode:getColumns()
	local bm = osu_starrate.Beatmap(notes, columns, timeRate)

	chartdiff.notes_count = #notes
	chartdiff.long_notes_count = long_notes_count
	chartdiff.enps_diff = enps.getEnps(notes) * timeRate
	chartdiff.osu_diff = bm:calculateStarRate()

	to_interval(chart)
	assert(IntervalLayer * chart.layers.main)

	local encoder = ChartEncoder()
	local sph = encoder:encodeSph(chart)

	local preview_ver = 1
	if columns > 10 then
		preview_ver = 0
	end

	pcall(function()
		local lines = sph.sphLines:encode()
		lines = LinesCleaner:clean(lines)
		chartdiff.notes_preview = SphPreview:encodeLines(lines, preview_ver)
	end)
end

return DifficultyModel
