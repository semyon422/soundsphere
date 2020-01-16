
local NoteChartFactory			= require("sphere.database.NoteChartFactory")
local NoteChartEntryFactory		= require("sphere.database.NoteChartEntryFactory")
local NoteChartDataEntryFactory	= require("sphere.database.NoteChartDataEntryFactory")
local CacheDatabase				= require("sphere.database.CacheDatabase")
local Cache						= require("sphere.database.Cache")
local Log						= require("aqua.util.Log")
local md5						= require("md5")

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
	
	local entries = {}
	for i = 1, #noteChartPaths do
		entries[i] = {path = noteChartPaths[i]}
	end
	local noteChartEntries = NoteChartEntryFactory:getEntries(entries)

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
	CacheDatabase:load()

	print("Find all charts")
	Cache:select()
	CacheDatabase:begin()
	self:lookup("userdata/chartsTest", true)
	CacheDatabase:commit()
	
	print("Create cache")
	Cache:select()
	CacheDatabase:begin()
	self:generate()
	CacheDatabase:commit()
	print("end")

	CacheDatabase:unload()
end

NoteChartManager.generate = function(self)
	local noteChartSets = Cache.noteChartSets
	for i = 1, #noteChartSets do
		self:processNoteChartDataEntries(Cache:getNoteChartsAtSet(noteChartSets[i].id), true)
	end
end

NoteChartManager.getRealPath = function(self, path)
	if path:find("%.ojn/.$") then
		return path:match("^(.+)/.$")
	end
	return path
end

NoteChartManager.processNoteChartDataEntries = function(self, noteChartEntries, reHash)
	if not reHash then
		local newLoteChartEntries = {}
		for i = 1, #noteChartEntries do
			local noteChartEntry = noteChartEntries[i]
			if not noteChartEntry.hash then
				newLoteChartEntries[#newLoteChartEntries + 1] = noteChartEntry
			end
		end
		noteChartEntries = newLoteChartEntries
	end

	local fileContent = {}
	local fileHash = {}

	for i = 1, #noteChartEntries do
		local realPath = self:getRealPath(noteChartEntries[i].path)
		if not fileContent[realPath] then
			local file = love.filesystem.newFile(realPath)
			file:open("r")
			local content = file:read()
			file:close()

			fileContent[realPath] = content
			fileHash[realPath] = md5.sumhexa(content)
		end
	end

	local fileDatas = {}
	for i = 1, #noteChartEntries do
		local path = noteChartEntries[i].path
		local realPath = self:getRealPath(path)

		local noteChartEntry = noteChartEntries[i]
		local content = fileContent[realPath]
		local hash = fileHash[realPath]

		if noteChartEntry.hash ~= hash then
			local noteChartDataEntry = Cache:getNoteChartDataEntry(hash)
			noteChartEntry.hash = hash

			if noteChartDataEntry then
				Cache:setNoteChartEntry(noteChartEntry)
			else
				fileDatas[#fileDatas + 1] = {
					path = path,
					content = content,
					hash = hash,
					noteChartEntry = noteChartEntry
				}
			end
		end
	end

	local entries = NoteChartDataEntryFactory:getEntries(fileDatas)
	for i = 1, #fileDatas do
		local fileData = fileDatas[i]

		Cache:setNoteChartDataEntry(fileData.noteChartDataEntry)
		Cache:setNoteChartEntry(fileData.noteChartEntry)
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
