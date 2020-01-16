local CacheDatabase = require("sphere.database.CacheDatabase")

local Cache = {}

Cache.select = function(self)
	if self.lock then
		return
	end
	
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

	if oldEntry then
		return oldEntry
	end

	entry = CacheDatabase:getNoteChartSetEntry(entry)

	self.noteChartSets[#self.noteChartSets + 1] = entry
	self.noteChartsAtSet[entry.id] = {}
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

----------------------------------------------------------------

Cache.update = function(self, path, recursive)
	self.lock = true
	if not self.isUpdating then
		self.isUpdating = true
		return ThreadPool:execute(
			[[
				local path, recursive = ...
				
				local CacheDatabase = require("sphere.database.CacheDatabase")
				local CacheDataFactory = require("sphere.database.CacheDataFactory")
				local NoteChartFactory = require("sphere.database.NoteChartFactory")
				CacheDatabase:init()
				CacheDataFactory:init()
				NoteChartFactory:init()
				
				CacheDatabase:load()
				--CacheDatabase:lookup(path, recursive)
				CacheDatabase:unload()
			]],
			{path, recursive},
			function(result)
				self.lock = false
				self:select()
				self.isUpdating = false
			end
		)
	end
end

return Cache
