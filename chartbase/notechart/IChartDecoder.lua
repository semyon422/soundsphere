local class = require("class")

---@class chartbase.IChartDecoder
---@operator call: chartbase.IChartDecoder
local IChartDecoder = class()

IChartDecoder.hash = "00000000000000000000000000000000"

---@param s string
---@param hash string?
---@return {chart: ncdk2.Chart, chartmeta: sea.Chartmeta}[]
function IChartDecoder:decode(s, hash)
	return {}
end

return IChartDecoder
