
local NoteChartFactory			= require("sphere.database.NoteChartFactory")
local NoteChartEntryFactory		= require("sphere.database.NoteChartEntryFactory")
local NoteChartDataEntryFactory	= require("sphere.database.NoteChartDataEntryFactory")
local CacheDatabase				= require("sphere.database.CacheDatabase")
local Log						= require("aqua.util.Log")

local NoteChartManager = {}

NoteChartManager.init = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/NoteChartManager.log"
end

-- NoteChartManager.update = function(self, path, recursive, callback)
-- 	if not self.isUpdating then
-- 		self.isUpdating = true
-- 		return ThreadPool:execute(
-- 			[[
-- 				local path, recursive = ...
				
-- 				local CacheDatabase = require("sphere.database.CacheDatabase")
-- 				local CacheDataFactory = require("sphere.database.CacheDataFactory")
-- 				local NoteChartFactory = require("sphere.database.NoteChartFactory")
-- 				CacheDatabase:init()
-- 				CacheDataFactory:init()
-- 				NoteChartFactory:init()
				
-- 				CacheDatabase:load()
-- 				CacheDatabase:clear(path)
-- 				CacheDatabase:lookup(path, recursive)
-- 				CacheDatabase:unload()
-- 			]],
-- 			{path, recursive},
-- 			function(result)
-- 				callback()
-- 				self.isUpdating = false
-- 			end
-- 		)
-- 	end
-- end

NoteChartManager.lookup = function(self, directoryPath, recursive)
	self.log:write("lookup", directoryPath)
	local items = love.filesystem.getDirectoryItems(directoryPath)
	
	local containerPaths = {}
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isFile(path) and NoteChartFactory:isNoteChartContainer(path) then
			containerPaths[#containerPaths + 1] = path
			self:processNoteChartEntries({path}, path)
		end
	end
	if #containerPaths > 0 then
		return
	end
	
	local chartPaths = {}
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isFile(path) and NoteChartFactory:isNoteChart(path) then
			chartPaths[#chartPaths + 1] = path
		end
	end
	if #chartPaths > 0 then
		self:processNoteChartEntries(chartPaths, directoryPath)
		return
	end
	
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isDirectory(path) and (recursive or not self:checkChartSetData(path)) then
			self:lookup(path, recursive)
		end
	end
end

NoteChartManager.processNoteChartEntries = function(self, noteChartPaths, noteChartSetPath)
	self.log:write("ncs", noteChartSetPath:match("^.+/(.-)$"))
	-- CacheDatabase:begin()
	local noteChartEntries = NoteChartEntryFactory:getEntries(noteChartPaths)
	local noteChartSetEntry = CacheDatabase:getNoteChartSetEntry(noteChartSetPath)

	for i = 1, #noteChartEntries do
		local noteChartEntry = noteChartEntries[i]

		noteChartEntry.chartSetId = noteChartSetEntry[1]
		CacheDatabase:setNoteChartEntry(noteChartEntry)

		self.log:write("chart", noteChartEntry.path:match("^.+/(.-)$"))
	end
	-- CacheDatabase:commit()
end

NoteChartManager.generateCacheFull = function(self)
	CacheDatabase:load()
	CacheDatabase:begin()
	self:lookup("userdata/chartsTest", true)
	CacheDatabase:commit()
	CacheDatabase:unload()
end


NoteChartManager.load = function(self)
	
end

NoteChartManager.getNoteChart = function(self, path)

	return noteChart
end

NoteChartManager.getNoteChartDatas = function(self, paths)

end

return NoteChartManager
