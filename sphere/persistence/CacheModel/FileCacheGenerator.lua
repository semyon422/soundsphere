local class = require("class")
local table_util = require("table_util")
local path_util = require("path_util")
local sql_util = require("rdb.sql_util")

---@class sphere.FileCacheGenerator
---@operator call: sphere.FileCacheGenerator
local FileCacheGenerator = class()

---@param chartfilesRepo sphere.ChartfilesRepo
---@param noteChartFinder sphere.NoteChartFinder
---@param context sphere.ITaskContext
function FileCacheGenerator:new(chartfilesRepo, noteChartFinder, context)
	self.chartfilesRepo = chartfilesRepo
	self.noteChartFinder = noteChartFinder
	self.context = context
end

---@param root_dir string?
---@param location_id number
---@param location_prefix string?
function FileCacheGenerator:scan(root_dir, location_id, location_prefix)
	local iterator = self.noteChartFinder:iter(location_prefix, root_dir)
	local chartfile_set, chartfile
	local discovered_count = 0

	local typ, dir, name, modtime = iterator()
	while typ do
		if self.context:shouldStop() then break end

		local res
		if name and typ == "related_dir" then
			chartfile_set = self:processChartfileSet({
				dir = dir,
				name = assert(name),
				modified_at = modtime,
				is_file = false,
				location_id = location_id,
			})
		elseif chartfile_set and typ == "related" then
			chartfile = self:processChartfile(chartfile_set.id, name, modtime)
			discovered_count = discovered_count + 1
			if discovered_count % 100 == 0 then
				self.context:checkProgress(1, discovered_count, 0)
			end
		elseif chartfile_set and typ == "related_all" then
			self.chartfilesRepo:deleteChartfiles({set_id = chartfile_set.id, name__notin = name})
			chartfile_set = nil
		elseif typ == "unrelated_dir" then
		elseif typ == "unrelated" then
			chartfile_set = self:processChartfileSet({
				dir = dir,
				name = name,
				modified_at = modtime,
				is_file = true,
				location_id = location_id,
			})
			chartfile = self:processChartfile(chartfile_set.id, name, modtime)
			discovered_count = discovered_count + 1
			if discovered_count % 100 == 0 then
				self.context:checkProgress(1, discovered_count, 0)
			end
		elseif typ == "unrelated_all" then
			self.chartfilesRepo:deleteChartfiles({set_id = chartfile_set.id, name__notin = name})
			self.chartfilesRepo:deleteChartfileSets({
				dir = dir,
				dir__isnull = not dir,
				name__notin = name,
				location_id = location_id,
			})
		elseif typ == "directory_dir" then
		elseif typ == "directory" then
			res = self:shouldScan(dir, name, modtime, location_id)
		elseif typ == "directory_all" then
			local names_current = table_util.invert(name)
			local chartfile_sets = self.chartfilesRepo:selectChartfileSetsAtLocation(location_id, dir)
			local names_to_delete = {}
			for _, set in ipairs(chartfile_sets) do
				if not names_current[set.name] then
					table.insert(names_to_delete, set.name)
				end
			end
			for _, slice in ipairs(table_util.slices(names_to_delete, 1024)) do
				self.chartfilesRepo:deleteChartfileSets({
					dir = dir,
					dir__isnull = not dir,
					name__in = slice,
					location_id = location_id,
				})
			end
		elseif typ == "not_found" then
			self.chartfilesRepo:deleteChartfileSets({
				dir = dir,
				dir__isnull = not dir,
				name = name,
				location_id = location_id,
			})
		end
		typ, dir, name, modtime = iterator(res)
	end

	-- Clean up missing directory sets
	if not root_dir then
		local tdirs = self.chartfilesRepo:selectChartfileSetsDirs(location_id)
		for _, tdir in ipairs(tdirs) do
			if self.context:shouldStop() then break end
			if tdir.dir then
				local dir = path_util.join(location_prefix, tdir.dir)
				if not self.noteChartFinder.fs:getInfo(dir) then
					self.chartfilesRepo:deleteChartfileSets({
						dir = tdir.dir,
						location_id = location_id,
					})
				end
			end
		end
	end
end

---@param dir string?
---@param name string
---@param modified_at number
---@param location_id number
---@return boolean
function FileCacheGenerator:shouldScan(dir, name, modified_at, location_id)
	local chartfile_set = self.chartfilesRepo:selectChartfileSet(dir, name, location_id)
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
	local _chartfile_set = self.chartfilesRepo:selectChartfileSet(
		chartfile_set.dir,
		chartfile_set.name,
		chartfile_set.location_id
	)

	if _chartfile_set then
		if _chartfile_set.modified_at ~= chartfile_set.modified_at then
			_chartfile_set.modified_at = chartfile_set.modified_at
			self.chartfilesRepo:updateChartfileSet(_chartfile_set)
		end
		return _chartfile_set
	end

	_chartfile_set = self.chartfilesRepo:insertChartfileSet(chartfile_set)

	return _chartfile_set
end

---@param name string
---@param set_id number
---@param modified_at number
---@return table
function FileCacheGenerator:processChartfile(set_id, name, modified_at)
	local chartfile = self.chartfilesRepo:selectChartfile(set_id, name)

	if not chartfile then
		return self.chartfilesRepo:insertChartfile({
			name = name,
			modified_at = modified_at,
			set_id = set_id,
		})
	end

	if chartfile.modified_at ~= modified_at then
		chartfile.hash = sql_util.NULL
		chartfile.modified_at = modified_at
		self.chartfilesRepo:updateChartfile(chartfile)
	end

	return chartfile
end

return FileCacheGenerator
