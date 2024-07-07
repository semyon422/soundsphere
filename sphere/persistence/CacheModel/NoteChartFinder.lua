local ChartLocation = require("notechart.ChartLocation")
local path_util = require("path_util")
local class = require("class")

---@class sphere.NoteChartFinder
---@operator call: sphere.NoteChartFinder
local NoteChartFinder = class()

---@param fs love.filesystem
function NoteChartFinder:new(fs)
	self.fs = fs
end

local function get_dir_name(dir)
	if not dir then
		return
	end
	local a, b = dir:match("^(.*)/(.-)$")
	if a and b then
		return a, b
	end
	return nil, dir
end
NoteChartFinder.get_dir_name = get_dir_name

---@param prefix string?
---@param dir string?
function NoteChartFinder:lookupAsync(prefix, dir)
	print("scan dir", prefix, dir)
	local prefix_dir = path_util.join(prefix, dir)

	local items = self.fs.getDirectoryItems(prefix_dir)
	local dir_info = self.fs.getInfo(prefix_dir)
	if not dir_info then
		local a, b = get_dir_name(dir)
		coroutine.yield("not_found", a, b, nil)
		return
	end

	local all_items = {}

	local chartPaths = false
	for _, item in ipairs(items) do
		local info = self.fs.getInfo(path_util.join(prefix, dir, item))
		if info and info.type == "file" and ChartLocation:isRelated(item) then
			if not chartPaths then
				chartPaths = true
				local a, b = get_dir_name(dir)
				coroutine.yield("related_dir", a, b, dir_info.modtime)
			end
			coroutine.yield("related", dir, item, info.modtime)
			table.insert(all_items, item)
		end
	end
	if chartPaths then
		coroutine.yield("related_all", dir, all_items, dir_info.modtime)
		return
	end

	local containerPaths = false
	for _, item in ipairs(items) do
		local info = self.fs.getInfo(path_util.join(prefix, dir, item))
		if info and info.type == "file" and ChartLocation:isUnrelated(item) then
			if not containerPaths then
				containerPaths = true
				local a, b = get_dir_name(dir)
				coroutine.yield("unrelated_dir", a, b, dir_info.modtime)
			end
			coroutine.yield("unrelated", dir, item, info.modtime)
			table.insert(all_items, item)
		end
	end
	if containerPaths then
		coroutine.yield("unrelated_all", dir, all_items, dir_info.modtime)
		return
	end

	local a, b = get_dir_name(dir)
	coroutine.yield("directory_dir", a, b, dir_info.modtime)

	local checked_items = {}
	for _, item in ipairs(items) do
		local info = self.fs.getInfo(path_util.join(prefix, dir, item))
		if info and (info.type == "directory" or info.type == "symlink") then
			if coroutine.yield("directory", dir, item, info.modtime) then
				table.insert(checked_items, item)
			end
			table.insert(all_items, item)
		end
	end

	coroutine.yield("directory_all", dir, all_items, dir_info.modtime)

	for _, item in ipairs(checked_items) do
		self:lookupAsync(prefix, path_util.join(dir, item))
	end
end

---@param prefix string?
---@param dir string?
---@return function
function NoteChartFinder:iter(prefix, dir)
	return coroutine.wrap(function()
		self:lookupAsync(prefix, dir)
	end)
end

return NoteChartFinder
