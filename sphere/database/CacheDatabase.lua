local ThreadPool		= require("aqua.thread.ThreadPool")
local Log				= require("aqua.util.Log")
local sqlite			= require("ljsqlite3")
local CacheDataFactory	= require("sphere.database.CacheDataFactory")
local NoteChartFactory	= require("sphere.database.NoteChartFactory")

local CacheDatabase = {}

CacheDatabase.dbpath = "userdata/charts.db"
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

local createTableRequest = [[
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

local insertChartRequest = [[
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
]]

local updateChartRequest = [[
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
]]

local insertChartSetRequest = [[
	INSERT OR IGNORE INTO `chartSets` (
		path
	)
	VALUES (?);
]]

local selectChartRequest = [[
	SELECT * FROM `charts` WHERE path = ?
]]

local selectChartSetRequest = [[
	SELECT * FROM `chartSets` WHERE path = ?
]]

local deleteChartRequest = [[
	DELETE FROM `charts` WHERE INSTR(`path`, ?) == 1
]]

local deleteChartSetRequest = [[
	DELETE FROM `chartSets` WHERE INSTR(`path`, ?) == 1
]]

CacheDatabase.init = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/cache.log"
end

CacheDatabase.load = function(self)
	self.db = sqlite.open(self.dbpath)
	
	self.db:exec(createTableRequest)
	
	self.insertChartStatement = self.db:prepare(insertChartRequest)
	self.updateChartStatement = self.db:prepare(updateChartRequest)
	self.insertChartSetStatement = self.db:prepare(insertChartSetRequest)
	self.selectChartStatement = self.db:prepare(selectChartRequest)
	self.selectChartSetStatement = self.db:prepare(selectChartSetRequest)
	self.deleteChartStatement = self.db:prepare(deleteChartRequest)
	self.deleteChartSetStatement = self.db:prepare(deleteChartSetRequest)
end

CacheDatabase.unload = function(self)
	return self.db:close()
end

CacheDatabase.begin = function(self)
	return self.db:exec("BEGIN;")
end

CacheDatabase.commit = function(self)
	return self.db:exec("COMMIT;")
end

CacheDatabase.checkChartSetData = function(self, path)
	return self.selectChartSetStatement:reset():bind(path):step()
end

CacheDatabase.getChartSetData = function(self, path)
	self.insertChartSetStatement:reset():bind(path):step()
	return self:checkChartSetData(path)
end

CacheDatabase.deleteChartData = function(self, path)
	return self.deleteChartStatement:reset():bind(path):step()
end

CacheDatabase.deleteChartSetData = function(self, path)
	return self.deleteChartSetStatement:reset():bind(path):step()
end

CacheDatabase.update = function(self, path, recursive, callback)
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
				CacheDatabase:clear(path)
				CacheDatabase:lookup(path, recursive)
				CacheDatabase:unload()
			]],
			{path, recursive},
			function(result)
				callback()
				self.isUpdating = false
			end
		)
	end
end

CacheDatabase.lookup = function(self, directoryPath, recursive)
	if love.filesystem.isFile(directoryPath) then
		if NoteChartFactory:isNoteChartContainer(directoryPath) then
			self:lookupContainer(directoryPath)
		end
		return
	end
	
	self.log:write("lookup", directoryPath)
	
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
			self:lookup(path, recursive)
		end
	end
end

CacheDatabase.clear = function(self, directoryPath)
	if love.filesystem.exists(directoryPath) then
		return
	end
	
	self.log:write("clear", directoryPath)
	
	self:deleteChartData(directoryPath)
	self:deleteChartSetData(directoryPath)
end

CacheDatabase.lookupContainer = function(self, containerPath)
	self.log:write("ncc", containerPath:match("^.+/(.-)$"))
	
	self:begin()
	self:processCacheDatas(
		CacheDataFactory:getCacheDatas({containerPath}),
		self:getChartSetData(containerPath)
	)
	self:commit()
end

CacheDatabase.processNoteChartSet = function(self, chartPaths, directoryPath)
	self.log:write("ncs", directoryPath:match("^.+/(.-)$"))
	
	self:begin()
	self:processCacheDatas(
		CacheDataFactory:getCacheDatas(chartPaths),
		self:getChartSetData(directoryPath)
	)
	self:commit()
end

CacheDatabase.processCacheDatas = function(self, cacheDatas, chartSetData)
	for i = 1, #cacheDatas do
		local cacheData = cacheDatas[i]
		cacheData.chartSetId = chartSetData[1]
		self.log:write("chart", cacheData.path:match("^.+/(.-)$"))
		self:setNoteChartData(cacheData)
	end
end

CacheDatabase.setNoteChartData = function(self, data)
	self:insertNoteChartData(data)
	self:updateNoteChartData(data)
end

CacheDatabase.insertNoteChartData = function(self, data)
	return self.insertChartStatement:reset():bind(
		data.chartSetId,
		data.hash,
		data.path,
		data.title,
		data.artist,
		data.source,
		data.tags,
		data.name,
		data.level,
		data.creator,
		data.audioPath,
		data.stagePath,
		data.previewTime,
		data.noteCount,
		data.length,
		data.bpm,
		data.inputMode
	):step()
end

CacheDatabase.updateNoteChartData = function(self, data)
	return self.updateChartStatement:reset():bind(
		data.chartSetId,
		data.hash,
		data.path,
		data.title,
		data.artist,
		data.source,
		data.tags,
		data.name,
		data.level,
		data.creator,
		data.audioPath,
		data.stagePath,
		data.previewTime,
		data.noteCount,
		data.length,
		data.bpm,
		data.inputMode,
		data.path
	):step()
end

CacheDatabase.insertNoteChartData = function(self, path)
	self:setChartData({
		chartSetId	= 0,
		path		= path,
		hash		= "",
		title		= "",
		artist		= "",
		source		= "",
		tags		= "",
		name		= "",
		level		= 0,
		creator		= "",
		audioPath	= "",
		stagePath	= "",
		previewTime	= 0,
		noteCount	= 0,
		length		= 0,
		bpm			= 0,
		inputMode	= ""
	})
end

return CacheDatabase
