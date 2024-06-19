local class = require("class")

---@class sphere.IDiffcalc
---@operator call: sphere.IDiffcalc
local IDiffcalc = class()

IDiffcalc.name = "IDiffcalc"
IDiffcalc.chartdiff_field = ""

---@param ctx sphere.DiffcalcContext
function IDiffcalc:compute(ctx) end

return IDiffcalc
