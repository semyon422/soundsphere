local class = require("class")

---@class sea.IChartSelector
---@operator call: sea.IChartSelector
local IChartSelector = class()

---@param hash string
---@param index integer
function IChartSelector:selectChart(hash, index) end

return IChartSelector
