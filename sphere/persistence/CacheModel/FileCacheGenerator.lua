local class = require("class")
local sql_util = require("rdb.sql_util")

---@class sphere.FileCacheGenerator
---@operator call: sphere.FileCacheGenerator
local FileCacheGenerator = class()

---@param chartRepo sphere.ChartRepo
---@param noteChartFinder sphere.NoteChartFinder
function FileCacheGenerator:new(chartRepo, noteChartFinder, get_modtime)
	self.chartRepo = chartRepo
	self.noteChartFinder = noteChartFinder
	self.get_modtime = get_modtime
end

---@param root_dir string
function FileCacheGenerator:lookup(root_dir)
	for typ, dir, checked_items, all_items in self.noteChartFinder:iter(root_dir) do
		print(typ, dir, checked_items, all_items)
		if typ == "related" then
			local chartfile_set = self:processChartfileSet(dir)
			for _, item in ipairs(checked_items) do
				self:processChartfile(dir .. "/" .. item, chartfile_set.id)
			end
			self.chartRepo:deleteChartfiles({dir = dir, name__notin = all_items})
		elseif typ == "unrelated" then
			for _, item in ipairs(checked_items) do
				local chartfile_set = self:processChartfileSet(dir .. "/" .. item)
				self:processChartfile(dir .. "/" .. item, chartfile_set.id)
			end
			self.chartRepo:deleteChartfiles({dir = dir, name__notin = all_items})
			self.chartRepo:deleteChartfileSets({dir = dir, name__notin = all_items})
		elseif typ == "directories" then
			self.chartRepo:deleteChartfileSets({dir = dir, name__notin = all_items})
		end
	end
end

---@param path string
---@return table
function FileCacheGenerator:processChartfileSet(path)
	local modified_at = self.get_modtime(path)
	local chartfile_set = self.chartRepo:selectChartfileSet(path)

	if chartfile_set and chartfile_set.modified_at == modified_at then
		return chartfile_set
	end

	if not chartfile_set then
		return self.chartRepo:insertChartfileSet({
			path = path,
			modified_at = modified_at,
		})
	end

	chartfile_set.modified_at = modified_at
	self.chartRepo:updateChartfileSet(chartfile_set)

	return chartfile_set
end

---@param chartfile_path string
---@param chartfile_set_id number
function FileCacheGenerator:processChartfile(chartfile_path, chartfile_set_id)
	local modified_at = self.get_modtime(chartfile_path)
	local chartfile = self.chartRepo:selectChartfile(chartfile_path)

	if chartfile then
		if chartfile.modified_at ~= modified_at then
			chartfile.hash = sql_util.NULL
			chartfile.modified_at = modified_at
			chartfile.chartfile_set_id = chartfile_set_id
			self.chartRepo:updateChartfile(chartfile)
		elseif chartfile.chartfile_set_id ~= chartfile_set_id then
			chartfile.chartfile_set_id = chartfile_set_id
			self.chartRepo:updateChartfile(chartfile)
		end
		return
	end

	self.chartRepo:insertChartfile({
		path = chartfile_path,
		modified_at = modified_at,
		chartfile_set_id = chartfile_set_id
	})
end

return FileCacheGenerator
