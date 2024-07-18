local IDiffcalc = require("sphere.models.DifficultyModel.IDiffcalc")
local ChartEncoder = require("sph.ChartEncoder")
local SphPreview = require("sph.SphPreview")
local LinesCleaner = require("sph.lines.LinesCleaner")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")

---@class sphere.PreviewDiffcalc: sphere.IDiffcalc
---@operator call: sphere.PreviewDiffcalc
local PreviewDiffcalc = IDiffcalc + {}

PreviewDiffcalc.name = "enps"
PreviewDiffcalc.chartdiff_field = "notes_preview"

---@param ctx sphere.DiffcalcContext
function PreviewDiffcalc:compute(ctx)
	local chart = ctx.chart

	chart.layers.main:toInterval()
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
