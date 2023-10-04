local ChartRepo = require("sphere.persistence.CacheModel.ChartRepo")
local NoteChartFinder = require("sphere.persistence.CacheModel.NoteChartFinder")
local DifficultyModel = require("sphere.models.DifficultyModel")
local NoteChartFactory = require("notechart.NoteChartFactory")
local Log = require("Log")
local class = require("class")
local md5 = require("md5")
local Orm = require("Orm")

---@class sphere.CacheManager
---@operator call: sphere.CacheManager
local CacheManager = class()

function CacheManager:new()
	self.log = Log()
	self.log.console = true
	self.log.path = "userdata/cache.log"

	self.state = 0

	self.chartRepo = ChartRepo()
end

---@param entry table
---@return table
function CacheManager:getNoteChartSetEntry(entry)
	local oldEntry = self.chartRepo:selectNoteChartSetEntry(entry.path)

	if oldEntry and oldEntry.lastModified == entry.lastModified then
		return oldEntry
	end

	if not oldEntry then
		entry = self.chartRepo:insertNoteChartSetEntry(entry)
	else
		oldEntry.lastModified = entry.lastModified
		self.chartRepo:updateNoteChartSetEntry(entry)
		entry = oldEntry
	end

	return entry
end

---@param entry table
---@param isOldEntry boolean?
function CacheManager:setNoteChartEntry(entry, isOldEntry)
	local oldEntry = isOldEntry and entry or self.chartRepo:selectNoteChartEntry(entry.path)

	if not oldEntry then
		self.chartRepo:insertNoteChartEntry(entry)
	else
		self.chartRepo:updateNoteChartEntry(entry)
	end
end

---@param entry table
function CacheManager:setNoteChartDataEntry(entry)
	local oldEntry = self.chartRepo:selectNoteCharDataEntry(entry.hash, entry.index)

	if not oldEntry then
		self.chartRepo:insertNoteChartDataEntry(entry)
	else
		self.chartRepo:updateNoteChartDataEntry(entry)
	end
end

----------------------------------------------------------------

---@param entry table
function CacheManager:deleteNoteChartEntry(entry)
	self.chartRepo:deleteNoteChartEntry(entry.path)
end

---@param entry table
function CacheManager:deleteNoteChartSetEntry(entry)
	self.chartRepo:deleteNoteChartSetEntry(entry.path)

	local noteChartsAtSet = self.chartRepo:getNoteChartsAtSet(entry.id)
	for i = 1, #noteChartsAtSet do
		self:deleteNoteChartEntry(noteChartsAtSet[i])
	end
end

----------------------------------------------------------------

function CacheManager:resetProgress()
	self.noteChartSetCount = self.noteChartSets and #self.noteChartSets or 0
	self.noteChartCount = self.noteCharts and #self.noteCharts or 0
	self.cachePercent = 0

	self.countDelta = 100
	self.countNext = self.noteChartSetCount + self.countDelta

	self.state = 0
end

function CacheManager:checkProgress()
	if self.noteChartSetCount >= self.countNext then
		self.countNext = self.countNext + self.countDelta

		self.chartRepo:commit()
		self.chartRepo:begin()
	end

	local thread = require("thread")
	thread:update()

	local cache = thread.shared.cache
	cache.noteChartSetCount = self.noteChartSetCount
	cache.noteChartCount = self.noteChartCount
	cache.cachePercent = self.cachePercent
	cache.state = self.state

	if cache.stop then
		cache.stop = false
		self.needStop = true
	end
end

---@param path string
---@param force boolean?
function CacheManager:generateCacheFull(path, force)
	local path = path or "userdata/charts"
	self.chartRepo:load()

	self:resetProgress()
	self.state = 1
	self:checkProgress()

	self.chartRepo:begin()
	self:lookup(path, false)
	self.chartRepo:commit()

	self.state = 2
	self:checkProgress()

	self:generate(path, force)

	self.state = 3
	self:checkProgress()
end

---@param directoryPath string
---@param recursive boolean?
function CacheManager:lookup(directoryPath, recursive)
	local iterator = NoteChartFinder:newFileIterator(directoryPath, recursive, function(...)
		return self:checkNoteChartSetEntry(...)
	end)

	local noteChartSetPath
	local noteChartSetEntry
	for path, dirPath in iterator do
		if dirPath ~= noteChartSetPath then
			noteChartSetPath = dirPath
			noteChartSetEntry = self:processNoteChartSet(dirPath)
			self:checkProgress()
		end
		self:processNoteChartEntries(path, noteChartSetEntry)
		if self.needStop then
			return
		end
	end
end

---@param path string
---@return boolean
function CacheManager:checkNoteChartSetEntry(path)
	local entry = self.chartRepo:selectNoteChartSetEntry(path)
	if not entry then
		return true
	end

	local info = love.filesystem.getInfo(path)
	if info and entry.lastModified ~= info.modtime then
		return true
	end

	return false
end

---@param noteChartSetPath string
---@return table
function CacheManager:processNoteChartSet(noteChartSetPath)
	local info = love.filesystem.getInfo(noteChartSetPath)
	local noteChartSetEntry = self:getNoteChartSetEntry({
		path = noteChartSetPath,
		lastModified = info.modtime
	})
	self.noteChartSetCount = self.noteChartSetCount + 1

	local cachedEntries = self.chartRepo:getNoteChartsAtSet(noteChartSetEntry.id)
	for i = 1, #cachedEntries do
		local info = love.filesystem.getInfo(cachedEntries[i].path)
		if not info then
			self:deleteNoteChartEntry(cachedEntries[i])
		end
	end

	return noteChartSetEntry
end

---@param noteChartPath string
---@param noteChartSetEntry table
function CacheManager:processNoteChartEntries(noteChartPath, noteChartSetEntry)
	local info = love.filesystem.getInfo(noteChartPath)
	local lastModified = info.modtime
	local entry = self.chartRepo:selectNoteChartEntry(noteChartPath)

	if entry then
		if entry.lastModified ~= lastModified then
			entry.hash = Orm.NULL
			entry.lastModified = lastModified
			entry.setId = noteChartSetEntry.id
			self:setNoteChartEntry(entry, true)
		elseif entry.setId ~= noteChartSetEntry.id then
			entry.setId = noteChartSetEntry.id
			self:setNoteChartEntry(entry, true)
		end
	else
		self:setNoteChartEntry({
			path = noteChartPath,
			lastModified = lastModified,
			setId = noteChartSetEntry.id
		})
		self.noteChartCount = self.noteChartCount + 1
	end
end

---@param path string
---@param force boolean?
function CacheManager:generate(path, force)
	local entries = self.chartRepo:selectNoteChartSets(path)

	self.chartRepo:begin()
	for i = 1, #entries do
		local status, err = xpcall(function()
			return self:processNoteChartDataEntries(entries[i], force)
		end, debug.traceback)

		if not status then
			self.log:write("error", entries[i].id)
			self.log:write("error", entries[i].path)
			self.log:write("error", err)
		end

		if i % 100 == 0 then
			self.chartRepo:commit()
			self.chartRepo:begin()
		end

		self.cachePercent = (i - 1) / #entries * 100
		self:checkProgress()

		if self.needStop then
			self.chartRepo:commit()
			return
		end
	end
	self.chartRepo:commit()
end

---@param noteChartSetEntry table
---@param force boolean?
function CacheManager:processNoteChartDataEntries(noteChartSetEntry, force)
	local info = love.filesystem.getInfo(noteChartSetEntry.path)
	if not info then
		self:deleteNoteChartSetEntry(noteChartSetEntry)
		return
	end

	local noteChartEntries = self.chartRepo:getNoteChartsAtSet(noteChartSetEntry.id)

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

	for i = 1, #noteChartEntries do
		local path = noteChartEntries[i].path

		local noteChartEntry = noteChartEntries[i]
		local content = fileContent[path]
		local hash = fileHash[path]
		noteChartEntry.hash = hash

		if not force and self.chartRepo:selectNoteCharDataEntry(hash, 1) then
			self:setNoteChartEntry(noteChartEntry)
		else
			print(path)
			local noteCharts, err = NoteChartFactory:getNoteCharts(path, content)
			if noteCharts then
				for _, noteChart in ipairs(noteCharts) do
					local entry = noteChart.metaData
					local difficulty, longNoteRatio, longNoteArea = DifficultyModel:getDifficulty(noteChart)
					entry.difficulty = difficulty
					entry.longNoteRatio = longNoteRatio
					entry.hash = hash
					self:setNoteChartDataEntry(entry)
					self:setNoteChartEntry(noteChartEntry)
				end
			else
				print(err)
			end
		end
	end
end

return CacheManager
