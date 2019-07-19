local sqlite = require("ljsqlite3")
local NoteChartFactory = require("sphere.game.NoteChartManager.NoteChartFactory")
local CacheDataFactory = require("sphere.game.NoteChartManager.CacheDataFactory")
local ThreadPool = require("aqua.thread.ThreadPool")

local CacheDatabase = {}

CacheDatabase.dbpath = "userdata/cache.sqlite"
CacheDatabase.chartspath = "userdata/charts"

CacheDatabase.chartColumns = {
	"id",
	"chartSetId",
	"hash",
	"path",
	"title",
	"artist",
	"source",
	"tags",
	"name",
	"level",
	"creator",
	"audioPath",
	"stagePath",
	"previewTime",
	"noteCount",
	"length",
	"bpm",
	"inputMode"
}

CacheDatabase.chartSetColumns = {
	"id",
	"path"
}

CacheDatabase.chartNumberColumns = {
	"id",
	"chartSetId",
	"level",
	"previewTime",
	"noteCount",
	"length",
	"bpm"
}

CacheDatabase.chartSetNumberColumns = {
	"id"
}

CacheDatabase.unload = function(self)
	self.db:close()
end

CacheDatabase.load = function(self)
	self.db = sqlite.open(self.dbpath)
	
	self.db:exec[[
		CREATE TABLE IF NOT EXISTS `charts` (
			`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
			`chartSetId` INTEGER NOT NULL,
			`hash` TEXT NOT NULL DEFAULT '',
			`path` TEXT UNIQUE,
			
			`title` TEXT,
			`artist` TEXT,
			`source` TEXT,
			`tags` TEXT,
			`name` TEXT,
			`level` REAL,
			`creator` TEXT,
			`audioPath` TEXT,
			`stagePath` TEXT,
			`previewTime` REAL,
			`noteCount` REAL,
			`length` REAL,
			`bpm` REAL,
			`inputMode` TEXT
		);
		CREATE TABLE IF NOT EXISTS `chartSets` (
			`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
			`path` TEXT UNIQUE
		);
	]]
	
	self.insertChartStatement = self.db:prepare([[
		INSERT OR IGNORE INTO `charts` (
			chartSetId,
			hash,
			path,
			
			title,
			artist,
			source,
			tags,
			name,
			level,
			creator,
			audioPath,
			stagePath,
			previewTime,
			noteCount,
			length,
			bpm,
			inputMode
		)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
	]])
	
	self.updateChartStatement = self.db:prepare([[
		UPDATE `charts` SET
			chartSetId = ?,
			hash = ?,
			path = ?,
			
			title = ?,
			artist = ?,
			source = ?,
			tags = ?,
			name = ?,
			level = ?,
			creator = ?,
			audioPath = ?,
			stagePath = ?,
			previewTime = ?,
			noteCount = ?,
			length = ?,
			bpm = ?,
			inputMode = ?
		WHERE `path` = ?;
	]])
	
	self.insertChartSetStatement = self.db:prepare([[
		INSERT OR IGNORE INTO `chartSets` (
			path
		)
		VALUES (?);
	]])
	
	self.selectChartStatement = self.db:prepare([[
		SELECT * FROM `charts` WHERE path = ?
	]])
	
	self.selectChartSetStatement = self.db:prepare([[
		SELECT * FROM `chartSets` WHERE path = ?
	]])
end

CacheDatabase.begin = function(self)
	self.db:exec("BEGIN;")
end

CacheDatabase.commit = function(self)
	self.db:exec("COMMIT;")
end

CacheDatabase.update = function(self, path, recursive, callback)
	if not self.isUpdating then
		ThreadPool:execute(
			[[
				local path, recursive = ...
				local CacheDatabase = require("sphere.game.NoteChartManager.CacheDatabase")
				CacheDatabase:load()
				CacheDatabase:lookup(path, recursive)
				CacheDatabase:unload()
			]],
			{path, recursive},
			function(result)
				callback()
				self.isUpdating = false
			end
		)
		self.isUpdating = true
	end
end

CacheDatabase.checkChartSetData = function(self, path)
	return self.selectChartSetStatement:reset():bind(path):step()
end

CacheDatabase.getChartSetData = function(self, path)
	self.insertChartSetStatement:reset():bind(path):step()
	return self:checkChartSetData(path)
end

CacheDatabase.lookup = function(self, directoryPath, recursive)
	if love.filesystem.isFile(directoryPath) then
		return
	end
	
	local items = love.filesystem.getDirectoryItems(directoryPath)
	
	local containerPaths = {}
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isFile(path) and NoteChartFactory:isNoteChartContainer(path) then
			containerPaths[#containerPaths + 1] = path
			self:lookupContainer(path)
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
		self:processNoteChartSet(chartPaths, directoryPath)
		return
	end
	
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isDirectory(path) and (recursive or not self:checkChartSetData(path)) then
			self:lookup(path, true)
		end
	end
end

CacheDatabase.lookupContainer = function(self, containerPath)
	print(containerPath)
	self:begin()
	local chartSetData = self:getChartSetData(containerPath)
	
	local cacheDatas = CacheDataFactory:getCacheDatas({containerPath})
	
	for i = 1, #cacheDatas do
		local cacheData = cacheDatas[i]
		
		cacheData.chartSetId = chartSetData[1]
		
		self:setChartData(cacheData)
	end
	self:commit()
end

CacheDatabase.processNoteChartSet = function(self, chartPaths, directoryPath)
	print(directoryPath)
	self:begin()
	local chartSetData = self:getChartSetData(directoryPath)
	
	for _, paths in ipairs(NoteChartFactory:splitList(chartPaths)) do
		local cacheDatas = CacheDataFactory:getCacheDatas(paths)
		
		for i = 1, #cacheDatas do
			local cacheData = cacheDatas[i]
			
			cacheData.chartSetId = chartSetData[1]
			
			self:setChartData(cacheData)
		end
	end
	self:commit()
end

CacheDatabase.setChartData = function(self, cacheData)
	self.insertChartStatement:reset():bind(
		cacheData.chartSetId,
		cacheData.hash,
		cacheData.path,
		
		cacheData.title,
		cacheData.artist,
		cacheData.source,
		cacheData.tags,
		cacheData.name,
		cacheData.level,
		cacheData.creator,
		cacheData.audioPath,
		cacheData.stagePath,
		cacheData.previewTime,
		cacheData.noteCount,
		cacheData.length,
		cacheData.bpm,
		cacheData.inputMode
	):step()
	self.updateChartStatement:reset():bind(
		cacheData.chartSetId,
		cacheData.hash,
		cacheData.path,
		
		cacheData.title,
		cacheData.artist,
		cacheData.source,
		cacheData.tags,
		cacheData.name,
		cacheData.level,
		cacheData.creator,
		cacheData.audioPath,
		cacheData.stagePath,
		cacheData.previewTime,
		cacheData.noteCount,
		cacheData.length,
		cacheData.bpm,
		cacheData.inputMode,
		
		cacheData.path
	):step()
end

return CacheDatabase
