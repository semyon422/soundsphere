local class = require("class")
local md5 = require("md5")

---@class sphere.ChartmetaGenerator
---@operator call: sphere.ChartmetaGenerator
local ChartmetaGenerator = class()

---@param chartRepo sphere.ChartRepo
---@param noteChartFactory notechart.NoteChartFactory
---@param fs love.filesystem
---@param after function?
---@param error_handler function?
function ChartmetaGenerator:new(chartRepo, noteChartFactory, fs, after, error_handler)
	self.chartRepo = chartRepo
	self.noteChartFactory = noteChartFactory
	self.fs = fs
	self.after = after
	self.error_handler = error_handler
	self.reused = 0
	self.cached = 0
end

---@param full boolean?
function ChartmetaGenerator:generate(full)
	local chartfiles = self.chartRepo:selectUnhashedChartfiles()

	for i, chartfile in ipairs(chartfiles) do
		local status, err = self:processChartfile(chartfile, full)

		local noteCharts
		if not status and self.error_handler then
			self.error_handler(chartfile, err)
		elseif status == "reused" then
			self.reused = self.reused + 1
		elseif status == "cached" then
			self.cached = self.cached + #err
			noteCharts = err
		end

		if self.after and self.after(i, #chartfiles, chartfile, noteCharts) then
			return
		end
	end
end

---@param chartfile table
---@param full boolean?
function ChartmetaGenerator:processChartfile(chartfile, full)
	local path = chartfile.dir .. "/" .. chartfile.name

	local content = assert(self.fs.read(path))
	local hash = md5.sumhexa(content)

	if not full and self.chartRepo:selectChartmeta(hash, 1) then
		chartfile.hash = hash
		self.chartRepo:updateChartfile(chartfile)
		return "reused"
	end

	local noteCharts, err = self.noteChartFactory:getNoteCharts(path, content)
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
	self.chartRepo:updateChartfile(chartfile)

	return "cached", noteCharts
end

---@param chartmeta table
function ChartmetaGenerator:setChartmeta(chartmeta)
	local old = self.chartRepo:selectChartmeta(chartmeta.hash, chartmeta.index)
	if not old then
		self.chartRepo:insertChartmeta(chartmeta)
		return
	end
	chartmeta.id = old.id
	self.chartRepo:updateChartmeta(chartmeta)
end

return ChartmetaGenerator
