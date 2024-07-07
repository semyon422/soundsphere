local IDiffcalc = require("sphere.models.DifficultyModel.IDiffcalc")
local ChartEncoder = require("sph.ChartEncoder")
local SphPreview = require("sph.SphPreview")
local LinesCleaner = require("sph.lines.LinesCleaner")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local MeasureLayer = require("ncdk2.layers.MeasureLayer")
local AbsoluteInterval = require("ncdk2.convert.AbsoluteInterval")
local MeasureInterval = require("ncdk2.convert.MeasureInterval")

---@class sphere.PreviewDiffcalc: sphere.IDiffcalc
---@operator call: sphere.PreviewDiffcalc
local PreviewDiffcalc = IDiffcalc + {}

PreviewDiffcalc.name = "enps"
PreviewDiffcalc.chartdiff_field = "notes_preview"

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

---@param ctx sphere.DiffcalcContext
function PreviewDiffcalc:compute(ctx)
	local chart = ctx.chart

	to_interval(chart)
	assert(IntervalLayer * chart.layers.main)

	local encoder = ChartEncoder()
	local sph = encoder:encodeSph(chart)

	local preview_ver = 1
	if chart.inputMode:getColumns() > 10 then
		preview_ver = 0
	end

	-- SphPreview still have some issues with encoding unusual charts
	pcall(function()
		local lines = sph.sphLines:encode()
		lines = LinesCleaner:clean(lines)
		ctx.chartdiff.notes_preview = SphPreview:encodeLines(lines, preview_ver)
	end)
end

return PreviewDiffcalc
