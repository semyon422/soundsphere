local NoteChartFactory = require("notechart.NoteChartFactory")
local class = require("class")

---@class sphere.NoteChartFinder
---@operator call: sphere.NoteChartFinder
local NoteChartFinder = class()

---@param checkDir function
---@param checkFile function
---@param fs table
function NoteChartFinder:new(checkDir, checkFile, fs)
	self.checkDir = checkDir
	self.checkFile = checkFile
	self.fs = fs
end

---@param dir string
function NoteChartFinder:lookupAsync(dir)
	local items = self.fs.getDirectoryItems(dir)

	local all_items = {}
	local checked_items = {}

	local chartPaths = false
	for _, item in ipairs(items) do
		local path = dir .. "/" .. item
		local info = self.fs.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isRelatedContainer(path) then
			chartPaths = true
			if self.checkFile(path) then
				table.insert(checked_items, item)
			end
			table.insert(all_items, item)
		end
	end
	if chartPaths then
		coroutine.yield("related", dir, checked_items, all_items)
		return
	end

	local containerPaths = false
	for _, item in ipairs(items) do
		local path = dir .. "/" .. item
		local info = self.fs.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isUnrelatedContainer(path) and self.checkFile(path) then
			containerPaths = true
			if self.checkFile(path) then
				table.insert(checked_items, item)
			end
			table.insert(all_items, item)
		end
	end
	if containerPaths then
		coroutine.yield("unrelated", dir, checked_items, all_items)
		return
	end

	for _, item in ipairs(items) do
		local path = dir .. "/" .. item
		local info = self.fs.getInfo(path)
		if info and (info.type == "directory" or info.type == "symlink") then
			if self.checkDir(path) then
				table.insert(checked_items, item)
			end
			table.insert(all_items, item)
		end
	end

	coroutine.yield("directories", dir, checked_items, all_items)

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
