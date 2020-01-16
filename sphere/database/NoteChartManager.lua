
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

	NoteChartDataEntryFactory:init()
end

NoteChartManager.resetProgress = function(self)
	self.noteChartSetCount = 0
	self.noteChartCount = 0

	self.noteChartSetCountDelta = 100
	self.noteChartCountDelta = 100

	self.noteChartSetCountNext = self.noteChartSetCountDelta
	self.noteChartCountNext = self.noteChartCountDelta
end

NoteChartManager.checkProgress = function(self)
	if self.noteChartSetCount >= self.noteChartSetCountNext then
		self.log:write("progress", "notechart set ".. self.noteChartSetCount)
		self.noteChartSetCountNext = self.noteChartSetCountNext + self.noteChartSetCountDelta
		
		CacheDatabase:commit()
		CacheDatabase:begin()
	end
	if self.noteChartCount >= self.noteChartCountNext then
		self.log:write("progress", "notechart ".. self.noteChartCount)
		self.noteChartCountNext = self.noteChartCountNext + self.noteChartCountDelta
	end
end

NoteChartManager.lookup = function(self, directoryPath, recursive)
	-- self.log:write("lookup", directoryPath)
	local items = love.filesystem.getDirectoryItems(directoryPath)
	
	local containerPaths = {}
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isFile(path) and NoteChartFactory:isNoteChartContainer(path) and self:checkNoteChartSetEntry(path) then
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
		if love.filesystem.isDirectory(path) and (recursive or self:checkNoteChartSetEntry(path)) then
			self:lookup(path, recursive)
		end
	end
end

NoteChartManager.checkNoteChartSetEntry = function(self, path)
	local entry = Cache:getNoteChartSetEntryByPath(path)
	if not entry then
		return true
	end

	local lastModified = love.filesystem.getLastModified(path)
	if entry.lastModified ~= lastModified then
		return true
	end

	return false
end

NoteChartManager.processNoteChartEntries = function(self, noteChartPaths, noteChartSetPath)
	-- self.log:write("ncs", noteChartSetPath:match("^.+/(.-)$"))

	local noteChartSetEntry = Cache:getNoteChartSetEntry({
		path = noteChartSetPath,
		lastModified = love.filesystem.getLastModified(noteChartSetPath)
	})
	self.noteChartSetCount = self.noteChartSetCount + 1
	
	local entries = {}
	for i = 1, #noteChartPaths do
		local path = noteChartPaths[i]
		local lastModified = love.filesystem.getLastModified(path)
		local entry = Cache:getNoteChartEntryByPath(path)

		-- self.log:write("entry", path)
		if entry then
			-- self.log:write("entry", "exists")
			if entry.lastModified ~= lastModified then
				entry.hash = nil
				entry.lastModified = lastModified
				entry.setId = noteChartSetEntry.id
				-- self.log:write("entry", "modified, resetting hash")
				Cache:setNoteChartEntry(entry)
			elseif entry.setId ~= noteChartSetEntry.id then
				entry.setId = noteChartSetEntry.id
				-- self.log:write("entry", "wrong setId, updating")
				Cache:setNoteChartEntry(entry)
			end
		else
			-- self.log:write("entry", "not exists, adding to table")
			entries[#entries + 1] = {
				path = noteChartPaths[i],
				lastModified = lastModified
			}
		end
	end
	local noteChartEntries = NoteChartEntryFactory:getEntries(entries)

	for i = 1, #noteChartEntries do
		local noteChartEntry = noteChartEntries[i]
		-- self.log:write("entry", "adding " .. noteChartEntry.path)

		noteChartEntry.setId = noteChartSetEntry.id
		
		Cache:setNoteChartEntry(noteChartEntry)
		self.noteChartCount = self.noteChartCount + 1

		-- self.log:write("chart", noteChartEntry.path:match("^.+/(.-)$"))
	end
	self:checkProgress()
end

NoteChartManager.generateCacheFull = function(self)
	CacheDatabase:load()

	self:resetProgress()
	print("Find all charts")
	Cache:select()
	CacheDatabase:begin()
	self:lookup("userdata/charts", false)
	CacheDatabase:commit()
	
	print("Create cache")
	Cache:select()
	self:generate()
	print("end")

	CacheDatabase:unload()
end

NoteChartManager.generate = function(self)
	local noteChartSets = Cache.noteChartSets
	local length = #tostring(#noteChartSets)

	CacheDatabase:begin()
	for i = 1, #noteChartSets do
		local status, err = xpcall(function()
			self:processNoteChartDataEntries(Cache:getNoteChartsAtSet(noteChartSets[i].id), false)
		end, debug.traceback)
		if not status then
			self.log:write("error", noteChartSets[i].id)
			self.log:write("error", noteChartSets[i].path)
			self.log:write("error", err)
		end

		print(("%" .. length .. "d/%d"):format(i, #noteChartSets))
		if i % 100 == 0 then
			CacheDatabase:commit()
			CacheDatabase:begin()
		end
	end
	CacheDatabase:commit()
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
