local class = require("class")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ChartFactory = require("notechart.ChartFactory")

---@class sphere.WebChartHandler
---@operator call: sphere.WebChartHandler
local WebChartHandler = class()

function WebChartHandler:new()
	self.difficultyModel = DifficultyModel()
end

---@param path string
---@return string?
---@return string?
local function read_file(path)
	local file, err = io.open(path, "r")
	if not file then
		return nil, err
	end
	local content = file:read("*a")
	file:close()
	return content
end

---@param notechart table
---@return ncdk2.Chart[]?
---@return string?
function WebChartHandler:getCharts(notechart)
	local content, err = read_file(notechart.path)
	if not content then
		return nil, err
	end

	return ChartFactory:getCharts("file." .. notechart.extension, content)
end

---@param notechart table
---@return ncdk2.Chart?
---@return string?
function WebChartHandler:getChart(notechart)
	local charts, err = WebChartHandler:getCharts(notechart)
	if not charts then
		return nil, err
	end
	return charts[1]
end

---@param params table
---@return integer
---@return table
function WebChartHandler:handle(params)
	local charts, err = WebChartHandler:getCharts(params.notechart)
	if not charts then
		return 500, {error = err}
	end

	local metadatas = {}
	for _, chart in ipairs(charts) do
		local chartmeta = chart.chartmeta
		self.difficultyModel:compute(chartmeta, chart, 1)
		table.insert(metadatas, chartmeta)
	end

	return 200, {notecharts = metadatas}
end


return WebChartHandler
