local class = require("class")
local md5 = require("md5")

---@class sphere.ChartmetaGenerator
---@operator call: sphere.ChartmetaGenerator
local ChartmetaGenerator = class()

---@param chartmetasRepo sphere.ChartmetasRepo
---@param chartfilesRepo sphere.ChartfilesRepo
---@param chartFactory notechart.ChartFactory
function ChartmetaGenerator:new(chartmetasRepo, chartfilesRepo, chartFactory)
	self.chartmetasRepo = chartmetasRepo
	self.chartfilesRepo = chartfilesRepo
	self.chartFactory = chartFactory
end

---@param chartfile table
---@param content string
---@param not_reuse boolean?
---@return string?
---@return table|string?
function ChartmetaGenerator:generate(chartfile, content, not_reuse)
	local hash = md5.sumhexa(content)

	if not not_reuse and self.chartmetasRepo:selectChartmeta(hash, 1) then
		chartfile.hash = hash
		self.chartfilesRepo:updateChartfile(chartfile)
		return "reused"
	end

	local chart_chartmetas, err = self.chartFactory:getCharts(chartfile.name, content, hash)
	if not chart_chartmetas then
		return nil, err
	end

	for _, t in ipairs(chart_chartmetas) do
		self:setChartmeta(t.chartmeta)
	end

	chartfile.hash = hash
	self.chartfilesRepo:updateChartfile(chartfile)

	return "cached", chart_chartmetas
end

---@param chartmeta table
function ChartmetaGenerator:setChartmeta(chartmeta)
	local old = self.chartmetasRepo:selectChartmeta(chartmeta.hash, chartmeta.index)
	if not old then
		self.chartmetasRepo:insertChartmeta(chartmeta)
		return
	end
	chartmeta.id = old.id
	self.chartmetasRepo:updateChartmeta(chartmeta)
end

return ChartmetaGenerator
