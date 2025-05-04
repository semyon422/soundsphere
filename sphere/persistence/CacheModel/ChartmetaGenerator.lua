local class = require("class")
local md5 = require("md5")

---@class sphere.ChartmetaGenerator
---@operator call: sphere.ChartmetaGenerator
local ChartmetaGenerator = class()

---@param chartsRepo sea.ChartsRepo
---@param chartfilesRepo sphere.ChartfilesRepo
---@param chartFactory notechart.ChartFactory
function ChartmetaGenerator:new(chartsRepo, chartfilesRepo, chartFactory)
	self.chartsRepo = chartsRepo
	self.chartfilesRepo = chartfilesRepo
	self.chartFactory = chartFactory
end

---@param chartfile sea.ClientChartfile
---@param content string
---@param not_reuse boolean?
---@return string?
---@return {chart: ncdk2.Chart, chartmeta: sea.Chartmeta}[]|string?
function ChartmetaGenerator:generate(chartfile, content, not_reuse)
	local chartfilesRepo = self.chartfilesRepo
	local chartsRepo = self.chartsRepo

	local hash = md5.sumhexa(content)

	if not not_reuse and chartsRepo:getChartmetaByHashIndex(hash, 1) then
		chartfile.hash = hash
		chartfilesRepo:updateChartfile(chartfile)
		return "reused"
	end

	local chart_chartmetas, err = self.chartFactory:getCharts(chartfile.name, content, hash)
	if not chart_chartmetas then
		return nil, err
	end

	for _, t in ipairs(chart_chartmetas) do
		chartsRepo:createUpdateChartmeta(t.chartmeta)
	end

	chartfile.hash = hash
	chartfilesRepo:updateChartfile(chartfile)

	return "cached", chart_chartmetas
end

return ChartmetaGenerator
