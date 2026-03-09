local ChartDecoder = require("bms.ChartDecoder")
local Bms = require("bms.BMS")

---@class bms.PmsChartDecoder: bms.ChartDecoder
---@operator call: bms.PmsChartDecoder
local PmsChartDecoder = ChartDecoder + {}

---@param s string
---@param hash string?
---@return {chart: ncdk2.Chart, chartmeta: sea.Chartmeta}[]
function PmsChartDecoder:decode(s, hash)
	self.hash = hash
	local bms = Bms()
	bms.pms = true
	local content = s:gsub("\r[\r\n]?", "\n")
	content = self.conv:convert(content)
	bms:import(content)
	local chart, chartmeta = self:decodeBms(bms)
	return {{
		chart = chart,
		chartmeta = chartmeta,
	}}
end

return PmsChartDecoder
