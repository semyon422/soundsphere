
local NoteChartFactory = require("notechart.NoteChartFactory")
local class = require("class")

---@class sphere.NoteChartFinder
---@operator call: sphere.NoteChartFinder
local NoteChartFinder = class()

---@param directoryPath string
---@param recursive boolean
---@param checkSet function
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

---@param directoryPath string
---@param recursive boolean
---@param checkSet function
---@return function
function NoteChartFinder:newFileIterator(directoryPath, recursive, checkSet)
	return coroutine.wrap(function()
		lookup(directoryPath, recursive, checkSet)
	end)
end

return NoteChartFinder
