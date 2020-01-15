
local NoteChartFactory			= require("sphere.database.NoteChartFactory")
local NoteChartEntryFactory		= require("sphere.database.NoteChartEntryFactory")
local NoteChartDataEntryFactory	= require("sphere.database.NoteChartDataEntryFactory")
local CacheDatabase				= require("sphere.database.CacheDatabase")
local Cache						= require("sphere.database.Cache")
local Log						= require("aqua.util.Log")

local NoteChartManager = {}

NoteChartManager.init = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/NoteChartManager.log"
end

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
	local noteChartEntries = NoteChartEntryFactory:getEntries(noteChartPaths)
	local noteChartSetEntry = Cache:getNoteChartSetEntry({
		path = noteChartSetPath,
		lastModified = love.filesystem.getLastModified(noteChartSetPath)
	})

	for i = 1, #noteChartEntries do
		local noteChartEntry = noteChartEntries[i]

		noteChartEntry.setId = noteChartSetEntry.id
		noteChartEntry.lastModified = love.filesystem.getLastModified(noteChartEntry.path)
		
		Cache:setNoteChartEntry(noteChartEntry)

		self.log:write("chart", noteChartEntry.path:match("^.+/(.-)$"))
	end
end

NoteChartManager.generateCacheFull = function(self)
	Cache:select()
	CacheDatabase:load()
	CacheDatabase:begin()

	self:lookup("userdata/chartsTest", true)
	self:generate()

	CacheDatabase:commit()
	CacheDatabase:unload()
end

NoteChartManager.generate = function(self)
	local noteChartSets = Cache.noteChartSets
	for i = 1, #noteChartSets do
		self:processNoteChartDataEntries(Cache:getNoteChartsAtSet(noteChartSets[i].id))
	end
end

NoteChartManager.processNoteChartDataEntries = function(self, noteChartEntries)
	local paths = {}
	for i = 1, #noteChartEntries do
		paths[#paths + 1] = noteChartEntries[i].path
	end

	local entries = NoteChartDataEntryFactory:getEntries(paths)
	for i = 1, #entries do
		local noteChartDataEntry = entries[i]
		Cache:setNoteChartDataEntry(noteChartDataEntry)

		local noteChartEntry = Cache:getNoteChartEntryByPath(noteChartDataEntry.path)
		noteChartEntry.hash = noteChartDataEntry.hash
		Cache:setNoteChartEntry(noteChartEntry)
	end
end

NoteChartManager.load = function(self)
	
end

NoteChartManager.getNoteChart = function(self, path)

	return noteChart
end

NoteChartManager.getNoteChartDatas = function(self, paths)

end

return NoteChartManager
