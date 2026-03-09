local ChartDecoder = require("stepmania.ChartDecoder")
local Ssc = require("stepmania.Ssc")

---@class stepmania.SscChartDecoder: stepmania.ChartDecoder
---@operator call: stepmania.SscChartDecoder
local SscChartDecoder = ChartDecoder + {}

---@param s string
---@return ncdk2.Chart[]
function SscChartDecoder:decode(s)
	local ssc = Ssc()
	s = self.conv:convert(s)
	ssc:decode(s)

	---@type {chart: ncdk2.Chart, chartmeta: sea.Chartmeta}[]
	local charts = {}
	for i = 1, #ssc.charts do
		local chart, chartmeta = self:decodeSm(ssc, i)
		charts[i] = {
			chart = chart,
			chartmeta = chartmeta,
		}
	end
	return charts
end

return SscChartDecoder
