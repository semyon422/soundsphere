local IDiffcalc = require("sphere.models.DifficultyModel.IDiffcalc")
local minacalc = require("libchart.minacalc")

---@class sphere.MsdDiffcalc: sphere.IDiffcalc
---@operator call: sphere.MsdDiffcalc
local MsdDiffcalc = IDiffcalc + {}

MsdDiffcalc.name = "MSD"
MsdDiffcalc.chartdiff_field = "msd_diff"

---@param ctx sphere.DiffcalcContext
function MsdDiffcalc:compute(ctx)
	local notes = ctx:getSimplifiedNotes()

	local columns = ctx.chart.inputMode:getColumns()
	local ssr = minacalc.calc(notes, columns, ctx.rate)

	ctx.chartdiff.msd_diff = ssr.overall
	ctx.chartdiff.msd_diff_data = ssr
end

return MsdDiffcalc
