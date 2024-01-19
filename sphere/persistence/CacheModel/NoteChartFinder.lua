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

	local chartPaths = false
	for _, item in ipairs(items) do
		local path = dir .. "/" .. item
		local info = self.fs.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isRelatedContainer(path) then
			chartPaths = true
			if self.checkFile(path) then
				coroutine.yield(path, dir)
			end
		end
	end
	if chartPaths then
		return
	end

	local containerPaths = false
	for _, item in ipairs(items) do
		local path = dir .. "/" .. item
		local info = self.fs.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isUnrelatedContainer(path) and self.checkFile(path) then
			containerPaths = true
			if self.checkFile(path) then
				coroutine.yield(path, path)
			end
		end
	end
	if containerPaths then
		return
	end

	for _, item in ipairs(items) do
		local path = dir .. "/" .. item
		local info = self.fs.getInfo(path)
		if info and (info.type == "directory" or info.type == "symlink") and self.checkDir(path) then
			self:lookupAsync(path)
		end
	end
end

---@param dir string
---@return function
function NoteChartFinder:newFileIterator(dir)
	return coroutine.wrap(function()
		self:lookupAsync(dir)
	end)
end

return NoteChartFinder
