local class = require("class")
local path_util = require("path_util")
local md5 = require("md5")

---@class sphere.ChartmetaGenerator
---@operator call: sphere.ChartmetaGenerator
local ChartmetaGenerator = class()

---@param chartmetasRepo sphere.ChartmetasRepo
---@param chartfilesRepo sphere.ChartfilesRepo
---@param noteChartFactory notechart.NoteChartFactory
function ChartmetaGenerator:new(chartmetasRepo, chartfilesRepo, noteChartFactory)
	self.chartmetasRepo = chartmetasRepo
	self.chartfilesRepo = chartfilesRepo
	self.noteChartFactory = noteChartFactory
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

	local noteCharts, err = self.noteChartFactory:getNoteCharts(chartfile.name, content)
	if not noteCharts then
		return nil, err
	end

	for index, noteChart in ipairs(noteCharts) do
		local chartmeta = noteChart.chartmeta
		chartmeta.hash = hash
		chartmeta.index = index
		self:setChartmeta(chartmeta)
	end

	chartfile.hash = hash
	self.chartfilesRepo:updateChartfile(chartfile)

	return "cached", noteCharts
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
