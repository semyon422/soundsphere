local NoteChartFactory = require("notechart.NoteChartFactory")
local class = require("class")

---@class sphere.NoteChartFinder
---@operator call: sphere.NoteChartFinder
local NoteChartFinder = class()

---@param fs table
function NoteChartFinder:new(fs)
	self.fs = fs
end

---@param dir string
function NoteChartFinder:lookupAsync(dir)
	local items = self.fs.getDirectoryItems(dir)
	local dir_info = self.fs.getInfo(dir)

	local all_items = {}

	local chartPaths = false
	for _, item in ipairs(items) do
		local path = dir .. "/" .. item
		local info = self.fs.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isRelatedContainer(path) then
			if not chartPaths then
				chartPaths = true
				coroutine.yield("related_dir", dir, nil, dir_info.modtime)
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
		local path = dir .. "/" .. item
		local info = self.fs.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isUnrelatedContainer(path) then
			if not containerPaths then
				containerPaths = true
				coroutine.yield("unrelated_dir", dir, nil, dir_info.modtime)
			end
			coroutine.yield("unrelated", dir, item, info.modtime)
			table.insert(all_items, item)
		end
	end
	if containerPaths then
		coroutine.yield("unrelated_all", dir, all_items, dir_info.modtime)
		return
	end

	coroutine.yield("directory_dir", dir, nil, dir_info.modtime)

	local checked_items = {}
	for _, item in ipairs(items) do
		local path = dir .. "/" .. item
		local info = self.fs.getInfo(path)
		if info and (info.type == "directory" or info.type == "symlink") then
			if coroutine.yield("directory", dir, item, info.modtime) then
				table.insert(checked_items, item)
			end
			table.insert(all_items, item)
		end
	end

	coroutine.yield("directory_all", dir, all_items, dir_info.modtime)

	for _, item in ipairs(checked_items) do
		self:lookupAsync(dir .. "/" .. item)
	end
end

---@param dir string
---@return function
function NoteChartFinder:iter(dir)
	return coroutine.wrap(function()
		self:lookupAsync(dir)
	end)
end

return NoteChartFinder
