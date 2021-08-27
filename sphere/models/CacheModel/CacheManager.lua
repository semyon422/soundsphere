local CacheDatabase				= require("sphere.models.CacheModel.CacheDatabase")
local DifficultyModel			= require("sphere.models.DifficultyModel")
local NoteChartFactory			= require("notechart.NoteChartFactory")
local NoteChartDataEntryFactory	= require("notechart.NoteChartDataEntryFactory")
local Log						= require("aqua.util.Log")
local Class						= require("aqua.util.Class")
local md5						= require("md5")

local CacheManager = Class:new()

CacheManager.construct = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/cache.log"

	self.state = 0

	self:clear()
end

CacheManager.clear = function(self)
	self.noteChartsAtSet = {}
	self.noteChartsAtHash = {}
	self.noteChartSets = {}
	self.noteChartDatas = {}
	self.noteCharts = {}
	self.noteChartsId = {}
	self.noteChartsPath = {}
	self.noteChartSetsId = {}
	self.noteChartSetsPath = {}
	self.noteChartDatasHashIndex = {}
end

CacheManager.select = function(self)
	local loaded = CacheDatabase.loaded
	if not loaded then
		CacheDatabase:load()
	end

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
	local noteChartDatasId = {}
	local noteChartDatasHashIndex = {}
	self.noteChartsId = noteChartsId
	self.noteChartsPath = noteChartsPath
	self.noteChartSetsId = noteChartSetsId
	self.noteChartSetsPath = noteChartSetsPath
	self.noteChartDatasId = noteChartDatasId
	self.noteChartDatasHashIndex = noteChartDatasHashIndex

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
		noteChartDatasHashIndex[entry.hash] = noteChartDatasHashIndex[entry.hash] or {}
		noteChartDatasHashIndex[entry.hash][entry.index] = entry
		noteChartDatasId[entry.id] = entry
	end

	if not loaded then
		CacheDatabase:unload()
	end
end

----------------------------------------------------------------

CacheManager.getNoteCharts = function(self)
	return self.noteCharts
end

CacheManager.getNoteChartSets = function(self)
	return self.noteChartSets
end

----------------------------------------------------------------

CacheManager.getNoteChartSetEntry = function(self, entry)
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

CacheManager.setNoteChartEntry = function(self, entry)
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

CacheManager.setNoteChartDataEntry = function(self, entry)
	local oldEntry = self:getNoteChartDataEntry(entry.hash, entry.index)

	CacheDatabase:setNoteChartDataEntry(entry)

	if not oldEntry then
		self.noteChartDatas[#self.noteChartDatas + 1] = entry
		self.noteChartsAtHash[entry.hash] = {}
		self.noteChartDatasHashIndex[entry.hash] = self.noteChartDatasHashIndex[entry.hash] or {}
		self.noteChartDatasHashIndex[entry.hash][entry.index] = entry
	else
		for k, v in pairs(entry) do
			oldEntry[k] = v
		end
	end
end

----------------------------------------------------------------

CacheManager.deleteNoteChartEntry = function(self, entry)
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

	self.noteChartDatasHashIndex[entry.hash] = nil
end

CacheManager.deleteNoteChartSetEntry = function(self, entry)
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

CacheManager.getNoteChartEntryById = function(self, id)
	return self.noteChartsId[id]
end

CacheManager.getNoteChartEntryByPath = function(self, path)
	return self.noteChartsPath[path]
end

CacheManager.getNoteChartSetEntryById = function(self, id)
	return self.noteChartSetsId[id]
end

CacheManager.getNoteChartSetEntryByPath = function(self, path)
	return self.noteChartSetsPath[path]
end

----------------------------------------------------------------

CacheManager.getNoteChartsAtSet = function(self, setId)
	return self.noteChartsAtSet[setId]
end

CacheManager.getNoteChartsAtHash = function(self, hash)
	return self.noteChartsAtHash[hash]
end

CacheManager.getNoteChartDataEntry = function(self, hash, index)
	local t = self.noteChartDatasHashIndex
	return t[hash] and t[hash][index]
end

CacheManager.getNoteChartDataEntryById = function(self, id)
	return self.noteChartDatasId[id]
end

CacheManager.getAllNoteChartDataEntries = function(self, hash)
	local t = {}

	local hashIndex = self.noteChartDatasHashIndex[hash]
	if not hashIndex then
		return t
	end

	for k, v in pairs(hashIndex) do
		t[k] = v
	end

	return t
end

----------------------------------------------------------------

CacheManager.getEmptyNoteChartDataEntry = function(self, path)
	return {
		hash = "",
		index = 1,
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
		difficulty = 0,
		longNoteRatio = 0,
	}
end

----------------------------------------------------------------

CacheManager.checkThreadEvent = function(self)
	if thread then
		local event = thread:pop()
		if event and event.name == "CacheUpdater" then
			if event.action == "stop" then
				self.needStop = true
			end
		end
	end
end

CacheManager.sendThreadEvent = function(self)
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

CacheManager.resetProgress = function(self)
	self.noteChartSetCount = self.noteChartSets and #self.noteChartSets or 0
	self.noteChartCount = self.noteCharts and #self.noteCharts or 0
	self.cachePercent = 0

	self.countDelta = 100
	self.countNext = self.noteChartSetCount + self.countDelta

	self.state = 0
end

CacheManager.checkProgress = function(self)
	if self.noteChartSetCount >= self.countNext then
		self.countNext = self.countNext + self.countDelta

		CacheDatabase:commit()
		CacheDatabase:begin()
	end

	self:sendThreadEvent()
	self:checkThreadEvent()
end

CacheManager.generateCacheFull = function(self, path, force)
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

	self:generate(path, force)

	self.state = 3
	self:checkProgress()

	CacheDatabase:unload()
end

CacheManager.lookup = function(self, directoryPath, recursive)
	if self.needStop then
		return
	end

	local items = love.filesystem.getDirectoryItems(directoryPath)

	local chartPaths = {}
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isRelatedContainer(path) then
			chartPaths[#chartPaths + 1] = path
		end
	end
	if #chartPaths > 0 then
		self:processNoteChartEntries(chartPaths, directoryPath)
		return
	end

	local containerPaths = {}
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info and info.type == "file" and NoteChartFactory:isUnrelatedContainer(path) and self:checkNoteChartSetEntry(path) then
			containerPaths[#containerPaths + 1] = path
			self:processNoteChartEntries({path}, path)
		end
	end
	if #containerPaths > 0 then
		return
	end

	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		local info = love.filesystem.getInfo(path)
		if info and (info.type == "directory" or info.type == "symlink") and (recursive or self:checkNoteChartSetEntry(path)) then
			self:lookup(path, recursive)
		end
	end
end

CacheManager.checkNoteChartSetEntry = function(self, path)
	local entry = self:getNoteChartSetEntryByPath(path)
	if not entry then
		return true
	end

	local info = love.filesystem.getInfo(path)
	if info and entry.lastModified ~= info.modtime then
		return true
	end

	return false
end

CacheManager.processNoteChartEntries = function(self, noteChartPaths, noteChartSetPath)
	local info = love.filesystem.getInfo(noteChartSetPath)
	local noteChartSetEntry = self:getNoteChartSetEntry({
		path = noteChartSetPath,
		lastModified = info.modtime
	})
	self.noteChartSetCount = self.noteChartSetCount + 1

	local noteChartsAtSet = self:getNoteChartsAtSet(noteChartSetEntry.id) or {}
	local cachedEntries = {}
	for i = 1, #noteChartsAtSet do
		cachedEntries[i] = noteChartsAtSet[i]
	end
	for i = 1, #cachedEntries do
		local info = love.filesystem.getInfo(cachedEntries[i].path)
		if not info then
			self:deleteNoteChartEntry(cachedEntries[i])
		end
	end

	for i = 1, #noteChartPaths do
		local path = noteChartPaths[i]
		local info = love.filesystem.getInfo(path)
		local lastModified = info.modtime
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
			self:setNoteChartEntry({
				hash = nil,
				path = noteChartPaths[i],
				lastModified = lastModified,
				setId = noteChartSetEntry.id
			})
			self.noteChartCount = self.noteChartCount + 1
		end
	end

	self:checkProgress()
end

CacheManager.generate = function(self, path, force)
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
		local status, err = xpcall(function() return self:processNoteChartDataEntries(entries[i], force) end, debug.traceback)

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

CacheManager.processNoteChartDataEntries = function(self, noteChartSetEntry, force)
	local info = love.filesystem.getInfo(noteChartSetEntry.path)
	if not info then
		return self:deleteNoteChartSetEntry(noteChartSetEntry)
	end

	local noteChartEntries = self:getNoteChartsAtSet(noteChartSetEntry.id)

	local newNoteChartEntries = {}
	for i = 1, #noteChartEntries do
		local noteChartEntry = noteChartEntries[i]
		if not noteChartEntry.hash or force then
			newNoteChartEntries[#newNoteChartEntries + 1] = noteChartEntry
		end
	end
	noteChartEntries = newNoteChartEntries

	local fileContent = {}
	local fileHash = {}

	for i = 1, #noteChartEntries do
		local path = noteChartEntries[i].path
		if not fileContent[path] then
			local content = love.filesystem.read(path)

			fileContent[path] = content
			fileHash[path] = md5.sumhexa(content)
		end
	end

	local fileDatas = {}
	for i = 1, #noteChartEntries do
		local path = noteChartEntries[i].path

		local noteChartEntry = noteChartEntries[i]
		local content = fileContent[path]
		local hash = fileHash[path]
		noteChartEntry.hash = hash

		if not force and self:getNoteChartDataEntry(hash, 1) then
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

	local entries, noteCharts = NoteChartDataEntryFactory:getEntries(fileDatas)
	for i, entry in ipairs(entries) do
		local noteChart = noteCharts[i]
		local difficulty, longNoteRate = DifficultyModel:getDifficulty(noteChart)
		entry.difficulty = difficulty
		entry.longNoteRate = longNoteRate
		self:setNoteChartDataEntry(entry)
		self:setNoteChartEntry(entry.noteChartEntry)
	end
end

return CacheManager
