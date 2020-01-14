
local NoteChartFactory	= require("sphere.database.NoteChartFactory")
local CacheDatabase		= require("sphere.database.CacheDatabase")

local NoteChartManager = {}

NoteChartManager.load = function(self)
	
end

NoteChartManager.getNoteChart = function(self, path)

	return noteChart
end

NoteChartManager.getNoteChartDatas = function(self, paths)

end

local getDirectoryItems, isFile, isDirectory = love.filesystem.getDirectoryItems, love.filesystem.isFile, love.filesystem.isDirectory
NoteChartManager.lookup = function(self, directoryPath, list)
	local items = getDirectoryItems(directoryPath)
	
	for i = 1, #items do
		local path = directoryPath .. "/" .. items[i]
		if isFile(path) and NoteChartFactory:isNoteChart(path) then
			list[#list + 1] = path
		elseif isDirectory(path) then
			self:lookup(path, list)
		end
	end

	return list
end

NoteChartManager.getNoteChartList = function(self, path)
	return self:lookup("userdata/charts", {})
end

return NoteChartManager
