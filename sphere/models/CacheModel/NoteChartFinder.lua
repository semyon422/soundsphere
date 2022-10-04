
local NoteChartFactory = require("notechart.NoteChartFactory")
local Class = require("Class")

local NoteChartFinder = Class:new()

local function lookup(directoryPath, recursive, checkSet)
	local items = love.filesystem.getDirectoryItems(directoryPath)

	local chartPaths = false
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isRelatedContainer(path) then
			chartPaths = true
			coroutine.yield(path, directoryPath)
		end
	end
	if chartPaths then
		return
	end

	local containerPaths = false
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isUnrelatedContainer(path) and checkSet(path) then
			containerPaths = true
			coroutine.yield(path, path)
		end
	end
	if containerPaths then
		return
	end

	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info and (info.type == "directory" or info.type == "symlink") and (recursive or checkSet(path)) then
			lookup(path, recursive, checkSet)
		end
	end
end

NoteChartFinder.newFileIterator = function(self, directoryPath, recursive, checkSet)
	return coroutine.wrap(function()
		lookup(directoryPath, recursive, checkSet)
	end)
end

return NoteChartFinder
