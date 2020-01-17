local CacheDatabase				= require("sphere.database.CacheDatabase")
local NoteChartFactory			= require("sphere.database.NoteChartFactory")
local NoteChartEntryFactory		= require("sphere.database.NoteChartEntryFactory")
local NoteChartDataEntryFactory	= require("sphere.database.NoteChartDataEntryFactory")
local Log						= require("aqua.util.Log")
local md5						= require("md5")

local Cache = {}

Cache.init = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/cache.log"

	self.state = 0
end

Cache.clear = function(self)
	self.noteChartsAtSet = nil
	self.noteChartsAtHash = nil
	self.noteChartSets = nil
	self.noteChartDatas = nil
	self.noteCharts = nil
	self.noteChartsId = nil
	self.noteChartsPath = nil
	self.noteChartSetsId = nil
	self.noteChartSetsPath = nil
	self.noteChartDatasHash = nil
end

Cache.select = function(self)
	local loaded = CacheDatabase.loaded
	if not loaded then
		CacheDatabase:load()
	end
	
	local db = CacheDatabase.db

	local selectAllNoteChartsStatement		= CacheDatabase.selectAllNoteChartsStatement
	local selectAllNoteChartSetsStatement	= CacheDatabase.selectAllNoteChartSetsStatement
	local selectAllNoteChartDatasStatement	= CacheDatabase.selectAllNoteChartDatasStatement

	local noteChartsAtSet = {}
	local noteChartsAtHash = {}
	self.noteChartsAtSet = noteChartsAtSet
	self.noteChartsAtHash = noteChartsAtHash

	local noteChartSets = {}
	self.noteChartSets = noteChartSets
	
	local stmt = selectAllNoteChartSetsStatement:reset()
	local row = stmt:step()
	while row do
		local entry = CacheDatabase:transformNoteChartSetEntry(row)
		noteChartSets[#noteChartSets + 1] = entry

		noteChartsAtSet[entry.id] = {}

		row = stmt:step()
	end
	
	local noteChartDatas = {}
	self.noteChartDatas = noteChartDatas

	local stmt = selectAllNoteChartDatasStatement:reset()
	local row = stmt:step()
	while row do
		local entry = CacheDatabase:transformNoteChartDataEntry(row)
		noteChartDatas[#noteChartDatas + 1] = entry

		noteChartsAtHash[entry.hash] = {}

		row = stmt:step()
	end
	
	local noteCharts = {}
	self.noteCharts = noteCharts

	local stmt = selectAllNoteChartsStatement:reset()
	local row = stmt:step()
	while row do
		local entry = CacheDatabase:transformNoteChartEntry(row)
		noteCharts[#noteCharts + 1] = entry

		if entry.setId then
			local setList = noteChartsAtSet[entry.setId]
			if setList then
				setList[#setList + 1] = entry
			else
				entry.setId = nil
			end
		end

		if entry.hash then
			local hashList = noteChartsAtHash[entry.hash]
			if hashList then
				hashList[#hashList + 1] = entry
			else
				entry.hash = nil
			end
		end

		row = stmt:step()
	end
	
	local noteChartsId = {}
	local noteChartsPath = {}
	local noteChartSetsId = {}
	local noteChartSetsPath = {}
	local noteChartDatasHash = {}
	self.noteChartsId = noteChartsId
	self.noteChartsPath = noteChartsPath
	self.noteChartSetsId = noteChartSetsId
	self.noteChartSetsPath = noteChartSetsPath
	self.noteChartDatasHash = noteChartDatasHash
	
	for i = 1, #noteCharts do
		local entry = noteCharts[i]
		noteChartsId[entry.id] = entry
		noteChartsPath[entry.path] = entry
	end
	for i = 1, #noteChartSets do
		local entry = noteChartSets[i]
		noteChartSetsId[entry.id] = entry
		noteChartSetsPath[entry.path] = entry
	end
	for i = 1, #noteChartDatas do
		local entry = noteChartDatas[i]
		noteChartDatasHash[entry.hash] = entry
	end
	
	if not loaded then
		CacheDatabase:unload()
	end
end

----------------------------------------------------------------

Cache.getNoteCharts = function(self)
	return self.noteCharts
end

Cache.getNoteChartSets = function(self)
	return self.noteChartSets
end

----------------------------------------------------------------

Cache.getNoteChartSetEntry = function(self, entry)
	local oldEntry = self:getNoteChartSetEntryByPath(entry.path)

	if oldEntry and oldEntry.lastModified == entry.lastModified then
		return oldEntry
	end

	entry = CacheDatabase:getNoteChartSetEntry(entry)

	self.noteChartSets[#self.noteChartSets + 1] = entry
	if oldEntry then
		self.noteChartsAtSet[entry.id] = self.noteChartsAtSet[oldEntry.id]
	else
		self.noteChartsAtSet[entry.id] = {}
	end
	self.noteChartSetsId[entry.id] = entry
	self.noteChartSetsPath[entry.path] = entry

	return entry
end

Cache.setNoteChartEntry = function(self, entry)
	local oldEntry = self:getNoteChartEntryByPath(entry.path)

	CacheDatabase:setNoteChartEntry(entry)

	if not oldEntry then
		self.noteCharts[#self.noteCharts + 1] = entry

		local setList = self.noteChartsAtSet[entry.setId]
		setList[#setList + 1] = entry

		if not entry.hash then
			return
		end

		local hashList = self.noteChartsAtHash[entry.hash]
		hashList[#hashList + 1] = entry
	else
		for k, v in pairs(entry) do
			oldEntry[k] = v
		end
	end
end

Cache.setNoteChartDataEntry = function(self, entry)
	local oldEntry = self:getNoteChartDataEntry(entry.hash)

	CacheDatabase:setNoteChartDataEntry(entry)

	if not oldEntry then
		self.noteChartDatas[#self.noteChartDatas + 1] = entry
		self.noteChartsAtHash[entry.hash] = {}
		self.noteChartDatasHash[entry.hash] = entry
	else
		for k, v in pairs(entry) do
			oldEntry[k] = v
		end
	end
end

----------------------------------------------------------------

Cache.deleteNoteChartEntry = function(self, entry)
	CacheDatabase:deleteNoteChartEntry(entry.path)

	local noteChartsAtSet = self:getNoteChartsAtSet(entry.setId) or {}
	for i = 1, #noteChartsAtSet do
		if noteChartsAtSet[i].path == entry.path then
			table.remove(noteChartsAtSet, i)
			break
		end
	end

	local noteCharts = self.noteCharts
	for i = 1, #noteCharts do
		if noteCharts[i].path == entry.path then
			table.remove(noteCharts, i)
			break
		end
	end

	if not entry.hash then
		return
	end

	local noteChartDatasHash = self.noteChartDatasHash[entry.hash] or {}
	for i = 1, #noteChartDatasHash do
		if noteChartDatasHash[i].path == entry.path then
			table.remove(noteChartDatasHash, i)
			break
		end
	end
end

Cache.deleteNoteChartSetEntry = function(self, entry)
	CacheDatabase:deleteNoteChartSetEntry(entry.path)
	
	local noteChartsAtSet = self:getNoteChartsAtSet(entry.id) or {}
	local cachedEntries = {}
	for i = 1, #noteChartsAtSet do
		cachedEntries[i] = noteChartsAtSet[i]
	end
	for i = 1, #cachedEntries do
		self:deleteNoteChartEntry(cachedEntries[i])
	end
end

----------------------------------------------------------------

Cache.getNoteChartEntryById = function(self, id)
	return self.noteChartsId[id]
end

Cache.getNoteChartEntryByPath = function(self, path)
	return self.noteChartsPath[path]
end

Cache.getNoteChartSetEntryById = function(self, id)
	return self.noteChartSetsId[id]
end

Cache.getNoteChartSetEntryByPath = function(self, path)
	return self.noteChartSetsPath[path]
end

----------------------------------------------------------------

Cache.getNoteChartsAtSet = function(self, setId)
	return self.noteChartsAtSet[setId]
end

Cache.getNoteChartsAtHash = function(self, hash)
	return self.noteChartsAtHash[hash]
end

Cache.getNoteChartDataEntry = function(self, hash)
	return self.noteChartDatasHash[hash]
end

Cache.getEmptyNoteChartDataEntry = function(self, path)
	return {
		hash = "",
		title = path:match(".+/(.-)$"),
		artist = "",
		source = "",
		tags = "",
		name = path:match(".+/(.-)$"),
		creator = "",
		audioPath = "",
		stagePath = "",
		previewTime = 0,
		inputMode = "",
		noteCount = 0,
		length = 0,
		bpm = 0,
		level = 0,
		difficultyRat = 0
	}
end

----------------------------------------------------------------

Cache.checkThreadEvent = function(self)
	if thread then
		local event = thread:pop()
		if event and event.name == "NoteChartManager" then
			if event.action == "stop" then
				self.needStop = true
			end
		end
	end
end

Cache.sendThreadEvent = function(self)
	if thread then
		thread:push({
			name = "CacheProgress",
			noteChartSetCount = self.noteChartSetCount,
			noteChartCount = self.noteChartCount,
			cachePercent = self.cachePercent,
			state = self.state
		})
	end
end

Cache.resetProgress = function(self)
	self.noteChartSetCount = self.noteChartSets and #self.noteChartSets or 0
	self.noteChartCount = self.noteCharts and #self.noteCharts or 0
	self.cachePercent = 0

	self.countDelta = 100
	self.countNext = self.noteChartSetCount + self.countDelta

	self.state = 0
end

Cache.checkProgress = function(self)
	if self.noteChartSetCount >= self.countNext then
		self.countNext = self.countNext + self.countDelta
		
		CacheDatabase:commit()
		CacheDatabase:begin()
	end

	self:sendThreadEvent()
	self:checkThreadEvent()
end

local getDirectoryItems, isFile, isDirectory = love.filesystem.getDirectoryItems, love.filesystem.isFile, love.filesystem.isDirectory
Cache.lookup = function(self, directoryPath, recursive)
	if self.needStop then
		return
	end

	local items = getDirectoryItems(directoryPath)
	
	local containerPaths = {}
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if isFile(path) and NoteChartFactory:isNoteChartContainer(path) and self:checkNoteChartSetEntry(path) then
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
		if isFile(path) and NoteChartFactory:isNoteChart(path) then
			chartPaths[#chartPaths + 1] = path
		end
	end
	if #chartPaths > 0 then
		self:processNoteChartEntries(chartPaths, directoryPath)
		return
	end
	
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if isDirectory(path) and (recursive or self:checkNoteChartSetEntry(path)) then
			self:lookup(path, recursive)
		end
	end
end

local getLastModified, exists = love.filesystem.getLastModified, love.filesystem.exists
Cache.checkNoteChartSetEntry = function(self, path)
	local entry = self:getNoteChartSetEntryByPath(path)
	if not entry then
		return true
	end

	local lastModified = getLastModified(path)
	if entry.lastModified ~= lastModified then
		return true
	end

	return false
end

Cache.processNoteChartEntries = function(self, noteChartPaths, noteChartSetPath)
	local noteChartSetEntry = self:getNoteChartSetEntry({
		path = noteChartSetPath,
		lastModified = getLastModified(noteChartSetPath)
	})
	self.noteChartSetCount = self.noteChartSetCount + 1
	
	local noteChartsAtSet = self:getNoteChartsAtSet(noteChartSetEntry.id) or {}
	local cachedEntries = {}
	for i = 1, #noteChartsAtSet do
		cachedEntries[i] = noteChartsAtSet[i]
	end
	for i = 1, #cachedEntries do
		if not exists(cachedEntries[i].path) then
			self:deleteNoteChartEntry(cachedEntries[i])
		end
	end

	local entries = {}
	for i = 1, #noteChartPaths do
		local path = noteChartPaths[i]
		local lastModified = getLastModified(path)
		local entry = self:getNoteChartEntryByPath(path)

		if entry then
			if entry.lastModified ~= lastModified then
				entry.hash = nil
				entry.lastModified = lastModified
				entry.setId = noteChartSetEntry.id
				self:setNoteChartEntry(entry)
			elseif entry.setId ~= noteChartSetEntry.id then
				entry.setId = noteChartSetEntry.id
				self:setNoteChartEntry(entry)
			end
		else
			entries[#entries + 1] = {
				path = noteChartPaths[i],
				lastModified = lastModified
			}
		end
	end
	local noteChartEntries = NoteChartEntryFactory:getEntries(entries)

	for i = 1, #noteChartEntries do
		local noteChartEntry = noteChartEntries[i]
		noteChartEntry.setId = noteChartSetEntry.id
		
		self:setNoteChartEntry(noteChartEntry)
		self.noteChartCount = self.noteChartCount + 1
	end

	self:checkProgress()
end

Cache.generate = function(self, path)
	local noteChartSets = self.noteChartSets
	local entries = {}
	for i = 1, #noteChartSets do
		local entry = noteChartSets[i]
		if entry.path:find(path, 1, true) then
			entries[#entries + 1] = entry
		end
	end

	CacheDatabase:begin()
	for i = 1, #entries do
		local status, err = xpcall(function()
			self:processNoteChartDataEntries(entries[i], false)
		end, debug.traceback)
		if not status then
			self.log:write("error", entries[i].id)
			self.log:write("error", entries[i].path)
			self.log:write("error", err)
		end

		if i % 100 == 0 then
			CacheDatabase:commit()
			CacheDatabase:begin()
		end

		self.cachePercent = (i - 1) / #entries * 100
		self:checkProgress()

		if self.needStop then
			CacheDatabase:commit()
			return
		end
	end
	CacheDatabase:commit()
end

Cache.generateCacheFull = function(self, path)
	local path = path or "userdata/charts"
	CacheDatabase:load()

	self:select()

	self:resetProgress()
	self.state = 1
	self:checkProgress()

	CacheDatabase:begin()
	self:lookup(path, false)
	CacheDatabase:commit()

	self:select()
	self.state = 2
	self:checkProgress()

	self:generate(path)

	self.state = 3
	self:checkProgress()

	CacheDatabase:unload()
end

Cache.getRealPath = function(self, path)
	if path:find("%.ojn/.$") then
		return path:match("^(.+)/.$")
	end
	return path
end

Cache.processNoteChartDataEntries = function(self, noteChartSetEntry, reHash)
	if not exists(noteChartSetEntry.path) then
		return self:deleteNoteChartSetEntry(noteChartSetEntry)
	end

	local noteChartEntries = self:getNoteChartsAtSet(noteChartSetEntry.id)

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
				self:setNoteChartEntry(noteChartEntry)
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

		self:setNoteChartDataEntry(fileData.noteChartDataEntry)
		self:setNoteChartEntry(fileData.noteChartEntry)
	end
end

return Cache
