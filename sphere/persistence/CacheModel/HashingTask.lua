local class = require("class")
local path_util = require("path_util")

---@class sphere.HashingTask
---@operator call: sphere.HashingTask
local HashingTask = class()

---@param fs fs.IFilesystem
---@param chartmetaGenerator sphere.ChartmetaGenerator
---@param chartdiffGenerator sphere.ChartdiffGenerator
---@param context sphere.ITaskContext
function HashingTask:new(fs, chartmetaGenerator, chartdiffGenerator, context)
	self.fs = fs
	self.chartmetaGenerator = chartmetaGenerator
	self.chartdiffGenerator = chartdiffGenerator
	self.context = context
end

---@param chartfile sea.ClientChartfile
---@param location_prefix string
---@return boolean?
---@return string?
function HashingTask:processChartfile(chartfile, location_prefix)
	local full_path = path_util.join(location_prefix, chartfile.path)
	local content, err = self.fs:read(full_path)
	if not content then
		self.context:addError("HashingTask: read error (" .. chartfile.path .. "): " .. tostring(err))
		return nil, "HashingTask: read error: " .. tostring(err)
	end

	local status, chart_chartmetas = self.chartmetaGenerator:generate(chartfile, content, false)

	if not status then
		self.context:addError("HashingTask: chartmeta error (" .. chartfile.path .. "): " .. tostring(chart_chartmetas))
		return nil, "HashingTask: chartmeta error: " .. tostring(chart_chartmetas)
	end

	if not chart_chartmetas then
		return true
	end
	---@cast chart_chartmetas -string

	for j, t in ipairs(chart_chartmetas) do
		local ok, err = xpcall(t.chart.layers.main.toAbsolute, debug.traceback, t.chart.layers.main)
		if not ok then
			self.context:addError("HashingTask: toAbsolute error (" .. chartfile.path .. "): " .. tostring(err))
			goto continue
		end
		local ok, err = self.chartdiffGenerator:create(t.chart, chartfile.hash, j)
		if not ok then
			self.context:addError("HashingTask: chartdiff error (" .. chartfile.path .. "): " .. tostring(err))
		end
		::continue::
	end
	
	return true
end

return HashingTask
