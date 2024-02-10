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

---@param root_dir string?
---@param location_id number
---@param location_prefix string?
function FileCacheGenerator:lookup(root_dir, location_id, location_prefix)
	local iterator = self.noteChartFinder:iter(location_prefix, root_dir)
	local chartfile_set

	local typ, dir, name, modtime = iterator()
	while typ do
		local res
		if typ == "related_dir" then
			chartfile_set = self:processChartfileSet({
				dir = dir,
				name = name,
				modified_at = modtime,
				is_file = false,
				location_id = location_id,
			})
		elseif typ == "related" then
			self:processChartfile(chartfile_set.id, name, modtime)
		elseif typ == "related_all" then
			self.chartRepo:deleteChartfiles({set_id = chartfile_set.id, name__notin = name})
		elseif typ == "unrelated_dir" then
		elseif typ == "unrelated" then
			chartfile_set = self:processChartfileSet({
				dir = dir,
				name = name,
				modified_at = modtime,
				is_file = true,
				location_id = location_id,
			})
			self:processChartfile(chartfile_set.id, name, modtime)
		elseif typ == "unrelated_all" then
			self.chartRepo:deleteChartfiles({set_id = chartfile_set.id, name__notin = name})
			self.chartRepo:deleteChartfileSets({
				dir = dir,
				dir__isnull = not dir,
				name__notin = name,
				location_id = location_id,
			})
		elseif typ == "directory_dir" then
		elseif typ == "directory" then
			res = self:shouldScan(dir, name, modtime)
		elseif typ == "directory_all" then
			self.chartRepo:deleteChartfileSets({
				dir = dir,
				dir__isnull = not dir,
				name__notin = name,
				location_id = location_id,
			})
		end
		typ, dir, name, modtime = iterator(res)
	end
end

---@param dir string?
---@param name string
---@param modified_at number
---@return boolean
function FileCacheGenerator:shouldScan(dir, name, modified_at)
	local chartfile_set = self.chartRepo:selectChartfileSet(dir, name)
	if not chartfile_set then
		return true
	end
	if chartfile_set.modified_at ~= modified_at then
		return true
	end
	return false
end

---@param chartfile_set table
---@return table
function FileCacheGenerator:processChartfileSet(chartfile_set)
	local _chartfile_set = self.chartRepo:selectChartfileSet(
		chartfile_set.dir,
		chartfile_set.name
	)

	if _chartfile_set then
		if _chartfile_set.modified_at ~= chartfile_set.modified_at then
			_chartfile_set.modified_at = chartfile_set.modified_at
			self.chartRepo:updateChartfileSet(_chartfile_set)
		end
		return _chartfile_set
	end

	_chartfile_set = self.chartRepo:insertChartfileSet(chartfile_set)

	return _chartfile_set
end

---@param name string
---@param set_id number
---@param modified_at number
function FileCacheGenerator:processChartfile(set_id, name, modified_at)
	local chartfile = self.chartRepo:selectChartfile(set_id, name)

	if not chartfile then
		self.chartRepo:insertChartfile({
			name = name,
			modified_at = modified_at,
			set_id = set_id,
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
