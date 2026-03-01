local class = require("class")
local path_util = require("path_util")

---@class sphere.HashingTask
---@operator call: sphere.HashingTask
local HashingTask = class()

---@param fs fs.IFilesystem
---@param chartmetaGenerator sphere.ChartmetaGenerator
---@param chartdiffGenerator sphere.ChartdiffGenerator
function HashingTask:new(fs, chartmetaGenerator, chartdiffGenerator)
	self.fs = fs
	self.chartmetaGenerator = chartmetaGenerator
	self.chartdiffGenerator = chartdiffGenerator
end

---@param chartfile sea.ClientChartfile
---@param location_prefix string
---@return boolean?
---@return string?
function HashingTask:processChartfile(chartfile, location_prefix)
	local full_path = path_util.join(location_prefix, chartfile.path)
	local content, err = self.fs:read(full_path)
	if not content then
		return nil, "HashingTask: read error: " .. tostring(err)
	end

	local status, chart_chartmetas = self.chartmetaGenerator:generate(chartfile, content, false)

	if not status then
		return nil, "HashingTask: chartmeta error: " .. tostring(chart_chartmetas)
	end

	if not chart_chartmetas then
		return true
	end
	---@cast chart_chartmetas -string

	for j, t in ipairs(chart_chartmetas) do
		local ok, err = xpcall(t.chart.layers.main.toAbsolute, debug.traceback, t.chart.layers.main)
		if not ok then
			print("HashingTask: toAbsolute error:", err)
			goto continue
		end
		local ok, err = self.chartdiffGenerator:create(t.chart, chartfile.hash, j)
		if not ok then
			print("HashingTask: chartdiff error:", err)
		end
		::continue::
	end
	
	return true
end

return HashingTask
