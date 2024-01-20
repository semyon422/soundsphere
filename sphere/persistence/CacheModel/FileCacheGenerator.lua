local class = require("class")
local sql_util = require("rdb.sql_util")

---@class sphere.FileCacheGenerator
---@operator call: sphere.FileCacheGenerator
local FileCacheGenerator = class()

---@param chartRepo sphere.ChartRepo
---@param noteChartFinder sphere.NoteChartFinder
function FileCacheGenerator:new(chartRepo, noteChartFinder)
	self.chartRepo = chartRepo
	self.noteChartFinder = noteChartFinder
end

---@param root_dir string
function FileCacheGenerator:lookup(root_dir)
	local iterator = self.noteChartFinder:iter(root_dir)
	local chartfile_set

	local typ, dir, item, modtime = iterator()
	while typ do
		local res
		if typ == "related_dir" then
			chartfile_set = self:processChartfileSet(dir, modtime)
		elseif typ == "related" then
			self:processChartfile(dir .. "/" .. item, chartfile_set.id, modtime)
		elseif typ == "related_all" then
			self.chartRepo:deleteChartfiles({dir = dir, name__notin = item})
		elseif typ == "unrelated_dir" then
		elseif typ == "unrelated" then
			chartfile_set = self:processChartfileSet(dir .. "/" .. item, modtime)
			self:processChartfile(dir .. "/" .. item, chartfile_set.id, modtime)
		elseif typ == "unrelated_all" then
			self.chartRepo:deleteChartfiles({dir = dir, name__notin = item})
			self.chartRepo:deleteChartfileSets({dir = dir, name__notin = item})
		elseif typ == "directory_dir" then
		elseif typ == "directory" then
			res = self:shouldScan(dir .. "/" .. item, modtime)
		elseif typ == "directory_all" then
			self.chartRepo:deleteChartfileSets({dir = dir, name__notin = item})
		end
		typ, dir, item, modtime = iterator(res)
	end
end

---@param path string
---@param modified_at number
---@return boolean
function FileCacheGenerator:shouldScan(path, modified_at)
	local chartfile_set = self.chartRepo:selectChartfileSet(path)
	if not chartfile_set then
		return true
	end
	if chartfile_set.modified_at ~= modified_at then
		return true
	end
	return false
end

---@param path string
---@return table
function FileCacheGenerator:processChartfileSet(path, modified_at)
	local chartfile_set = self.chartRepo:selectChartfileSet(path)

	if chartfile_set then
		chartfile_set.modified_at = modified_at
		self.chartRepo:updateChartfileSet(chartfile_set)
		return chartfile_set
	end

	return self.chartRepo:insertChartfileSet({
		path = path,
		modified_at = modified_at,
	})
end

---@param chartfile_path string
---@param chartfile_set_id number
function FileCacheGenerator:processChartfile(chartfile_path, chartfile_set_id, modified_at)
	local chartfile = self.chartRepo:selectChartfile(chartfile_path)

	if not chartfile then
		self.chartRepo:insertChartfile({
			path = chartfile_path,
			modified_at = modified_at,
			chartfile_set_id = chartfile_set_id,
		})
		return
	end

	if chartfile.modified_at ~= modified_at then
		chartfile.hash = sql_util.NULL
		chartfile.modified_at = modified_at
		self.chartRepo:updateChartfile(chartfile)
	end
end

return FileCacheGenerator
